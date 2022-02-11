// -----------------------------------------------------------------------------
//  Title      : Tests class methods
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : tests.cpp
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : C++11
// -----------------------------------------------------------------------------
//  Description:
//  This file contains the code for the tests class methods
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

#include <string>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "tests.h"
#include "testsLocal.h"
#include "utils.h"

using namespace std;

#ifdef HDL_SIM
#include "VUserMain0.h"

// Memory model API has C linkage functions
extern "C" {
#include "mem_model.h"

}

static string dumpFileSuffix("_sim");

#else

#include <asm/unistd.h>
#include <sys/syscall.h>
#include <sys/mman.h>

// --------------------------------------------------
// DEFINES
// --------------------------------------------------


// --------------------------------------------------
// LOCAL STATICS
// --------------------------------------------------


#endif

// --------------------------------------------------
// Test code
// --------------------------------------------------
int tests::start(uint32_t* coreBaseAddr, config_t config, int node)
{
    int error = 0;

    CCoreAuto* pCore = new CCoreAuto(coreBaseAddr);

    // Get some configuration data from the core registers
    config.clkFreqMHz = pCore->pClkFreqMhz->GetClkFreqMhz();

    error |= codecTest(pCore, config, node);

    return error;
}


// --------------------------------------------------
// Test serialisation of real nozzle data and images
// --------------------------------------------------

int tests::codecTest (CCoreAuto*     pCore,
                        const config_t config,
                        int            node)
{

    int      error = 0;
    
    uint32_t start_addr = START_PHY_MEM + 104;

    // Fill in some test data in memory
    uint32_t addr = start_addr;
    for (int idx; idx < 1024; idx++, addr+=4)
    {
        WriteRamWord(addr, idx, 1, node);
    }

    // Set up RX config
    pCore->pSlzwCodec->pRxStartAddr->SetRxStartAddr(start_addr);
    pCore->pSlzwCodec->pRxLen->SetRxLen(1600);
    
    // Start DMA
    pCore->pSlzwCodec->pControl->SetStart(1);

    // Wait for busy not set
    uint32_t finished = 0;
    do
    {
       usleepSim(1);
       finished = pCore->pSlzwCodec->pStatus->GetFinished();
    }
    while(!finished);

    return error;
}
