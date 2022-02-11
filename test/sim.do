# Create clean libraries
foreach lib [list work] {
  file delete -force -- $lib
  vlib $lib
}

# Compile the code into the appropriate libraries
do compile.do

# Get any command line argumens added to the .do file call
set vsimargs [lrange $argv 3 end]

# Run the tests
vsim -quiet -pli VProc.so -t 1ns -l sim.log tb

run -all

#Exit the simulations
quit
