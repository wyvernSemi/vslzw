# TCL File Generated by Component Editor 18.1
# Mon Feb 07 15:53:20 GMT 2022
# DO NOT MODIFY


# 
# core "core" v0.0
#  2022.02.07.15:53:20
# Top Level Verilog FPGA logic
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module core
# 
set_module_property DESCRIPTION "Top Level Verilog FPGA logic"
set_module_property NAME core
set_module_property VERSION 0.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME core
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL core
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file slzw_codec_auto.vh VERILOG_INCLUDE PATH ../../src/slzw_codec_auto.vh
add_fileset_file slzw_codec_csr_regs_auto.v VERILOG PATH ../../src/slzw_codec_csr_regs_auto.v
add_fileset_file slzw_lib.v VERILOG PATH ../../src/slzw_lib.v
add_fileset_file slzw_axi4_master.v VERILOG PATH ../../src/slzw_axi4_master.v
add_fileset_file slzw_dict.v VERILOG PATH ../../src/slzw_dict.v
add_fileset_file slzw_codec.v VERILOG PATH ../../src/slzw_codec.v
add_fileset_file core_auto.vh VERILOG_INCLUDE PATH core_auto.vh
add_fileset_file core_csr_decode_auto.v VERILOG PATH core_csr_decode_auto.v
add_fileset_file core_csr_regs_auto.v VERILOG PATH core_csr_regs_auto.v
add_fileset_file core.v VERILOG PATH core.v TOP_LEVEL_FILE


# 
# parameters
# 
add_parameter CLK_FREQ_MHZ INTEGER 100 "Must match pll_0's outclk0 frequency"
set_parameter_property CLK_FREQ_MHZ DEFAULT_VALUE 100
set_parameter_property CLK_FREQ_MHZ DISPLAY_NAME CLK_FREQ_MHZ
set_parameter_property CLK_FREQ_MHZ TYPE INTEGER
set_parameter_property CLK_FREQ_MHZ UNITS None
set_parameter_property CLK_FREQ_MHZ ALLOWED_RANGES -2147483648:2147483647
set_parameter_property CLK_FREQ_MHZ DESCRIPTION "Must match pll_0's outclk0 frequency"
set_parameter_property CLK_FREQ_MHZ HDL_PARAMETER true
add_parameter MEMSIZE INTEGER 10240
set_parameter_property MEMSIZE DEFAULT_VALUE 10240
set_parameter_property MEMSIZE DISPLAY_NAME MEMSIZE
set_parameter_property MEMSIZE TYPE INTEGER
set_parameter_property MEMSIZE UNITS None
set_parameter_property MEMSIZE HDL_PARAMETER true
add_parameter ARUSER STD_LOGIC_VECTOR 1
set_parameter_property ARUSER DEFAULT_VALUE 1
set_parameter_property ARUSER DISPLAY_NAME ARUSER
set_parameter_property ARUSER TYPE STD_LOGIC_VECTOR
set_parameter_property ARUSER UNITS None
set_parameter_property ARUSER ALLOWED_RANGES 0:3
set_parameter_property ARUSER HDL_PARAMETER true
add_parameter ARCACHE STD_LOGIC_VECTOR 14
set_parameter_property ARCACHE DEFAULT_VALUE 14
set_parameter_property ARCACHE DISPLAY_NAME ARCACHE
set_parameter_property ARCACHE TYPE STD_LOGIC_VECTOR
set_parameter_property ARCACHE UNITS None
set_parameter_property ARCACHE ALLOWED_RANGES 0:31
set_parameter_property ARCACHE HDL_PARAMETER true


# 
# display items
# 
add_display_item "" VECTORS GROUP ""
add_display_item "" TIMING GROUP ""
add_display_item "" MEMORY GROUP ""
add_display_item "" EXTENSIONS GROUP ""
add_display_item "" TEST GROUP ""


# 
# connection point csr
# 
add_interface csr avalon end
set_interface_property csr addressUnits WORDS
set_interface_property csr associatedClock clk
set_interface_property csr associatedReset reset
set_interface_property csr bitsPerSymbol 8
set_interface_property csr burstOnBurstBoundariesOnly false
set_interface_property csr burstcountUnits WORDS
set_interface_property csr explicitAddressSpan 0
set_interface_property csr holdTime 0
set_interface_property csr linewrapBursts false
set_interface_property csr maximumPendingReadTransactions 0
set_interface_property csr maximumPendingWriteTransactions 0
set_interface_property csr readLatency 0
set_interface_property csr readWaitTime 1
set_interface_property csr setupTime 0
set_interface_property csr timingUnits Cycles
set_interface_property csr writeWaitTime 0
set_interface_property csr ENABLED true
set_interface_property csr EXPORT_OF ""
set_interface_property csr PORT_NAME_MAP ""
set_interface_property csr CMSIS_SVD_VARIABLES ""
set_interface_property csr SVD_ADDRESS_GROUP ""

add_interface_port csr avs_csr_address address Input 18
add_interface_port csr avs_csr_write write Input 1
add_interface_port csr avs_csr_writedata writedata Input 32
add_interface_port csr avs_csr_read read Input 1
add_interface_port csr avs_csr_readdata readdata Output 32
set_interface_assignment csr embeddedsw.configuration.isFlash 0
set_interface_assignment csr embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment csr embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment csr embeddedsw.configuration.isPrintableDevice 0


# 
# connection point clk
# 
add_interface clk clock end
set_interface_property clk clockRate 100000000
set_interface_property clk ENABLED true
set_interface_property clk EXPORT_OF ""
set_interface_property clk PORT_NAME_MAP ""
set_interface_property clk CMSIS_SVD_VARIABLES ""
set_interface_property clk SVD_ADDRESS_GROUP ""

add_interface_port clk clk clk Input 1


# 
# connection point reset
# 
add_interface reset reset end
set_interface_property reset associatedClock clk
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""

add_interface_port reset reset_n reset_n Input 1


# 
# connection point clk_x2
# 
add_interface clk_x2 clock end
set_interface_property clk_x2 clockRate 200000000
set_interface_property clk_x2 ENABLED true
set_interface_property clk_x2 EXPORT_OF ""
set_interface_property clk_x2 PORT_NAME_MAP ""
set_interface_property clk_x2 CMSIS_SVD_VARIABLES ""
set_interface_property clk_x2 SVD_ADDRESS_GROUP ""

add_interface_port clk_x2 clk_x2 clk Input 1


# 
# connection point clk_div2
# 
add_interface clk_div2 clock end
set_interface_property clk_div2 clockRate 50000000
set_interface_property clk_div2 ENABLED true
set_interface_property clk_div2 EXPORT_OF ""
set_interface_property clk_div2 PORT_NAME_MAP ""
set_interface_property clk_div2 CMSIS_SVD_VARIABLES ""
set_interface_property clk_div2 SVD_ADDRESS_GROUP ""

add_interface_port clk_div2 clk_div2 clk Input 1


# 
# connection point hdmi
# 
add_interface hdmi conduit end
set_interface_property hdmi associatedClock clk
set_interface_property hdmi associatedReset reset
set_interface_property hdmi ENABLED true
set_interface_property hdmi EXPORT_OF ""
set_interface_property hdmi PORT_NAME_MAP ""
set_interface_property hdmi CMSIS_SVD_VARIABLES ""
set_interface_property hdmi SVD_ADDRESS_GROUP ""

add_interface_port hdmi hdmi_i2c_sda_in sda_in Input 1
add_interface_port hdmi hdmi_i2c_sda_out sda_out Output 1
add_interface_port hdmi hdmi_i2c_sda_oe sda_oe Output 1
add_interface_port hdmi hdmi_i2c_scl i2c_scl Output 1
add_interface_port hdmi hdmi_i2s i2s Output 1
add_interface_port hdmi hdmi_lrclk lrck Output 1
add_interface_port hdmi hdmi_mclk mclk Output 1
add_interface_port hdmi hdmi_sclk sclk Output 1
add_interface_port hdmi hdmi_tx_clk tx_clk Output 1
add_interface_port hdmi hdmi_tx_d tx_d Output 24
add_interface_port hdmi hdmi_tx_de tx_de Output 1
add_interface_port hdmi hdmi_tx_hs tx_hs Output 1
add_interface_port hdmi hdmi_tx_vs tx_vs Output 1
add_interface_port hdmi hdmi_tx_int tx_int Input 1


# 
# connection point adc
# 
add_interface adc conduit end
set_interface_property adc associatedClock clk
set_interface_property adc associatedReset reset
set_interface_property adc ENABLED true
set_interface_property adc EXPORT_OF ""
set_interface_property adc PORT_NAME_MAP ""
set_interface_property adc CMSIS_SVD_VARIABLES ""
set_interface_property adc SVD_ADDRESS_GROUP ""

add_interface_port adc adc_convst convst Output 1
add_interface_port adc adc_sck sck Output 1
add_interface_port adc adc_sdo sdo Input 1
add_interface_port adc adc_sdi sdi Output 1


# 
# connection point arduino
# 
add_interface arduino conduit end
set_interface_property arduino associatedClock clk
set_interface_property arduino associatedReset reset
set_interface_property arduino ENABLED true
set_interface_property arduino EXPORT_OF ""
set_interface_property arduino PORT_NAME_MAP ""
set_interface_property arduino CMSIS_SVD_VARIABLES ""
set_interface_property arduino SVD_ADDRESS_GROUP ""

add_interface_port arduino arduino_io_out io_out Output 16
add_interface_port arduino arduino_io_oe io_oe Output 16
add_interface_port arduino arduino_io_in io_in Input 16
add_interface_port arduino arduino_reset_n reset_n Input 1


# 
# connection point gpio
# 
add_interface gpio conduit end
set_interface_property gpio associatedClock clk
set_interface_property gpio associatedReset reset
set_interface_property gpio ENABLED true
set_interface_property gpio EXPORT_OF ""
set_interface_property gpio PORT_NAME_MAP ""
set_interface_property gpio CMSIS_SVD_VARIABLES ""
set_interface_property gpio SVD_ADDRESS_GROUP ""

add_interface_port gpio gpio_in in Input 72
add_interface_port gpio gpio_out out Output 72
add_interface_port gpio gpio_oe oe Output 72


# 
# connection point key
# 
add_interface key conduit end
set_interface_property key associatedClock clk
set_interface_property key associatedReset reset
set_interface_property key ENABLED true
set_interface_property key EXPORT_OF ""
set_interface_property key PORT_NAME_MAP ""
set_interface_property key CMSIS_SVD_VARIABLES ""
set_interface_property key SVD_ADDRESS_GROUP ""

add_interface_port key key in Input 2


# 
# connection point led
# 
add_interface led conduit end
set_interface_property led associatedClock clk
set_interface_property led associatedReset reset
set_interface_property led ENABLED true
set_interface_property led EXPORT_OF ""
set_interface_property led PORT_NAME_MAP ""
set_interface_property led CMSIS_SVD_VARIABLES ""
set_interface_property led SVD_ADDRESS_GROUP ""

add_interface_port led led out Output 8


# 
# connection point sw
# 
add_interface sw conduit end
set_interface_property sw associatedClock clk
set_interface_property sw associatedReset reset
set_interface_property sw ENABLED true
set_interface_property sw EXPORT_OF ""
set_interface_property sw PORT_NAME_MAP ""
set_interface_property sw CMSIS_SVD_VARIABLES ""
set_interface_property sw SVD_ADDRESS_GROUP ""

add_interface_port sw sw in Input 4


# 
# connection point altera_axi4_master
# 
add_interface altera_axi4_master axi4 start
set_interface_property altera_axi4_master associatedClock clk
set_interface_property altera_axi4_master associatedReset reset
set_interface_property altera_axi4_master readIssuingCapability 1
set_interface_property altera_axi4_master writeIssuingCapability 1
set_interface_property altera_axi4_master combinedIssuingCapability 1
set_interface_property altera_axi4_master ENABLED true
set_interface_property altera_axi4_master EXPORT_OF ""
set_interface_property altera_axi4_master PORT_NAME_MAP ""
set_interface_property altera_axi4_master CMSIS_SVD_VARIABLES ""
set_interface_property altera_axi4_master SVD_ADDRESS_GROUP ""

add_interface_port altera_axi4_master axm_awaddr awaddr Output 32
add_interface_port altera_axi4_master axm_awlen awlen Output 8
add_interface_port altera_axi4_master axm_awprot awprot Output 3
add_interface_port altera_axi4_master axm_awvalid awvalid Output 1
add_interface_port altera_axi4_master axm_awready awready Input 1
add_interface_port altera_axi4_master axm_wdata wdata Output 32
add_interface_port altera_axi4_master axm_wlast wlast Output 1
add_interface_port altera_axi4_master axm_wvalid wvalid Output 1
add_interface_port altera_axi4_master axm_wready wready Input 1
add_interface_port altera_axi4_master axm_bvalid bvalid Input 1
add_interface_port altera_axi4_master axm_bready bready Output 1
add_interface_port altera_axi4_master axm_araddr araddr Output 32
add_interface_port altera_axi4_master axm_arlen arlen Output 8
add_interface_port altera_axi4_master axm_arcache arcache Output 4
add_interface_port altera_axi4_master axm_aruser aruser Output 1
add_interface_port altera_axi4_master axm_arprot arprot Output 3
add_interface_port altera_axi4_master axm_arvalid arvalid Output 1
add_interface_port altera_axi4_master axm_arready arready Input 1
add_interface_port altera_axi4_master axm_rdata rdata Input 32
add_interface_port altera_axi4_master axm_rvalid rvalid Input 1
add_interface_port altera_axi4_master axm_rready rready Output 1
