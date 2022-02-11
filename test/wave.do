onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group tb /tb/CLK_FREQ_MHZ
add wave -noupdate -expand -group tb /tb/GUI_RUN
add wave -noupdate -expand -group tb /tb/clk
add wave -noupdate -expand -group tb /tb/rst_n
add wave -noupdate -expand -group tb /tb/do_finish
add wave -noupdate -expand -group tb /tb/do_stop
add wave -noupdate -expand -group tb /tb/error
add wave -noupdate -expand -group tb /tb/failed
add wave -noupdate -expand -group tb /tb/partial_test
add wave -noupdate -expand -group tb /tb/passed
add wave -noupdate -expand -group tb -radix unsigned /tb/timeout
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avs_csr_address
add wave -noupdate -expand -group tb /tb/avs_csr_read
add wave -noupdate -expand -group tb /tb/avs_csr_read_mem
add wave -noupdate -expand -group tb /tb/avs_csr_read_tb
add wave -noupdate -expand -group tb /tb/avs_csr_read_uut
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avs_csr_readdata
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avs_csr_readdata_mem
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avs_csr_readdata_tb
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avs_csr_readdata_uut
add wave -noupdate -expand -group tb /tb/avs_csr_write
add wave -noupdate -expand -group tb /tb/avs_csr_write_mem
add wave -noupdate -expand -group tb /tb/avs_csr_write_tb
add wave -noupdate -expand -group tb /tb/avs_csr_write_uut
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avs_csr_writedata
add wave -noupdate -expand -group tb /tb/avm_rx_read
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avm_rx_address
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avm_rx_burstcount
add wave -noupdate -expand -group tb /tb/avm_rx_waitrequest
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avm_rx_readdata
add wave -noupdate -expand -group tb /tb/avm_rx_readdatavalid
add wave -noupdate -expand -group tb /tb/avm_tx_address
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avm_tx_burstcount
add wave -noupdate -expand -group tb /tb/avm_tx_waitrequest
add wave -noupdate -expand -group tb /tb/avm_tx_write
add wave -noupdate -expand -group tb -radix hexadecimal /tb/avm_tx_writedata
add wave -noupdate -expand -group tb /tb/axm_arvalid
add wave -noupdate -expand -group tb -radix hexadecimal /tb/axm_araddr
add wave -noupdate -expand -group tb -radix unsigned /tb/axm_arlen
add wave -noupdate -expand -group tb /tb/axm_arcache
add wave -noupdate -expand -group tb /tb/axm_arprot
add wave -noupdate -expand -group tb /tb/axm_arready
add wave -noupdate -expand -group tb /tb/axm_aruser
add wave -noupdate -expand -group tb -radix hexadecimal /tb/axm_awaddr
add wave -noupdate -expand -group tb -radix unsigned /tb/axm_awlen
add wave -noupdate -expand -group tb /tb/axm_awprot
add wave -noupdate -expand -group tb /tb/axm_awready
add wave -noupdate -expand -group tb /tb/axm_awvalid
add wave -noupdate -expand -group tb /tb/axm_bready
add wave -noupdate -expand -group tb /tb/axm_bvalid
add wave -noupdate -expand -group tb /tb/axm_rvalid
add wave -noupdate -expand -group tb -radix hexadecimal /tb/axm_rdata
add wave -noupdate -expand -group tb /tb/axm_rready
add wave -noupdate -expand -group tb -radix hexadecimal /tb/axm_wdata
add wave -noupdate -expand -group tb /tb/axm_wlast
add wave -noupdate -expand -group tb /tb/axm_wready
add wave -noupdate -expand -group tb /tb/axm_wvalid
add wave -noupdate -expand -group tb -radix unsigned /tb/count_vec
add wave -noupdate -expand -group tb -radix hexadecimal /tb/wr_addr
add wave -noupdate -expand -group tb -radix hexadecimal /tb/wr_data
add wave -noupdate -expand -group tb /tb/wr_valid
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/aclk
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/aresetn
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/start
add wave -noupdate -group {axi master} -radix hexadecimal /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/araddr
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/arvalid
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/arcache
add wave -noupdate -group {axi master} -radix hexadecimal /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/arlen
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/arprot
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/arready
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/aruser
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/awaddr
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/awlen
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/awprot
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/awready
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/awvalid
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/bready
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/busy
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/bvalid
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/clear
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/clk
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/next_burst_size
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rvalid
add wave -noupdate -group {axi master} -radix hexadecimal /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rdata
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rbusy
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/remain_count_gt_burst
add wave -noupdate -group {axi master} -radix unsigned /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/remaining_word_count
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/reset_n
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rready
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_fifo_clr
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_fifo_count
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_fifo_data
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_fifo_rd
add wave -noupdate -group {axi master} -radix decimal /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_len
add wave -noupdate -group {axi master} -radix unsigned /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_len_int
add wave -noupdate -group {axi master} -radix unsigned /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_len_words
add wave -noupdate -group {axi master} -radix unsigned /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_outstanding_count
add wave -noupdate -group {axi master} -radix hexadecimal /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_start_addr
add wave -noupdate -group {axi master} -radix hexadecimal /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_start_addr_int
add wave -noupdate -group {axi master} -radix unsigned /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_words_to_boundary
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/RXFIFODEPTH
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/tx_len
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/tx_start_addr
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/user_rd_byte_count
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_empty
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/rx_full
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/user_read_byte
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/user_read_data
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/user_read_data_valid
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/user_write_byte
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/user_write_data
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/user_write_ready
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/wdata
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/wlast
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/wready
add wave -noupdate -group {axi master} /tb/core_inst/slzw_codec_i/slzw_axi4_master_i/wvalid
add wave -noupdate -group mem_model /tb/mem_model_inst/EN_READ_QUEUE
add wave -noupdate -group mem_model -radix hexadecimal /tb/mem_model_inst/address
add wave -noupdate -group mem_model /tb/mem_model_inst/byteenable
add wave -noupdate -group mem_model /tb/mem_model_inst/clk
add wave -noupdate -group mem_model /tb/mem_model_inst/q_full
add wave -noupdate -group mem_model -radix hexadecimal /tb/mem_model_inst/rd_addr
add wave -noupdate -group mem_model /tb/mem_model_inst/read
add wave -noupdate -group mem_model -radix hexadecimal /tb/mem_model_inst/readdata
add wave -noupdate -group mem_model -radix hexadecimal /tb/mem_model_inst/readdata_int
add wave -noupdate -group mem_model /tb/mem_model_inst/readdatavalid
add wave -noupdate -group mem_model /tb/mem_model_inst/rst_n
add wave -noupdate -group mem_model /tb/mem_model_inst/rx_address
add wave -noupdate -group mem_model -radix hexadecimal /tb/mem_model_inst/rx_address_q
add wave -noupdate -group mem_model -radix unsigned /tb/mem_model_inst/rx_burstcount_q
add wave -noupdate -group mem_model -radix unsigned /tb/mem_model_inst/rx_burstcount
add wave -noupdate -group mem_model -radix hexadecimal /tb/mem_model_inst/rx_count
add wave -noupdate -group mem_model /tb/mem_model_inst/rx_read
add wave -noupdate -group mem_model /tb/mem_model_inst/q_empty
add wave -noupdate -group mem_model /tb/mem_model_inst/rx_read_q
add wave -noupdate -group mem_model /tb/mem_model_inst/rx_waitrequest_int
add wave -noupdate -group mem_model -radix hexadecimal /tb/mem_model_inst/rx_readdata
add wave -noupdate -group mem_model -radix hexadecimal /tb/mem_model_inst/rx_readdata_int
add wave -noupdate -group mem_model /tb/mem_model_inst/rx_readdatavalid
add wave -noupdate -group mem_model /tb/mem_model_inst/rx_readdatavalid_int
add wave -noupdate -group mem_model /tb/mem_model_inst/rx_waitrequest
add wave -noupdate -group mem_model /tb/mem_model_inst/tx_address
add wave -noupdate -group mem_model /tb/mem_model_inst/tx_burstcount
add wave -noupdate -group mem_model /tb/mem_model_inst/tx_count
add wave -noupdate -group mem_model /tb/mem_model_inst/tx_waitrequest
add wave -noupdate -group mem_model /tb/mem_model_inst/tx_write
add wave -noupdate -group mem_model /tb/mem_model_inst/tx_writedata
add wave -noupdate -group mem_model /tb/mem_model_inst/wr_addr
add wave -noupdate -group mem_model /tb/mem_model_inst/wr_port_addr
add wave -noupdate -group mem_model /tb/mem_model_inst/wr_port_data
add wave -noupdate -group mem_model /tb/mem_model_inst/wr_port_valid
add wave -noupdate -group mem_model /tb/mem_model_inst/write
add wave -noupdate -group mem_model /tb/mem_model_inst/writedata
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/ARCACHE
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/ARUSER
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/MEMSIZE
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/avs_csr_address
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/avs_csr_read
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/avs_csr_readdata
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/avs_csr_write
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/avs_csr_writedata
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_araddr
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_arcache
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_arlen
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_arprot
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_arready
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_aruser
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_arvalid
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_awaddr
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_awlen
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_awprot
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_awready
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_awvalid
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_bready
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_bvalid
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_rdata
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_rready
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_rvalid
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_wdata
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_wlast
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_wready
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/axm_wvalid
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/busy
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/clk
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/control_clr
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/control_disable_flush
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/control_en_acp_win
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/control_mode
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/control_start
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/reset_n
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/rst_n
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/rx_len
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/rx_start_addr
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/status_finished
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/tx_len
add wave -noupdate -group slzw_codec /tb/core_inst/slzw_codec_i/tx_start_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {87924 ns} 0} {{Cursor 2} {996693 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 176
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {24639 ns}
