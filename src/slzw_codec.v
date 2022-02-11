// -----------------------------------------------------------------------------
//  Title      : Verilog SLZW codec top level module
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : slzwcodec.v
//  Author     : Simon Southwell
//  Created    : 2022-02-05
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This file contains the top level functionality for the SLZW codec
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

// =============================================================================
// Top level codec module
// =============================================================================

module slzw_codec
#(parameter
  MEMSIZE                      = 10240,
  ARUSER                       = 1'b1,    // If Cacheable accesses required, this must be 1
  ARCACHE                      = 4'b1110  // For cacheable accesses, bit 3 must be 1, and the rest a valid value as per A4.4 of AXI4 spec.
)
(
  input                        clk,
  input                        reset_n,

  // --- Avalon CSR slave interface --
  input  [3:0]                 avs_csr_address,
  input                        avs_csr_write,
  input  [31:0]                avs_csr_writedata,
  input                        avs_csr_read,
  output [31:0]                avs_csr_readdata,

  // --- AXI-4 bus ---

  // AXI write address bus.
  // Optional signals, unused: AWID, AWREGION, AWSIZE, AWBURST, AWLOCK, AWCACHE, AWQOS
  output [31:0]                axm_awaddr,
  output  [7:0]                axm_awlen,   // Optional. Default length 1 (AWLEN == 0)
  output  [2:0]                axm_awprot,
  output                       axm_awvalid,
  input                        axm_awready,

  // AXI write data bus.
  // Optional signals, unused: WSTRB
  output [31:0]                axm_wdata,
  output                       axm_wlast,
  output                       axm_wvalid,
  input                        axm_wready,

  // AXI write response bus.
  // Optional signals, unused: BID, BRESP
  input                        axm_bvalid,
  output                       axm_bready,

  // AXI read address bus.
  // Optional signals, unused: ARID, ARREGION, ARSIZE, ARBURST, ARLOCK, ARQOS
  output [31:0]                axm_araddr,
  output  [7:0]                axm_arlen,   // Optional. Default length 1 (ARLEN == 0)
  output  [3:0]                axm_arcache, // Optional. Used for cache coherency
  output                       axm_aruser,  // Optional. Used for cache coherency
  output  [2:0]                axm_arprot,
  output                       axm_arvalid,
  input                        axm_arready,

  // AXI read data bus.
  // Optional signals, unused: RID, RRSEP, RLAST
  input  [31:0]                axm_rdata,
  input                        axm_rvalid,
  output                       axm_rready

);

// -----------------------------------------------------------------------------
// Signalling
// -----------------------------------------------------------------------------

wire                           control_en_acp_win;
wire                           control_mode;
wire                           control_clr;
wire                           control_start;
wire                           control_disable_flush;

wire                           status_finished;

wire [31:0]                    rx_start_addr;
wire [31:0]                    rx_len;
wire [31:0]                    tx_start_addr;
wire [31:0]                    tx_len;
wire                           busy;

// -----------------------------------------------------------------------------
// TIE OFF signals
// -----------------------------------------------------------------------------

// STATUS
assign status_finished         = ~busy;

// Byte address values are word aligned
assign rx_start_addr[1:0]      = 2'b00;
assign tx_start_addr[1:0]      = 2'b00;

// -----------------------------------------------------------------------------
// Local CSR registers
// -----------------------------------------------------------------------------

  slzw_codec_csr_regs
  #(
    .ADDR_DECODE_WIDTH         (4)
  ) slzw_codec_csr_regs_i
  (
    .clk                       (clk),
    .rst_n                     (rst_n),

    .control_en_acp_win        (control_en_acp_win),
    .control_mode              (control_mode),
    .control_clr               (control_clr),
    .control_start             (control_start),
    .control_disable_flush     (control_disable_flush),

    .status_finished           (status_finished),

    .rx_start_addr_word        (rx_start_addr[31:2]),
    .rx_len                    (rx_len),
    .tx_start_addr_word        (tx_start_addr[31:2]),
    .tx_len                    (tx_len),

    .avs_address               (avs_csr_address[3:0]),
    .avs_write                 (avs_csr_write),
    .avs_writedata             (avs_csr_writedata),
    .avs_read                  (avs_csr_read),
    .avs_readdata              (avs_csr_readdata)
  );

// -----------------------------------------------------------------------------
// Dictionary
// -----------------------------------------------------------------------------

  slzw_dict
  #(
    .MEMSIZE                   (MEMSIZE)
  ) slzw_dict_i
  (
    .clk                       (clk),
    .reset_n                   (reset_n),

    // Dictionary clear control
    .clr                       (control_clr),

    // Mode
    .compress                  (control_mode),

    // Entry match port (compress)
    .match                     (1'b0),
    .match_code                (12'h000),
    .match_byte                (8'h00),
    .matched                   (),
    .matched_valid             (),

    // Build entry port (decompress)
    .build_entry               (1'b0),
    .build_code                (12'h000),
    .build_byte                (8'h00),

    // Read Port (decompress)
    .dict_decomp_ptr           (12'h000),
    .dict_code                 (),
    .dict_byte                 (),

    .op_code_len               ()

  );

// -----------------------------------------------------------------------------
// AXI Memory interface
// -----------------------------------------------------------------------------

  slzw_axi4_master 
  # (
    .USRPORTWIDTH              (8)
  )
  slzw_axi4_master_i
  (
    .aclk                      (clk),
    .aresetn                   (reset_n),
    
    // Control ports

    .clear                     (control_clr),
    .start                     (control_start),
    .busy                      (busy),

    .rx_start_addr             (rx_start_addr),
    .rx_len                    (rx_len),
    .tx_start_addr             (tx_start_addr),
    .tx_len                    (tx_len),

    // User application ports
    .user_read_byte            (1'b1),
    .user_read_data            (),
    .user_read_data_valid      (),

    .user_write_byte           (1'b0),
    .user_write_data           (8'h00),
    .user_write_ready          (),

    // --- AXI-4 bus ---
    .awaddr                    (axm_awaddr),
    .awlen                     (axm_awlen),
    .awprot                    (axm_awprot),
    .awvalid                   (axm_awvalid),
    .awready                   (axm_awready),
    .wdata                     (axm_wdata),
    .wlast                     (axm_wlast),
    .wvalid                    (axm_wvalid),
    .wready                    (axm_wready),
    .bvalid                    (axm_bvalid),
    .bready                    (axm_bready),
    .araddr                    (axm_araddr),
    .arlen                     (axm_arlen),
    .arcache                   (axm_arcache),
    .aruser                    (axm_aruser),
    .arprot                    (axm_arprot),
    .arvalid                   (axm_arvalid),
    .arready                   (axm_arready),
    .rdata                     (axm_rdata),
    .rvalid                    (axm_rvalid),
    .rready                    (axm_rready)
  );

endmodule