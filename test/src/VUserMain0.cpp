// -----------------------------------------------------------------------------
//  Title      : VProc node 0 main entry point code
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : VUserMain0.cpp
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : C++11
// -----------------------------------------------------------------------------
//  Description:
//  This file contains the code for the node 0 VProc main entry point
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

// --------------------------------------------------
// INCLUDES
// --------------------------------------------------
#include <string.h>

#include "VUserMain0.h"
#include "tests.h"
#include "utils.h"
#include "tb.h"
#include "hal/CTestAuto.h"
#include "hal/CCoreAuto.h"
//#include "../../build/hps_0.h"

// Access to memory model's direct API (C linkage)
extern "C" {
#include "mem_model.h"
}

#ifndef CORE_0_BASE
#define CORE_0_BASE 0
#endif

//######################################################
//# Add test code includes here
//######################################################

//#define DEBUG

// --------------------------------------------------
// DEFINES
// --------------------------------------------------

#define MAINTESTNUM            0
#define ALIVE_TEST_NUM         0x12345678
#define ALIVE_TEST_OFFSET      0x1000
#define ALIVE_TEST_NUM1        0xface900d

// --------------------------------------------------
// STATIC VARIABLES
// --------------------------------------------------
// I'm node 0
static int node           = 0;


// This must match the test bench system clock period to get accurate sleep times in the software.
static int sysClkPeriodPs = 10000;

// --------------------------------------------------
// Hooks for auto-generated HAL
// --------------------------------------------------

uint32_t read_ext (uint32_t addr, uint32_t* data)
{
    return csrReadMem(addr, data);
}

void write_ext (uint32_t addr, uint32_t data)
{
    csrWriteMem(addr, data);
}

// --------------------------------------------------
// Read function to access memory over CSR bus
// --------------------------------------------------
uint32_t csrReadMem (uint32_t addr, uint32_t* data)
{
    uint32_t rdata;

    // Read over the AVS bus
    VRead(addr, &rdata, NORMAL_UPDATE, node);

    *data = rdata;

    // Model some access rate time
    VTick(AVS_ACCESS_LEN, node);

#ifdef DEBUG
    VPrint("csrReadMem : addr = 0x%08x data = 0x%08x\n", addr, *data); fflush(NULL);
#endif
    return 0;
}

// --------------------------------------------------
// Write function to access memory over CSR bus
// --------------------------------------------------
void csrWriteMem (uint32_t addr, uint32_t data)
{
#ifdef DEBUG
    VPrint("csrWriteMem : addr = 0x%08x data = 0x%08x\n", addr, data); fflush(NULL);
#endif

    // Write over the AVS bus for this node
    VWrite(addr, data, NORMAL_UPDATE, node);

    // Model some access rate time
    VTick(AVS_ACCESS_LEN, node);
}

// --------------------------------------------------
// Read function to access memory directly (bypass sim)
// --------------------------------------------------
uint32_t directReadMem (uint32_t addr, uint32_t* data)
{
    uint32_t rdata;

    *data = ReadRamWord(addr/4, true, node);

#ifdef DEBUG
    VPrint("directReadMem : addr = 0x%08x data = 0x%08x\n", addr, *data); fflush(NULL);
#endif
    return 0;
}

// --------------------------------------------------
// Write function to access memory directly (bypass sim)
// --------------------------------------------------
void directWriteMem (uint32_t addr, uint32_t data)
{
#ifdef DEBUG
    VPrint("directWriteMem : addr = 0x%08x data = 0x%08x\n", addr, data); fflush(NULL);
#endif

    WriteRamWord(addr/4, data, true, node);
}

// --------------------------------------------------
// Simulation control functions
// --------------------------------------------------

void stopSim(bool error)
{
    csrWriteMem(TB_SIM_CTRL_REG, TB_SIM_CTRL_STOP_MASK   | (error ? TB_SIM_CTRL_ERROR_MASK : 0));
}

void finishSim(int error)
{
    csrWriteMem(TB_SIM_CTRL_REG, TB_SIM_CTRL_FINISH_MASK | (error ? TB_SIM_CTRL_ERROR_MASK : 0));
}

void usleepSim(unsigned time)
{
    VTick((time * 1000 * 1000)/sysClkPeriodPs, node);
}

void nsleepSim(unsigned time)
{
    uint64_t time64 = time;

    // Make ticks a minimum of 1, and do rounding to nearest clock period
    uint32_t ticks = ((time64 * 1000) < (sysClkPeriodPs) ? 1 : (time64 * 1000 + sysClkPeriodPs/2)/sysClkPeriodPs);

    VTick(ticks, node);
}

// ==================================================
// ENTRY POINT TO USER CODE FROM VPROC
// ==================================================

extern "C" void VUserMain0()
{
    int      error   = 0;
    uint32_t tmp1    = 0;
    uint32_t tmp2    = 0;
    uint32_t tmp3    = 0;

    config_t cfg;

    CTestAuto* pTestBench = new CTestAuto((uint32_t*)(CORE_0_BASE));
    CCoreAuto* pCore      = new CCoreAuto(CORE_0_BASE);

    VPrint("\n*****************************\n");
    VPrint(  "*   Wyvern Semiconductors   *\n");
    VPrint(  "* Virtual Processor (VProc) *\n");
    VPrint(  "*    Copyright (c) 2022     *\n");
    VPrint(  "*****************************\n\n");

    VPrint("Entered VUserMain%d()\n\n", node);

    uint32_t clkFreqMHz     = pTestBench->pConfigClkFreq->GetConfigClkFreq();
             sysClkPeriodPs = 1000000/clkFreqMHz;

    // Parse arguments. As no argc and argv, pass in these as null, and it will look for
    // vusermain.cfg, which should have a single line with the command line options. If this
    // file doesn't exist, no parsing is done.
    parseArgs(0, NULL, cfg);

    usleepSim(1);

    // Write to a core register via the HAL
    pCore->pScratch->SetScratch(ALIVE_TEST_NUM1);

    // Check we're alive by writing to memory over CSR bus
    csrWriteMem(MEM_BASE_ADDR + ALIVE_TEST_OFFSET, ALIVE_TEST_NUM);

    // Read back over CSR bus
    csrReadMem (MEM_BASE_ADDR + ALIVE_TEST_OFFSET, &tmp1);

    // Read directly from memory model (bypassing simulation)
    directReadMem (MEM_BASE_ADDR + ALIVE_TEST_OFFSET, &tmp2);

    // Read back the core register via the HAL
    tmp3 = pCore->pScratch->GetScratch();

    if (tmp1 != ALIVE_TEST_NUM || tmp2 != ALIVE_TEST_NUM || tmp3 != ALIVE_TEST_NUM1)
    {
        VPrint("\nVUserMain%d() failed start up memory access check (%08x %08x %08x) \n\n", node, tmp1, tmp2, tmp3);
        error = 1;
    }
    // If start up check passed, run user test code
    else
    {
        tests* pTest = new tests();

        pTest->start(CORE_0_BASE, cfg, node);

    }

    // Wait a bit
    usleepSim(1);

    // Tell the simulator to finish
    VPrint("\nVUserMain%d() finishing with status %d\n\n", node, error);
    finishSim(error);

    // Sleep for ever, ticking. Don't exit or loop forever internally
    // (e.g. while (1);) as simulation will hang.
    SLEEP_FOREVER;
}

