// -----------------------------------------------------------------------------
//  Title      : Verilog SLZW AXI-4 Master Interface
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : slzw_axi4_master.v
//  Author     : Simon Southwell
//  Created    : 2022-02-07
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This file contains the AXI-4 master interface for the SLZW codec
// -----------------------------------------------------------------------------
//  Copyright (c) 2022 Simon Southwell
// -----------------------------------------------------------------------------
//
//  This is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  It is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this code. If not, see <http://www.gnu.org/licenses/>.
//
// -----------------------------------------------------------------------------

`timescale 1ns / 10ps

// -----------------------------------------------------------------------------
// DEFINITIONS
// -----------------------------------------------------------------------------

`ifndef RESET
//`RESET
`define RESET or negedge reset_n
`endif

module slzw_axi4_master
#(parameter
  RXFIFODEPTH                          = 256,
  USRPORTWIDTH                         = 32,      // Valid values, 32, 16 or 8
  DEFAULTBURSTSIZE                     = 128,     // Must be no greater than AXI limit (256) and a power of 2. Preferably <= RXFIFODEPTH/2 to hide latency
  DEFAULTARUSER                        = 1'b1,    // If Cacheable accesses required, this must be 1
  DEFAULTARCACHE                       = 4'b1110, // For cacheable accesses, bit 3 must be 1, and the rest a valid value as per A4.4 of AXI4 spec.
  DEFAULTPROT                          = 3'b000   // User level protection
)
(
  input                                aclk,
  input                                aresetn,

  // --- User interface ---
  input                                clear,
  input                                start,

  input      [31:0]                    rx_start_addr,
  input      [31:0]                    rx_len,
  input      [31:0]                    tx_start_addr,
  input      [31:0]                    tx_len,

  input                                user_read_byte,
  output     [USRPORTWIDTH-1:0]        user_read_data,
  output                               user_read_data_valid,

  input                                user_write_byte,
  input       [7:0]                    user_write_data,
  output                               user_write_ready,

  output                               busy,

  // --- AXI-4 bus ---

  // AXI write address bus.
  // Optional signals, unused: AWID, AWREGION, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWQOS
  output     [31:0]                    awaddr,
  output      [7:0]                    awlen,   // Optional. Default length 1 (AWLEN == 0)
  output      [2:0]                    awprot,
  output reg                           awvalid,
  input                                awready,

  // AXI write data bus.
  // Optional signals, unused:         WSTRB
  output     [31:0]                    wdata,
  output                               wlast,
  output reg                           wvalid,
  input                                wready,

  // AXI write response bus.
  // Optional signals, unused: BID, BRESP
  input                                bvalid,
  output                               bready,

  // AXI read address bus.
  // Optional signals, unused: ARID, ARREGION, ARSIZE, ARBURST, ARLOCK, ARQOS
  output reg [31:0]                    araddr,
  output reg  [7:0]                    arlen,   // Optional. Default length 1 (ARLEN == 0)
  output      [3:0]                    arcache, // Optional. Used for cache coherency
  output                               aruser,  // Optional. Used for cache coherency
  output      [2:0]                    arprot,
  output reg                           arvalid,
  input                                arready,

  // AXI read data bus.
  // Optional signals, unused: RID, RRSEP, RLAST
  input      [31:0]                    rdata,
  input                                rvalid,
  output                               rready
);

// ---------------------------------------------
// Local parameters
// ---------------------------------------------


localparam                             MAXUSRPORTWIDTH   = 32;
localparam                             MINUSRPORTWIDTH   =  8;
localparam                             MAXAXIBURSTSIZE   = 256;
localparam                             LOG2MAXAXIBURST   = $clog2(MAXAXIBURSTSIZE);
localparam                             LOG2BURSTSIZE     = $clog2(DEFAULTBURSTSIZE);

// ---------------------------------------------
// Configuration checks
// ---------------------------------------------

// synthesis translate_off
// Check that the default burst size is within AXI limits, and is
// also a power of 2
generate
if (DEFAULTBURSTSIZE > MAXAXIBURSTSIZE || DEFAULTBURSTSIZE < 1 ||
   ((DEFAULTBURSTSIZE & (DEFAULTBURSTSIZE-1)) != 0))
begin
  initial
  begin
    $display("**Runtime error for invalid DEFAULTBURSTSIZE parameter value %0d", DEFAULTBURSTSIZE);
    $finish(1);
  end
end
endgenerate

// Check USRPORTWIDTH is valid
generate
if ((USRPORTWIDTH & (USRPORTWIDTH-1) != 0) || (USRPORTWIDTH > MAXUSRPORTWIDTH) || (USRPORTWIDTH < MINUSRPORTWIDTH))
begin
  initial
  begin
    $display("**Runtime error for invalid USRPORTWIDTH parameter value %0d", USRPORTWIDTH);
    $finish(1);
  end
end
endgenerate
// synthesis translate_on


// ---------------------------------------------
// Registers
// ---------------------------------------------

reg                                    rbusy;
reg   [1:0]                            user_rd_byte_count;
reg  [31:0]                            remaining_word_count;   // Total count of remaining words requiring new read commands
reg  [31:0]                            rx_outstanding_count;   // Total count of outstanding words yet to be received
reg  [LOG2MAXAXIBURST-1:0]             rx_fifo_count;          // Count of words in RX fifo plus any already requested but not yet received
reg  [31:0]                            rx_len_int;
reg  [31:0]                            rx_len_words;
reg   [8:0]                            rx_words_to_boundary;

// ---------------------------------------------
// Signalling
// ---------------------------------------------

wire                                   clk;
wire                                   reset_n;

wire   [31:0]                          user_read_data_int;

wire                                   rx_empty;
wire                                   rx_full;

wire                                   rx_fifo_rd;
wire                                   rx_fifo_clr;
wire   [31:0]                          rx_fifo_data;

wire   [31:0]                          rx_start_addr_int;

wire                                   remain_count_gt_burst;
wire   [LOG2MAXAXIBURST-1:0]           next_burst_size;

wire   [1:0]                           user_rd_byte_count_cmp;

// ---------------------------------------------
// Combinatorial logic
// ---------------------------------------------

assign clk                             = aclk;
assign reset_n                         = aresetn;

assign busy                            = rbusy | ~rx_empty;

// Export the configured AXI control values
assign awprot                          = DEFAULTPROT;
assign arprot                          = DEFAULTPROT;
assign arcache                         = DEFAULTARCACHE;
assign aruser                          = DEFAULTARUSER;

assign bready                          = 1'b1;
assign rready                          = 1'b1;

// Calculate the user_rd_byte_count state to pop a word from the read fifo.
// For 8 bit interface this is 3 for every four outputs, for 16 this is 2
// for every other output and for 32 bits this is 0 for every output
assign user_rd_byte_count_cmp          = (USRPORTWIDTH == 32) ? 2'b00 :
                                         (USRPORTWIDTH == 16) ? 2'b10 :
                                                                2'b11 ;

// Pop a read fifo word if requested and not empty, and byte count is at word boundary
assign rx_fifo_rd                      = ~rx_empty & user_read_byte & (user_rd_byte_count == user_rd_byte_count_cmp);

// Clear the read fifo when requested
assign rx_fifo_clr                     = clear;

// User read data is valid when te read fifo is not empty
assign user_read_data_valid            = ~rx_empty;

// Depending on the byte count, rotate the read FIFO output to present the correct
// bits to the read data output
assign user_read_data_int              = (user_rd_byte_count == 2'b11) ? {rx_fifo_data[23:0], rx_fifo_data[31:24]} :
                                         (user_rd_byte_count == 2'b10) ? {rx_fifo_data[15:0], rx_fifo_data[31:16]} :
                                         (user_rd_byte_count == 2'b01) ? {rx_fifo_data[7:0],  rx_fifo_data[31:8]}  :
                                                                         {rx_fifo_data[31:0]};

// Export the user data by picking off the relevant bits of the full width word
assign user_read_data                  = user_read_data_int[USRPORTWIDTH-1:0];

// Calculate the internal start byte address, rounding down to word boundary
assign rx_start_addr_int               = {rx_start_addr[31:2], 2'b00}; // Round down

// Flag when the remaining word count is bigger than a burst segment
assign remain_count_gt_burst           = (remaining_word_count > DEFAULTBURSTSIZE) ? 1'b1 : 1'b0;

// The next command length is a whole burst segment if remaining words greater, else
// just the remaining words.
assign next_burst_size                 = remain_count_gt_burst ? DEFAULTBURSTSIZE[LOG2MAXAXIBURST-1:0] :
                                                                 remaining_word_count[LOG2MAXAXIBURST-1:0];

// ---------------------------------------------
// Receive data FIFO
// ---------------------------------------------

  slzw_fifo
  #(
     .DEPTH                            (RXFIFODEPTH),
     .WIDTH                            (32),
     .NEARLYFULL                       (128)
  ) rx_fifo
  (
    .clk                               (aclk),
    .reset_n                           (aresetn),

    .clr                               (rx_fifo_clr),

    .write                             (rvalid),
    .wdata                             (rdata),

    .read                              (rx_fifo_rd),
    .rdata                             (rx_fifo_data),

    .empty                             (rx_empty),
    .full                              (rx_full),
    .nearly_full                       ()
  );

// ---------------------------------------------
// RX Synchronous logic
// ---------------------------------------------

always @(posedge clk `RESET)
begin
  if (reset_n == 1'b0)
  begin
    user_rd_byte_count                 <= 2'b00;
    rbusy                              <= 1'b0;
    arvalid                            <= 1'b0;
    wvalid                             <= 1'b0;
    awvalid                            <= 1'b0;
  end
  else
  begin

    // Calculate requested RX length in words, rounding up for partial word
    rx_len_words                       <= rx_len[31:2] + {29'h0, |rx_len[1:0]}; // Round up

    // Calculate the number of words to the next burst size segment boundary.
    // By making the end of the first transfer align to a DEFAULTBURSTSIZE boundary
    // all sunsequent transfers won't cross the AXI burst 4K bounday crossing limit.
    // (See "AMBA AXI and ACE Protocol Specification", section A3.4.1, Address Structure)
    rx_words_to_boundary               <= DEFAULTBURSTSIZE[LOG2BURSTSIZE:0] - {2'b00, rx_start_addr_int[LOG2BURSTSIZE+1:2]};

    // Default arvalid state is to clear unless set and arready not asserted
    arvalid                            <= (arvalid & ~arready);

    // Decrement RX fifo count for every popped word.This logic must
    // be before the rx_fifo_count update for the new read burst command
    // logic below, in order not to overwrite adding the issued burst length.
    // That logic will include subtracting any popped word when updating
    // the state.
    if (rx_fifo_rd)
    begin
      rx_fifo_count                    <= rx_fifo_count - 1;
    end

    // If start asserted and not already rbusy, calculate first AXI address command
    if (start & ~rbusy)
    begin
      rbusy                            <= 1'b1;
      arvalid                          <= 1'b1;
      araddr                           <= rx_start_addr_int;

      // ARLEN is burst size - 1
      arlen                            <= rx_words_to_boundary[LOG2MAXAXIBURST-1:0] - 1;

      // Keep a count of words requested
      rx_fifo_count                    <= rx_words_to_boundary[LOG2MAXAXIBURST-1:0];

      // The remaining words to have read burst commands sent is requested
      // length (in words) less this burst size.
      remaining_word_count             <= rx_len_words - rx_words_to_boundary;

      // Store the requested transfer length to count down the received data
      rx_outstanding_count             <= rx_len_words;
    end

    // If a read transfer is already busy, send new read commands to cover all
    // the burst remaining segments
    if (rbusy)
    begin
      // If there are still words left to transfer and there is enough space remaining
      // in the rx fifo to take the largest requested data, issue a new read command.
      if (remaining_word_count != 0 && rx_fifo_count <= (RXFIFODEPTH-DEFAULTBURSTSIZE))
      begin
        // If read address bus not already active, or interface is ready, send the command
        if (~arvalid | arready)
        begin
          arvalid                      <= 1'b1;

          // The new burst address is the old, plus the previous length (arlen + 1) scaled to bytes
          araddr                       <= araddr + {(arlen + 1), 2'b00};

          // The command length is the next burst size - 1
          arlen                        <= next_burst_size - 8'd1;

          // Add new command word count to pending count, and subtract any word popped from RX fifo
          rx_fifo_count             <= rx_fifo_count + next_burst_size - {{LOG2MAXAXIBURST-2{1'b0}}, rx_fifo_rd};

          // The words remaining is the current value minus the next burst size
          remaining_word_count         <= remaining_word_count - next_burst_size;
        end
      end
    end

    // As data arrives, update rx state.
    if (rvalid)
    begin
      rx_outstanding_count             <= rx_outstanding_count - 32'd1;

      // If this is the last expected word, clear the busy flag.
      if (rx_outstanding_count == 32'd1)
      begin
        rbusy                          <= 1'b0;
      end
    end

    // As each byte is read over the user interface, keep track
    // of which byte in the word is being addressed. This scales 
    // with configured port width. So 8 bits gives 0, 1, 2, 3;
    // 16 bits gives 0, 2; 32 bits gives 0.
    if (user_read_byte & user_read_data_valid)
    begin
      user_rd_byte_count               <= user_rd_byte_count + USRPORTWIDTH/8;
    end

    // When a user request to clear, reset all the relevant state
    // to an idle condition.
    if (clear)
    begin
      user_rd_byte_count               <= 2'b00;
      rbusy                            <= 1'b0;
      arvalid                          <= 1'b0;
      wvalid                           <= 1'b0;
      awvalid                          <= 1'b0;
    end
  end
end

// ---------------------------------------------
// TX Synchronous logic
// ---------------------------------------------
always @(posedge clk `RESET)
begin
  if (reset_n == 1'b0)
  begin
  end
  else
  begin
  end
end

endmodule