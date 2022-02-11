###################################################################
# Makefile for vslzw tests in Modelsim
#
# Copyright (c) 2022 Simon Southwell
#
# This code is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# The code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this code. If not, see <http://www.gnu.org/licenses/>.
#
###################################################################

# User files to build, passed in to vproc makefile build
USERCODE           = VUserMain0.cpp            \
                     tests.cpp                 \
                     utils.cpp
                     
MEM_C              = mem.c mem_model.c

# Set up Variables for tools locations
MODELSIMDIR        = c:\altera\ver\modelsim_ase
VPROCDIR           = c:/git/VProc
MEMMODELDIR        = c:/git/mem_model/src

# Define where the synthesis directory is located
SYNTHDIR           = ../de10-nano

# Define where the HAL directory is for the auto-generated code
HALDIR             = ./src/hal

# Define the executables used in this makefile
MAKE_EXE           = mingw32-make
VSIMEXE            = ${MODELSIMDIR}\\win32aloem\\vsim
VSIMARGS           =
AUTOSCRIPT         = autogen.bat
CMDSHELL           = c:\Windows\System32\cmd.exe /c

# Pick single target files for two auto-generations---UUT and test.
# The core.h file is always presentfor the UUT, and the test package
# for the test bench
AUTOTGTFILE        = ${HALDIR}/core.h

# Files used in auto-generating core file lists for simulation.
# compile.do uses the generated Tcl files.
COREHWTCLFILE      = ${SYNTHDIR}/src/core_hw.tcl
COREVHDLTCLFILE    = files_core_auto.tcl
COREVLOGTCLFILE    = files_core_vlog_auto.tcl

# The list of JSON files used in auto-generating registers
JSONFILES          = doc/test.json \
                     ../doc/*.json \
                     ${SYNTHDIR}/doc/core.json

# If no external code directory (e.g. a HAL) set this to local source directory, else set to code directory
EXTINCLDIR         = ${CURDIR}/src

# Define some user C flags to choose Verilog memory model, indicate this is a simulation build
# and is a little endian system.
USRFLAGS           = -I${MEMMODELDIR} -DINCL_VLOG_MEM_MODEL -DHDL_SIM -DMEM_MODEL_DEFAULT_ENDIAN=1

#------------------------------------------------------
# BUILD RULES
#------------------------------------------------------

# Build is dependant on building the auto-generated files,
# and processing makefile in vproc
all: ${AUTOTGTFILE} ${COREVHDLTCLFILE} ${COREVLOGTCLFILE} vproc

# Make UUT auto-gen code dependant on all the JSON files to
# call the batch file if any have changed
${AUTOTGTFILE}: ${JSONFILES}
	${CMDSHELL} ${AUTOSCRIPT}

# Generate the local list of VHDL core files from the QSYS core tcl file
${COREVHDLTCLFILE}: ${COREHWTCLFILE}
	@awk '/^#/{next}/VHDL/{print "../de10-nano/src/" $$5}' $< > $@

# Generate the local list of Verilog core files from the QSYS core tcl file
${COREVLOGTCLFILE}: ${COREHWTCLFILE}
	@awk '/^#/{next}/VERILOG/{print "../de10-nano/src/" $$5}' $< > $@

# Call the vproc make file for it to determine if anything
# needs building.
.PHONY : vproc
vproc:
	@${MAKE_EXE} -C ${VPROCDIR}               \
                 TESTDIR=${CURDIR}            \
                 USER_C="${USERCODE}"         \
                 USRCDIR="${CURDIR}/src"      \
                 USER_INCL="${AUTOTGTFILE}"   \
                 USRFLAGS="${USRFLAGS}"       \
                 MEM_C="${MEM_C}"             \
                 MEMMODELDIR="${MEMMODELDIR}" \
                 MODELSIMDIR="${MODELSIMDIR}" \
                 EXTINCLDIR="${EXTINCLDIR}"   \
                 HALCOPTS="${HALCOPTS}"

#------------------------------------------------------
# EXECUTION RULES
#------------------------------------------------------

run: all
	@${VSIMEXE} -c -do sim.do ${VSIMARGS}

rungui: all
	@${VSIMEXE} -gui -do simg.do ${VSIMARGS}
    
runlog: all
	@awk -F" " '/add wave/{print "log " $$NF}' < wave.do > batch.do
	@${VSIMEXE} -c -do simlog.do ${VSIMARGS}

compile: ${COREVHDLTCLFILE} ${COREVLOGTCLFILE}
	@${VSIMEXE} -c -do compile.do -do quit

waves:
	@${VSIMEXE} -view vsim.wlf -do wave.do
    
autobuild:
	@${CMDSHELL} ${AUTOSCRIPT}

gui: rungui

sim: run

log: runlog

help:
	@echo "mingw32-make               Build C/C++ code without running simulation"
	@echo "mingw32-make compile       Build HDL code without running simulation"
	@echo "mingw32-make autobuild     Build auto-generated code without running simulation"
	@echo "mingw32-make run/sim       Build and run batch simulation"
	@echo "mingw32-make rungui/gui    Build and run GUI simulation"
	@echo "mingw32-make runlog/log    Build and run batch simulation with signal logging"
	@echo "mingw32-make waves         Run wave view in free starter ModelSim (to view runlog/runfree signals)"
	@echo "mingw32-make help          Display this message"

#------------------------------------------------------
# CLEANING RULES
#------------------------------------------------------

clean:
	@${MAKE_EXE} -C ${VPROCDIR} USER_C="${USERCODE}" TESTDIR="${CURDIR}" clean
	@vsim -c -do cleanvlib.do -do quit
	@rm -rf *wlf*
	@rm -rf work
	@rm -rf obj
	@rm -rf batch.do
	@rm -rf transcript
	@rm -rf ${HALDIR}/*
	@rm -rf doc/*.htm
	@rm -rf *_auto.v*
	@rm -rf *_auto.tcl*
	@rm -rf *.log
	@rm -rf ${SYNTHDIR}/src/*_auto.v
	@rm -rf ${SYNTHDIR}/doc/*.htm
