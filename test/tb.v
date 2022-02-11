// -----------------------------------------------------------------------------
//  Title      : Core directed test bench top level
// -----------------------------------------------------------------------------
//  File       : tb.v
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This block is the top level test bench for the vslzw core component
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

module tb
#(parameter
    GUI_RUN                            = 0,
    CLK_FREQ_MHZ                       = 100,
    SLZW_MEMSIZE                       = 10240,
    EN_MEM_MODEL_RD_Q                  = 1,
    ARUSER                             = 1'b1,    // If Cacheable accesses required, this must be 1
    ARCACHE                            = 4'b1110  // For cacheable accesses, bit 3 must be 1, and the rest a valid value as per A4.4 of AXI4 spec.
)
(/* no ports */);

// ---------------------------------------------
// -- Signal declarations
// ---------------------------------------------

// Clock, reset and test bench control signals
wire                                   clk_x2;
wire                                   clk;
wire                                   clk_div2 ;
wire [31:0]                            count_vec;
wire [30:0]                            timeout;
wire                                   rst_n;

// Avalon control and status register slave bus signals
wire [31:0]                            avs_csr_address;
wire [31:0]                            avs_csr_writedata;
wire [31:0]                            avs_csr_readdata;
wire                                   avs_csr_write;
wire                                   avs_csr_read;

wire                                   avs_csr_write_uut;
wire                                   avs_csr_read_uut;
wire [31:0]                            avs_csr_readdata_uut;

wire                                   avs_csr_write_mem;
wire                                   avs_csr_read_mem;
wire [31:0]                            avs_csr_readdata_mem;

wire                                   avs_csr_write_tb;
wire                                   avs_csr_read_tb;
wire [31:0]                            avs_csr_readdata_tb;

// Avalon Master read interface from memory model
wire                                   avm_rx_waitrequest;
wire [11:0]                            avm_rx_burstcount;
wire [31:0]                            avm_rx_address;
wire                                   avm_rx_read;
wire [31:0]                            avm_rx_readdata;
wire                                   avm_rx_readdatavalid;

// Avalon Master write interface to memory model
wire                                   avm_tx_waitrequest;
wire [11:0]                            avm_tx_burstcount;
wire [31:0]                            avm_tx_address;
wire                                   avm_tx_write;
wire [31:0]                            avm_tx_writedata;

// AXI-4 bus signals
wire [31:0]                            axm_awaddr;
wire  [7:0]                            axm_awlen;
wire  [2:0]                            axm_awprot;
wire                                   axm_awvalid;
wire                                   axm_awready;
wire [31:0]                            axm_wdata;
wire                                   axm_wlast;
wire                                   axm_wvalid;
wire                                   axm_wready;
wire                                   axm_bvalid;
wire                                   axm_bready;
wire [31:0]                            axm_araddr;
wire  [7:0]                            axm_arlen;
wire  [3:0]                            axm_arcache;
wire                                   axm_aruser;
wire  [2:0]                            axm_arprot;
wire                                   axm_arvalid;
wire                                   axm_arready;
wire [31:0]                            axm_rdata;
wire                                   axm_rvalid;
wire                                   axm_rready;

// Memory model write port
wire                                   wr_valid;
wire [31:0]                            wr_data;
wire [31:0]                            wr_addr;

// Simuation control and status
wire                                   error;
wire                                   do_stop;
wire                                   do_finish;
wire                                   partial_test;
wire                                   passed;
wire                                   failed;

// ---------------------------------------------
//  Test bench control
// ---------------------------------------------

  tb_ctrl #(GUI_RUN, CLK_FREQ_MHZ) tb_ctrl_inst
  (
    // Clock and reset outputs
    .clk                               (clk),
    .clk_div2                          (clk_div2),
    .clk_x2                            (clk_x2),
    .rst_n                             (rst_n),

    .count_vec                         (count_vec),
    .timeout                           ({1'b0, timeout}),

    // Status and control inputs
    .error                             (error),
    .do_stop                           (do_stop),
    .do_finish                         (do_finish),
    .partial_test                      (partial_test),

    // Test condition flags (for inspection externally)
    .failed                            (failed),
    .passed                            (passed)

  );

// ---------------------------------------------
//  Test bench address decode (auto-gen)
// ---------------------------------------------

  test_csr_decode test_csr_decode_inst
  (
    .uut_write                         (avs_csr_write_uut),
    .uut_read                          (avs_csr_read_uut),
    .uut_readdata                      (avs_csr_readdata_uut),

    .local_write                       (avs_csr_write_tb),
    .local_read                        (avs_csr_read_tb),
    .local_readdata                    (avs_csr_readdata_tb),

    .memory_write                      (avs_csr_write_mem),
    .memory_read                       (avs_csr_read_mem),
    .memory_readdata                   (avs_csr_readdata_mem),

    .avs_address                       (avs_csr_address[28:24]),
    .avs_write                         (avs_csr_write),
    .avs_read                          (avs_csr_read),
    .avs_readdata                      (avs_csr_readdata)
  );

// ---------------------------------------------
//  Local test bench registers (auto-gen)
// ---------------------------------------------

  test_csr_regs #(5) test_csr_regs_inst
  (
    .clk                               (clk),
    .rst_n                             (rst_n),

    .control_error                     (error),
    .control_do_stop                   (do_stop),
    .control_do_finish                 (do_finish),
    .control_partial_test              (partial_test),

    .config_clk_freq                   (CLK_FREQ_MHZ[8:0]),

    .time_count                        (count_vec),
    .timeout                           (timeout),

    .avs_address                       (avs_csr_address[4:0]),
    .avs_write                         (avs_csr_write_tb),
    .avs_writedata                     (avs_csr_writedata),
    .avs_read                          (avs_csr_read_tb),
    .avs_readdata                      (avs_csr_readdata_tb)

 );

// ---------------------------------------------
//  Virtual processor with Avalon bus
// ---------------------------------------------

  avsvproc #(0, 1) avsproc_inst
  (
    .clk                               (clk),
    .rst_n                             (rst_n),

    // Avalon memory mapped master interface
    .avs_csr_address                   (avs_csr_address),
    .avs_csr_write                     (avs_csr_write),
    .avs_csr_writedata                 (avs_csr_writedata),
    .avs_csr_read                      (avs_csr_read),
    .avs_csr_readdata                  (avs_csr_readdata),
    .avs_csr_readdatavalid             (1'b0),

    .irq                               (1'b0)
  );


// ---------------------------------------------
//  Instantiation of memory model
// ---------------------------------------------

  mem_model
  #(
    .EN_READ_QUEUE                     (EN_MEM_MODEL_RD_Q)
  )
  mem_model_inst
  (
    .clk                               (clk),
    .rst_n                             (rst_n),

    .address                           (avs_csr_address),
    .write                             (avs_csr_write_mem),
    .writedata                         (avs_csr_writedata),
    .byteenable                        (4'hf),
    .read                              (avs_csr_read_mem),
    .readdata                          (avs_csr_readdata_mem),
    .readdatavalid                     (),

    .rx_waitrequest                    (avm_rx_waitrequest),
    .rx_burstcount                     (avm_rx_burstcount),
    .rx_address                        (avm_rx_address),
    .rx_read                           (avm_rx_read),
    .rx_readdata                       (avm_rx_readdata),
    .rx_readdatavalid                  (avm_rx_readdatavalid),

    .tx_waitrequest                    (avm_tx_waitrequest),
    .tx_burstcount                     (avm_tx_burstcount),
    .tx_address                        (avm_tx_address),
    .tx_write                          (avm_tx_write),
    .tx_writedata                      (avm_tx_writedata),

    .wr_port_valid                     (wr_valid),
    .wr_port_data                      (wr_data),
    .wr_port_addr                      (wr_addr)

  );

// ---------------------------------------------
// Convert AXI bus signalling to Avalon bus
// ---------------------------------------------

  axi_av_conv axi_av_conv_i
  (
    .aclk                              (clk),
    .aresetn                           (rst_n),

    // AXI4 slave interface
    .axs_awaddr                        (axm_awaddr),
    .axs_awlen                         (axm_awlen),
    .axs_awprot                        (axm_arprot),
    .axs_awvalid                       (axm_awvalid),
    .axs_awready                       (axm_awready),

    .axs_wdata                         (axm_wdata),
    .axs_wlast                         (axm_wlast),
    .axs_wvalid                        (axm_wvalid),
    .axs_wready                        (axm_wready),

    .axs_bvalid                        (axm_bvalid),
    .axs_bready                        (axm_bready),

    .axs_araddr                        (axm_araddr),
    .axs_arlen                         (axm_arlen),
    .axs_arcache                       (axm_arcache),
    .axs_aruser                        (axm_aruser),
    .axs_arprot                        (axm_arprot),
    .axs_arvalid                       (axm_arvalid),
    .axs_arready                       (axm_arready),

    .axs_rdata                         (axm_rdata),
    .axs_rvalid                        (axm_rvalid),
    .axs_rready                        (axm_rready),

    // Avalon read burst bus
    .avm_rx_waitrequest                (avm_rx_waitrequest),
    .avm_rx_burstcount                 (avm_rx_burstcount),
    .avm_rx_address                    (avm_rx_address),
    .avm_rx_read                       (avm_rx_read),
    .avm_rx_readdata                   (avm_rx_readdata),
    .avm_rx_readdatavalid              (avm_rx_readdatavalid),

    // Avalon read burst bus
    .avm_tx_waitrequest                (avm_tx_waitrequest),
    .avm_tx_burstcount                 (avm_tx_burstcount),
    .avm_tx_address                    (avm_tx_address),
    .avm_tx_write                      (avm_tx_write),
    .avm_tx_writedata                  (avm_tx_writedata)

  );

// ---------------------------------------------
//  Instantiation of UUT
// ---------------------------------------------

  core
  #(
    .CLK_FREQ_MHZ                      (CLK_FREQ_MHZ),
    .MEMSIZE                           (SLZW_MEMSIZE),
    .ARUSER                            (ARUSER),
    .ARCACHE                           (ARCACHE)
  ) core_inst
  (
    .clk                               (clk),
    .clk_x2                            (clk_x2),
    .clk_div2                          (clk_div2),
    .reset_n                           (rst_n),

    .adc_convst                        (),
    .adc_sck                           (),
    .adc_sdi                           (),
    .adc_sdo                           (1'b0),

    .arduino_io_in                     (16'h0),
    .arduino_io_out                    (),
    .arduino_io_oe                     (),
    .arduino_reset_n                   (1'b1),

    .hdmi_i2c_scl                      (),
    .hdmi_i2c_sda_in                   (1'b0),
    .hdmi_i2c_sda_out                  (),
    .hdmi_i2c_sda_oe                   (),
    .hdmi_i2s                          (),
    .hdmi_lrclk                        (),
    .hdmi_mclk                         (),
    .hdmi_sclk                         (),
    .hdmi_tx_clk                       (),
    .hdmi_tx_d                         (),
    .hdmi_tx_de                        (),
    .hdmi_tx_hs                        (),
    .hdmi_tx_int                       (1'b0),
    .hdmi_tx_vs                        (),

    .gpio_in                           (72'h0),
    .gpio_out                          (),
    .gpio_oe                           (),

    .key                               (2'h0),

    .led                               (),

    .sw                                (4'h0),

    .avs_csr_address                   (avs_csr_address[17:0]),
    .avs_csr_write                     (avs_csr_write_uut),
    .avs_csr_writedata                 (avs_csr_writedata),
    .avs_csr_read                      (avs_csr_read_uut),
    .avs_csr_readdata                  (avs_csr_readdata_uut),

    .axm_awaddr                        (axm_awaddr),
    .axm_awlen                         (axm_awlen),
    .axm_awprot                        (axm_arprot), // Unused, no privilege levels
    .axm_awvalid                       (axm_awvalid),
    .axm_awready                       (axm_awready),

    .axm_wdata                         (axm_wdata),
    .axm_wlast                         (axm_wlast),
    .axm_wvalid                        (axm_wvalid),
    .axm_wready                        (axm_wready),

    .axm_bvalid                        (axm_bvalid),
    .axm_bready                        (axm_bready),

    .axm_araddr                        (axm_araddr),
    .axm_arlen                         (axm_arlen),
    .axm_arcache                       (axm_arcache), // Unused, no cache coherency issues
    .axm_aruser                        (axm_aruser),  // Unused, no cache coherency issues
    .axm_arprot                        (axm_arprot),  // Unused, no privilege levels
    .axm_arvalid                       (axm_arvalid),
    .axm_arready                       (axm_arready),

    .axm_rdata                         (axm_rdata),
    .axm_rvalid                        (axm_rvalid),
    .axm_rready                        (axm_rready)   // Unused, will always take (set to 1)

  );

endmodule
