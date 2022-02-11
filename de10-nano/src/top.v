// -----------------------------------------------------------------------------
//  Title      : Top level Cylone V logic
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : core.v
//  Author     : Simon Southwell
//  Created    : 2021-09-10
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This block defines the project top level for Cyclone V device, instatiating
//  the top_system QSYS generated module, and wiring up to the pins.
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

`default_nettype none

module top (

  //////////// CLOCK //////////
  input                FPGA_CLK1_50,
  input                FPGA_CLK2_50,
  input                FPGA_CLK3_50,

  //////////// ADC //////////
  output               ADC_CONVST,
  output               ADC_SCK,
  output               ADC_SDI,
  input                ADC_SDO,

  //////////// ARDUINO //////////
  inout  [15:0]        ARDUINO_IO,
  inout                ARDUINO_RESET_N,

  //////////// HDMI //////////
  inout                HDMI_I2C_SCL,
  inout                HDMI_I2C_SDA,
  inout                HDMI_I2S,
  inout                HDMI_LRCLK,
  inout                HDMI_MCLK,
  inout                HDMI_SCLK,
  output               HDMI_TX_CLK,
  output [23:0]        HDMI_TX_D,
  output               HDMI_TX_DE,
  output               HDMI_TX_HS,
  input                HDMI_TX_INT,
  output               HDMI_TX_VS,

  //////////// HPS //////////
  output [14:0]        HPS_DDR3_ADDR,
  output  [2:0]        HPS_DDR3_BA,
  output               HPS_DDR3_CAS_N,
  output               HPS_DDR3_CK_N,
  output               HPS_DDR3_CK_P,
  output               HPS_DDR3_CKE,
  output               HPS_DDR3_CS_N,
  output  [3:0]        HPS_DDR3_DM,
  inout  [31:0]        HPS_DDR3_DQ,
  inout   [3:0]        HPS_DDR3_DQS_N,
  inout   [3:0]        HPS_DDR3_DQS_P,
  output               HPS_DDR3_ODT,
  output               HPS_DDR3_RAS_N,
  output               HPS_DDR3_RESET_N,
  input                HPS_DDR3_RZQ,
  output               HPS_DDR3_WE_N,

  output               HPS_ENET_GTX_CLK,
  inout                HPS_ENET_INT_N,
  output               HPS_ENET_MDC,
  inout                HPS_ENET_MDIO,
  input                HPS_ENET_RX_CLK,
  input   [3:0]        HPS_ENET_RX_DATA,
  input                HPS_ENET_RX_DV,
  output  [3:0]        HPS_ENET_TX_DATA,
  output               HPS_ENET_TX_EN,

  inout                HPS_GSENSOR_INT,

  inout                HPS_I2C0_SCLK,
  inout                HPS_I2C0_SDAT,
  inout                HPS_I2C1_SCLK,
  inout                HPS_I2C1_SDAT,

  inout                HPS_KEY,
  inout                HPS_LED,
  inout                HPS_LTC_GPIO,

  output               HPS_SD_CLK,
  inout                HPS_SD_CMD,
  inout   [3:0]        HPS_SD_DATA,

  output               HPS_SPIM_CLK,
  input                HPS_SPIM_MISO,
  output               HPS_SPIM_MOSI,
  inout                HPS_SPIM_SS,

  input                HPS_UART_RX,
  output               HPS_UART_TX,

  inout                HPS_CONV_USB_N,
  input                HPS_USB_CLKOUT,
  inout   [7:0]        HPS_USB_DATA,
  input                HPS_USB_DIR,
  input                HPS_USB_NXT,
  output               HPS_USB_STP,

  //////////// KEY //////////
  input   [1:0]        KEY,

  //////////// LED //////////
  output  [7:0]        LED,

  //////////// SW //////////
  input   [3:0]        SW,

  //////////// GPIO_0 //////////
  inout  [35:0]        GPIO_0,

  //////////// GPIO_1 //////////
  inout  [35:0]        GPIO_1
);

// ------------------------------------------------------
//  REG/WIRE declarations
// ------------------------------------------------------

wire                   hps_fpga_reset_n;
wire  [1:0]            fpga_debounced_buttons;
wire  [2:0]            hps_reset_req;
wire                   hps_cold_reset;
wire                   hps_warm_reset;
wire                   hps_debug_reset;
wire [27:0]            stm_hw_events;

wire                   hdmi_i2c_sda_out;
wire                   hdmi_i2c_sda_oe;

wire [15:0]            arduino_io_out;
wire [15:0]            arduino_io_oe;

wire [71:0]            gpio_out;
wire [71:0]            gpio_oe;

// ------------------------------------------------------
// Local logic
// ------------------------------------------------------

// connection of internal logics
assign stm_hw_events   = {{15{1'b0}}, SW, 7'h0, fpga_debounced_buttons};
assign HDMI_I2C_SDA    = hdmi_i2c_sda_oe ? hdmi_i2c_sda_out : 1'bZ;

genvar i;
generate
  for(i = 0; i < 16; i = i + 1)
  begin  : ard_gen
    assign ARDUINO_IO[i] = arduino_io_out[i] ? arduino_io_oe[i] : 1'bZ;
  end
endgenerate

generate
  for(i = 0; i < 36; i = i + 1)
  begin  : gpio_gen
    assign GPIO_0[i]   = gpio_out[i]    ? gpio_oe[i]    : 1'bZ;
    assign GPIO_1[i]   = gpio_out[i+36] ? gpio_oe[i+36] : 1'bZ;
  end
endgenerate

// ------------------------------------------------------
//  Structural coding
// ------------------------------------------------------

top_system u0
(
  // Clock & Reset
  .clk_clk                               (FPGA_CLK1_50),

  .reset_reset_n                         (hps_fpga_reset_n),
  .hps_0_h2f_reset_reset_n               (hps_fpga_reset_n),
  .hps_0_f2h_cold_reset_req_reset_n      (~hps_cold_reset ),
  .hps_0_f2h_debug_reset_req_reset_n     (~hps_debug_reset),
  .hps_0_f2h_stm_hw_events_stm_hwevents  (stm_hw_events),
  .hps_0_f2h_warm_reset_req_reset_n      (~hps_warm_reset ),

  // HPS ddr3
  .memory_mem_a                          (HPS_DDR3_ADDR),
  .memory_mem_ba                         (HPS_DDR3_BA),
  .memory_mem_ck                         (HPS_DDR3_CK_P),
  .memory_mem_ck_n                       (HPS_DDR3_CK_N),
  .memory_mem_cke                        (HPS_DDR3_CKE),
  .memory_mem_cs_n                       (HPS_DDR3_CS_N),
  .memory_mem_ras_n                      (HPS_DDR3_RAS_N),
  .memory_mem_cas_n                      (HPS_DDR3_CAS_N),
  .memory_mem_we_n                       (HPS_DDR3_WE_N),
  .memory_mem_reset_n                    (HPS_DDR3_RESET_N),
  .memory_mem_dq                         (HPS_DDR3_DQ),
  .memory_mem_dqs                        (HPS_DDR3_DQS_P),
  .memory_mem_dqs_n                      (HPS_DDR3_DQS_N),
  .memory_mem_odt                        (HPS_DDR3_ODT),
  .memory_mem_dm                         (HPS_DDR3_DM),
  .memory_oct_rzqin                      (HPS_DDR3_RZQ),

  // HPS ethernet
  .hps_0_hps_io_hps_io_emac1_inst_TX_CLK (HPS_ENET_GTX_CLK),
  .hps_0_hps_io_hps_io_emac1_inst_TXD0   (HPS_ENET_TX_DATA[0]),
  .hps_0_hps_io_hps_io_emac1_inst_TXD1   (HPS_ENET_TX_DATA[1]),
  .hps_0_hps_io_hps_io_emac1_inst_TXD2   (HPS_ENET_TX_DATA[2]),
  .hps_0_hps_io_hps_io_emac1_inst_TXD3   (HPS_ENET_TX_DATA[3]),
  .hps_0_hps_io_hps_io_emac1_inst_RXD0   (HPS_ENET_RX_DATA[0]),
  .hps_0_hps_io_hps_io_emac1_inst_MDIO   (HPS_ENET_MDIO),
  .hps_0_hps_io_hps_io_emac1_inst_MDC    (HPS_ENET_MDC),
  .hps_0_hps_io_hps_io_emac1_inst_RX_CTL (HPS_ENET_RX_DV),
  .hps_0_hps_io_hps_io_emac1_inst_TX_CTL (HPS_ENET_TX_EN),
  .hps_0_hps_io_hps_io_emac1_inst_RX_CLK (HPS_ENET_RX_CLK),
  .hps_0_hps_io_hps_io_emac1_inst_RXD1   (HPS_ENET_RX_DATA[1]),
  .hps_0_hps_io_hps_io_emac1_inst_RXD2   (HPS_ENET_RX_DATA[2]),
  .hps_0_hps_io_hps_io_emac1_inst_RXD3   (HPS_ENET_RX_DATA[3]),

  // HPS SD card
  .hps_0_hps_io_hps_io_sdio_inst_CMD     (HPS_SD_CMD),
  .hps_0_hps_io_hps_io_sdio_inst_D0      (HPS_SD_DATA[0]),
  .hps_0_hps_io_hps_io_sdio_inst_D1      (HPS_SD_DATA[1]),
  .hps_0_hps_io_hps_io_sdio_inst_CLK     (HPS_SD_CLK),
  .hps_0_hps_io_hps_io_sdio_inst_D2      (HPS_SD_DATA[2]),
  .hps_0_hps_io_hps_io_sdio_inst_D3      (HPS_SD_DATA[3]),

  // HPS USB
  .hps_0_hps_io_hps_io_usb1_inst_D0      (HPS_USB_DATA[0]),
  .hps_0_hps_io_hps_io_usb1_inst_D1      (HPS_USB_DATA[1]),
  .hps_0_hps_io_hps_io_usb1_inst_D2      (HPS_USB_DATA[2]),
  .hps_0_hps_io_hps_io_usb1_inst_D3      (HPS_USB_DATA[3]),
  .hps_0_hps_io_hps_io_usb1_inst_D4      (HPS_USB_DATA[4]),
  .hps_0_hps_io_hps_io_usb1_inst_D5      (HPS_USB_DATA[5]),
  .hps_0_hps_io_hps_io_usb1_inst_D6      (HPS_USB_DATA[6]),
  .hps_0_hps_io_hps_io_usb1_inst_D7      (HPS_USB_DATA[7]),
  .hps_0_hps_io_hps_io_usb1_inst_CLK     (HPS_USB_CLKOUT),
  .hps_0_hps_io_hps_io_usb1_inst_STP     (HPS_USB_STP),
  .hps_0_hps_io_hps_io_usb1_inst_DIR     (HPS_USB_DIR),
  .hps_0_hps_io_hps_io_usb1_inst_NXT     (HPS_USB_NXT),

  // HPS SPI
  .hps_0_hps_io_hps_io_spim1_inst_CLK    (HPS_SPIM_CLK),
  .hps_0_hps_io_hps_io_spim1_inst_MOSI   (HPS_SPIM_MOSI),
  .hps_0_hps_io_hps_io_spim1_inst_MISO   (HPS_SPIM_MISO),
  .hps_0_hps_io_hps_io_spim1_inst_SS0    (HPS_SPIM_SS),

  // HPS UART
  .hps_0_hps_io_hps_io_uart0_inst_RX     (HPS_UART_RX),
  .hps_0_hps_io_hps_io_uart0_inst_TX     (HPS_UART_TX),

  // HPS I2C0
  .hps_0_hps_io_hps_io_i2c0_inst_SDA     (HPS_I2C0_SDAT),
  .hps_0_hps_io_hps_io_i2c0_inst_SCL     (HPS_I2C0_SCLK),

  // HPS I2C1
  .hps_0_hps_io_hps_io_i2c1_inst_SDA     (HPS_I2C1_SDAT),
  .hps_0_hps_io_hps_io_i2c1_inst_SCL     (HPS_I2C1_SCLK),

    //GPIO
  .hps_0_hps_io_hps_io_gpio_inst_GPIO09  (HPS_CONV_USB_N),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO35  (HPS_ENET_INT_N),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO40  (HPS_LTC_GPIO),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO53  (HPS_LED),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO54  (HPS_KEY),
  .hps_0_hps_io_hps_io_gpio_inst_GPIO61  (HPS_GSENSOR_INT),

  .hdmi_sda_in                           (HDMI_I2C_SDA),
  .hdmi_sda_out                          (hdmi_i2c_sda_out),
  .hdmi_sda_oe                           (hdmi_i2c_sda_oe),
  .hdmi_i2c_scl                          (HDMI_I2C_SCL),
  .hdmi_i2s                              (HDMI_I2S),
  .hdmi_lrck                             (HDMI_LRCLK),
  .hdmi_mclk                             (HDMI_MCLK),
  .hdmi_sclk                             (HDMI_SCLK),
  .hdmi_tx_clk                           (HDMI_TX_CLK),
  .hdmi_tx_d                             (HDMI_TX_D),
  .hdmi_tx_de                            (HDMI_TX_DE),
  .hdmi_tx_hs                            (HDMI_TX_HS),
  .hdmi_tx_vs                            (HDMI_TX_VS),
  .hdmi_tx_int                           (HDMI_TX_INT),

  .adc_convst                            (ADC_CONVST),
  .adc_sck                               (ADC_SCK),
  .adc_sdo                               (ADC_SDO),
  .adc_sdi                               (ADC_SDI),

  .arduino_io_out                        (arduino_io_out),
  .arduino_io_oe                         (arduino_io_oe),
  .arduino_io_in                         (ARDUINO_IO),
  .arduino_reset_n                       (ARDUINO_RESET_N),

  .gpio_in                               ({GPIO_1, GPIO_0}),
  .gpio_out                              (gpio_out),
  .gpio_oe                               (gpio_oe),

  .key_in                                (KEY),
  .led_out                               (LED),
  .sw_in                                 (SW),

   .debug_out_1_debug_out                ()
);

// Debounce logic to clean out glitches within 1ms
debounce debounce_inst
(
  .clk                                   (FPGA_CLK1_50),
  .reset_n                               (hps_fpga_reset_n),
  .data_in                               (KEY),
  .data_out                              (fpga_debounced_buttons)
);
  defparam debounce_inst.WIDTH                     = 2;
  defparam debounce_inst.POLARITY                  = "LOW";
  defparam debounce_inst.TIMEOUT                   = 50000;         // at 50Mhz this is a debounce time of 1ms
  defparam debounce_inst.TIMEOUT_WIDTH             = 16;            // ceil(log2(TIMEOUT))

// Source/Probe megawizard instance
hps_reset hps_reset_inst
(
  .source_clk                            (FPGA_CLK1_50),
  .source                                (hps_reset_req)
);

altera_edge_detector pulse_cold_reset
(
  .clk                                   (FPGA_CLK1_50),
  .rst_n                                 (hps_fpga_reset_n),
  .signal_in                             (hps_reset_req[0]),
  .pulse_out                             (hps_cold_reset)
);
  defparam pulse_cold_reset.PULSE_EXT              = 6;
  defparam pulse_cold_reset.EDGE_TYPE              = 1;
  defparam pulse_cold_reset.IGNORE_RST_WHILE_BUSY  = 1;

altera_edge_detector pulse_warm_reset
(
  .clk                                   (FPGA_CLK1_50),
  .rst_n                                 (hps_fpga_reset_n),
  .signal_in                             (hps_reset_req[1]),
  .pulse_out                             (hps_warm_reset)
);
  defparam pulse_warm_reset.PULSE_EXT              = 2;
  defparam pulse_warm_reset.EDGE_TYPE              = 1;
  defparam pulse_warm_reset.IGNORE_RST_WHILE_BUSY  = 1;

altera_edge_detector pulse_debug_reset
(
  .clk                                   (FPGA_CLK1_50),
  .rst_n                                 (hps_fpga_reset_n),
  .signal_in                             (hps_reset_req[2]),
  .pulse_out                             (hps_debug_reset)
);
  defparam pulse_debug_reset.PULSE_EXT             = 32;
  defparam pulse_debug_reset.EDGE_TYPE             = 1;
  defparam pulse_debug_reset.IGNORE_RST_WHILE_BUSY = 1;

endmodule
