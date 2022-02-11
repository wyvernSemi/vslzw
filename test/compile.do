# Compile the code into the appropriate libraries
file delete -force -- work
vlib work
vlog -quiet -f files_core_vlog_auto.tcl      -work work
vlog -quiet -f files.tcl                     -work work
