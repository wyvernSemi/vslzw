// -----------------------------------------------------------------------------
//  Title      : Main platform test code
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : main.cpp
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : C++11
// -----------------------------------------------------------------------------
//  Description:
//  This file has the top level code for platform test
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
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>

#include "../build/hps_0.h"
#include "fpga_support.h"
#include "elf.h"
#include "main.h"

// --------------------------------------------------
// DEFINES
// --------------------------------------------------

// --------------------------------------------------
// STATIC VARIABLES
// --------------------------------------------------

static volatile uint32_t *pImem       = NULL;

// --------------------------------------------------
// External memory write function for ELF loading code
// --------------------------------------------------

void  write_mem(uint32_t addr, uint32_t word, uint32_t type, bool &access_fault)
{
    pImem[addr/4] = word;
}

// ==================================================
// MIAN FUNCTION
// ==================================================

int main(int argc, char** argv)
{
    const uint32_t sdrCtrlFpgaPortRstWordOffset   = 0x20;
    fpgaSupport    fpga;
    int            error                          = 0;
    bool           scall                          = false;

    printf("\n**********************************\n");
    printf(  "*     Wyvern Semiconductors      *\n");
    printf(  "*   de10-nano (ARM Cortex-A9)    *\n");
    printf(  "*      Copyright (c) 2022        *\n");
    printf(  "**********************************\n\n");
    
    if (argc > 1)
    {
        if (strcmp(argv[1], "-s") == 0)
        {
            scall = true;
        }
    }

    usleep(1);

    // Reset the FPGA
    fpga.fullResetFpga();

    // Get the virtual base address of the lightweight bus that the CSR bus is accessed from
    void*     fpgaBaseAddr = fpga.getFpgaVirtualBaseAddress();

    // Point to the CSR registers
    uint32_t* coreBaseAddr = (uint32_t*)((uint32_t)fpgaBaseAddr + CORE_0_BASE);

    // Get a virtual address of the base of the Cyclone V sdr registers
    volatile uint32_t* sdramCtrlRegBase = (uint32_t*)fpga.getSdrCtrlVirtualBaseAddress();

    // Bring out of reset SDRAM controller ports 0 and 1 for read write and control
    sdramCtrlRegBase[sdrCtrlFpgaPortRstWordOffset] = 0x3fff;

    // ---------------------------

    CCoreAuto* pCore = new CCoreAuto(coreBaseAddr);

    // Set up control register for test
    pCore->pControl->SetHaltOnAddr(scall  ? 1 : 0);
    pCore->pControl->SetHaltOnUnimp(scall ? 1 : 0);
    pCore->pControl->SetHaltOnEcall(scall ? 0 : 1);
    pCore->pHaltAddr->SetHaltAddr(0x00000040);

    // Get the base address of IMEM (in the CSR register space)
    pImem = (uint32_t*)((uint8_t*)coreBaseAddr + CSR_CORE_IMEM);

    // Load the test code to memory
    read_elf("test.exe");

    // Bring the core out of reset
    pCore->pControl->SetClrHalt(1);

    // Wait for halt status
    int32_t  timeout = 10000;
    while(!pCore->pStatus->GetHalted() && timeout != 0)
    {
        timeout--;
        usleep(1);
    }

    // If reached timeout, flag as an error
    if (timeout == 0)
    {
        uint32_t gp = pCore->pGp->GetGp();
        
        printf("Test timed out (gp = 0x%08x): ***FAIL***\n", gp);
        
        error = 2;
    }
    else
    {
        // Get test status (value of GP register)
        uint32_t gp = pCore->pGp->GetGp();

        // Check for PASS/FAIL. Bottom bit should be set. Test number of failure 
        // in bits 31:1. A test number of 0 is a pass.
        if (gp == 1)
        {
            printf("Test exit code = %d : PASS\n", gp >> 1);
        }
        else
        {
            printf("Test exit code = %d : ***FAIL***\n", gp);
            error = 1;
        }
    }

    // ---------------------------

    // Wait a bit
    usleep(1);

    // Communicate the exit status
    printf("\nmain() finishing with status %d\n\n", error);

    return(error);

}

