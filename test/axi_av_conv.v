// -----------------------------------------------------------------------------
//  AXI to Avalon bus converter
// -----------------------------------------------------------------------------
//  File       : axi_av_conv.v
//  Author     : Simon Southwell
//  Created    : 2022-02-06
//  Platform   :
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This block is a converter from AXI-4 burst bus to Avalon RX and TX
//  burst bus protcols. This has the minimum required signalling, plsu some
//  optional signals to handle different burst sizes and have access to cache
//  coherency features (on the read port).
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

`ifndef RESET
//`RESET
`define RESET or negedge reset_n
`endif

module axi_av_conv
(
  input                                aclk,
  input                                aresetn,

  // --- AXI-4 slave bus ---

  // AXI write address bus.
  // Optional signals, unused: AWID, AWREGION, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWQOS,
  input  [31:0]                        axs_awaddr,
  input   [7:0]                        axs_awlen,   // Optional. Default length 1 (AWLEN == 0)
  input   [2:0]                        axs_awprot,
  input                                axs_awvalid,
  output                               axs_awready,

  // AXI write data bus.
  // Optional signals, unused: WSTRB
  input  [31:0]                        axs_wdata,
  input                                axs_wlast,
  input                                axs_wvalid,
  output                               axs_wready,

  // AXI write response bus.
  // Optional signals, unused: BID, BRESP
  output                               axs_bvalid,
  input                                axs_bready,

  // AXI read address bus.
  // Optional signals, unused: ARID, ARREGION, ARSIZE, ARBURST, ARLOCK, ARQOS
  input  [31:0]                        axs_araddr,
  input   [7:0]                        axs_arlen,   // Optional. Default length 1 (ARLEN == 0)
  input   [3:0]                        axs_arcache, // Optional. Used for cache coherency
  input                                axs_aruser,  // Optional. Used for cache coherency
  input   [2:0]                        axs_arprot,
  input                                axs_arvalid,
  output                               axs_arready,

  // AXI read data bus.
  // Optional signals, unused: RID, RRSEP, RLAST
  output [31:0]                        axs_rdata,
  output                               axs_rvalid,
  input                                axs_rready,

  // --- Avalon burst bussses ---

  // Burst read master interface
  input                                avm_rx_waitrequest,
  output [11:0]                        avm_rx_burstcount,
  output [31:0]                        avm_rx_address,
  output                               avm_rx_read,
  input  [31:0]                        avm_rx_readdata,
  input                                avm_rx_readdatavalid,

  // Burst write master interface
  input                                avm_tx_waitrequest,
  output [11:0]                        avm_tx_burstcount,
  output [31:0]                        avm_tx_address,
  output                               avm_tx_write,
  output [31:0]                        avm_tx_writedata
);

// ---------------------------------------------
// Registers
// ---------------------------------------------

reg  [7:0]                             axs_awlen_held;
reg [31:0]                             axs_awaddr_held;
reg                                    axs_wr_busy;

// ---------------------------------------------
// ---------------------------------------------

wire   clk                             = aclk;
wire   reset_n                         = aresetn;

// ---------------------------------------------
// Tie off unused outputs
// ---------------------------------------------
assign axs_bvalid                      = 1'b0;

// ---------------------------------------------
// Convert AXI bus signalling to Avalon bus
// ---------------------------------------------

// Read data command
assign avm_rx_address                  = axs_araddr;
assign avm_rx_burstcount               = {3'h0, {1'b0, axs_arlen} + 9'h01};
assign avm_rx_read                     = axs_arvalid;
assign axs_arready                     = ~avm_rx_waitrequest;

// Read data
assign axs_rdata                       = avm_rx_readdata;
assign axs_rvalid                      = avm_rx_readdatavalid;

// Write data command
assign axs_awready                     = ~axs_wr_busy;
assign avm_tx_burstcount               = {3'h0, {1'b0, axs_awlen_held} + 9'h01};
assign avm_tx_address                  = axs_awaddr_held;

// Write data
assign axs_wready                      = ~avm_tx_waitrequest;
assign avm_tx_write                    = axs_wvalid;
assign avm_tx_writedata                = axs_wdata;

// ---------------------------------------------
// Process to align write command data for 
// Avalon protocols, and flag when bus is busy.
// ---------------------------------------------
always @(posedge clk `RESET)
begin
  if (reset_n == 1'b0)
  begin
    axs_wr_busy                        <= 1'b0;
  end
  else
  begin
    // Clear busy status when last write data comes past
    if (axs_wvalid & axs_wready & axs_wlast)
    begin
      axs_wr_busy                      <= 1'b0;
    end

    // On a write command, store address and length and set
    // the busy flag.
    if (axs_awvalid)
    begin
      axs_awlen_held                   <= axs_awlen;
      axs_awaddr_held                  <= axs_awaddr;
      axs_wr_busy                      <= 1'b1;
    end
  end
end

endmodule