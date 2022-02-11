# Create clean libraries
foreach lib [list work] {
  file delete -force -- $lib
  vlib $lib
}

# Compile the code into the appropriate libraries
do compile.do

# Run the tests
# Get any command line argumens added to the .do file call
set vsimargs [lrange $argv 3 end]

# Run the tests
vsim -quiet -pli VProc.so -t 1ns -l sim.log -gGUI_RUN=1 tb

set StdArithNoWarnings   1
set NumericStdNoWarnings 1
do wave.do
#run -all
