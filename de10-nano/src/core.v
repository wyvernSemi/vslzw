// -----------------------------------------------------------------------------
//  Title      : Top level core logic
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : core.v
//  Author     : Simon Southwell
//  Created    : 2021-09-10
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This block defines the project specific core logic top level, as instantiated
//  in QSYS.
// -----------------------------------------------------------------------------
//  Copyright (c) 2021, 2022 Simon Southwell
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

module core
#(parameter
    CLK_FREQ_MHZ               = 100,
    MEMSIZE                    = 10240,
    ARUSER                     = 1'b1,    // If Cacheable accesses required, this must be 1
    ARCACHE                    = 4'b1110  // For cacheable accesses, bit 3 must be 1, and the rest a valid value as per A4.4 of AXI4 spec.
)
(
  input                        clk,
  input                        clk_x2,
  input                        clk_div2,
  input                        reset_n,
                               
  // ADC                       
  output                       adc_convst,
  output                       adc_sck,
  output                       adc_sdi,
  input                        adc_sdo,
                               
  // ARDUINO                   
  output [15:0]                arduino_io_out,
  output [15:0]                arduino_io_oe,
  input  [15:0]                arduino_io_in,
  input                        arduino_reset_n,
                               
  // HDMI                      
  input                        hdmi_i2c_sda_in,
  output                       hdmi_i2c_sda_out,
  output                       hdmi_i2c_sda_oe,
  output                       hdmi_i2c_scl,
  output                       hdmi_i2s,
  output                       hdmi_lrclk,
  output                       hdmi_mclk,
  output                       hdmi_sclk,
  output                       hdmi_tx_clk,
  output [23:0]                hdmi_tx_d,
  output                       hdmi_tx_de,
  output                       hdmi_tx_hs,
  output                       hdmi_tx_vs,
  input                        hdmi_tx_int,
                               
  // GPIO                      
  input  [71:0]                gpio_in,
  output [71:0]                gpio_out,
  output [71:0]                gpio_oe,
                               
  // Key                       
  input   [1:0]                key,
                               
  // LED                       
  output  [7:0]                led,
                               
  // Switch                    
  input   [3:0]                sw,
                               
  // Avalon CSR slave interface
  input  [17:0]                avs_csr_address,
  input                        avs_csr_write,
  input  [31:0]                avs_csr_writedata,
  input                        avs_csr_read,
  output [31:0]                avs_csr_readdata,
                               
  // --- AXI-4 bus ---         
                               
  // AXI write address bus     
  output [31:0]                axm_awaddr,
  output  [7:0]                axm_awlen,
  output  [2:0]                axm_awprot,
  output                       axm_awvalid,
  input                        axm_awready,
                               
  // AXI write data bus        
  output [31:0]                axm_wdata,
  output                       axm_wlast,
  output                       axm_wvalid,
  input                        axm_wready,
                               
  // AXI write response bus    
  input                        axm_bvalid,
  output                       axm_bready,
                               
  // AXI read address bus      
  output [31:0]                axm_araddr,
  output  [7:0]                axm_arlen,
  output  [3:0]                axm_arcache,
  output                       axm_aruser,
  output  [2:0]                axm_arprot,
  output                       axm_arvalid,
  input                        axm_arready,
                               
  // AXI read data bus         
  input  [31:0]                axm_rdata,
  input                        axm_rvalid,
  output                       axm_rready
);
// ---------------------------------------------------------
// Local parameters
// ---------------------------------------------------------

localparam MEM_BIT_WIDTH               = 32;

// ---------------------------------------------------------
// Signal declarations
// ---------------------------------------------------------

reg   [26:0] count;

// Register access signals
wire         local_write;
wire         local_read;
wire  [31:0] local_readdata;

wire         slzw_codec_write;
wire         slzw_codec_read;
wire  [31:0] slzw_codec_readdata;

// ---------------------------------------------------------
// Tie off unused signals and ports
// ---------------------------------------------------------

assign adc_convst              =  1'b0;
assign adc_sck                 =  1'b0;
assign adc_sdi                 =  1'b0;

assign arduino_io_out          = 16'h0;
assign arduino_io_oe           = 16'h0;

assign hdmi_i2c_sda_out        =  1'b0;
assign hdmi_i2c_sda_oe         =  1'b0;
assign hdmi_i2c_scl            =  1'b0;
assign hdmi_i2s                =  1'b0;
assign hdmi_lrclk              =  1'b0;
assign hdmi_mclk               =  1'b0;
assign hdmi_sclk               =  1'b0;
assign hdmi_tx_clk             =  1'b0;
assign hdmi_tx_d               = 23'h0;
assign hdmi_tx_de              =  1'b0;
assign hdmi_tx_hs              =  1'b0;
assign hdmi_tx_vs              =  1'b0;

assign gpio_out                = 72'h0;
assign gpio_oe                 = 72'h0;

// ---------------------------------------------------------
// Combinatorial Logic
// ---------------------------------------------------------

// Flash the LEDs to visually check programming
assign led                     = {6'h0, ~count[26], count[26]};

// ---------------------------------------------------------
// Local Synchronous Logic
// ---------------------------------------------------------

always @ (posedge clk)
begin
  if (~reset_n)
  begin
    count                      <= 0;
  end
  else
  begin
    count                      <= count + 27'd1;
  end
end

// ---------------------------------------------------------
// Address decode
// ---------------------------------------------------------

  core_csr_decode #(17, 15) core_csr_decode_inst
  (
    .avs_address               (avs_csr_address[17:15]),
    .avs_write                 (avs_csr_write),
    .avs_read                  (avs_csr_read),
    .avs_readdata              (avs_csr_readdata),

    .local_write               (local_write),
    .local_read                (local_read),
    .local_readdata            (local_readdata),

    .slzw_codec_write          (slzw_codec_write),
    .slzw_codec_read           (slzw_codec_read),
    .slzw_codec_readdata       (slzw_codec_readdata)

  );

// ---------------------------------------------------------
// Local control and status registers
// ---------------------------------------------------------

  core_csr_regs #(5) core_csr_regs_inst
  (
    .clk                       (clk),
    .rst_n                     (reset_n),

    .scratch                   (),
    .clk_freq_mhz              (CLK_FREQ_MHZ[9:0]),

    .avs_address               (avs_csr_address[4:0]),
    .avs_write                 (local_write),
    .avs_writedata             (avs_csr_writedata),
    .avs_read                  (local_read),
    .avs_readdata              (local_readdata)
  );

// ---------------------------------------------------------
// SLZW codec
// --------------------------------------------------------

  slzw_codec
  #(
    .MEMSIZE                     (MEMSIZE),
    .ARUSER                      (ARUSER),
    .ARCACHE                     (ARCACHE)
  ) slzw_codec_i
  (
    .clk                         (clk),
    .reset_n                     (reset_n),
  
    .avs_csr_address             (avs_csr_address[3:0]),
    .avs_csr_write               (slzw_codec_write),
    .avs_csr_writedata           (avs_csr_writedata),
    .avs_csr_read                (slzw_codec_read),
    .avs_csr_readdata            (slzw_codec_readdata),
  
    .axm_awaddr                  (axm_awaddr),
    .axm_awlen                   (axm_awlen),
    .axm_awprot                  (axm_awprot),
    .axm_awvalid                 (axm_awvalid),
    .axm_awready                 (axm_awready),
    .axm_wdata                   (axm_wdata),
    .axm_wlast                   (axm_wlast),
    .axm_wvalid                  (axm_wvalid),
    .axm_wready                  (axm_wready),
    .axm_bvalid                  (axm_bvalid),
    .axm_bready                  (axm_bready),
    .axm_araddr                  (axm_araddr),
    .axm_arlen                   (axm_arlen),
    .axm_arcache                 (axm_arcache),
    .axm_aruser                  (axm_aruser),
    .axm_arprot                  (axm_arprot),
    .axm_arvalid                 (axm_arvalid),
    .axm_arready                 (axm_arready),
    .axm_rdata                   (axm_rdata),
    .axm_rvalid                  (axm_rvalid),
    .axm_rready                  (axm_rready)
  );

endmodule