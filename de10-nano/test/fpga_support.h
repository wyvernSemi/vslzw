// -----------------------------------------------------------------------------
//  Title      : FPGA platform support code
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : fpga_support.h
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : C++11
// -----------------------------------------------------------------------------
//  Description:
//  This code defines a class to support running test code on FPGA platform.
//  It provide means to reset the FPGA, and to get virtual address to 
//  the CSR lightweight bridge, the SDRAM controller, and memory mapped RAM
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

#include <stdint.h>
#include <stdio.h>

#ifndef _FPGA_SUPPORT_H_
#define _FPGA_SUPPORT_H_

// --------------------------------------------------
// LOCAL DEFINES
// --------------------------------------------------

#define HPS_LW_BRIDGE_PADDR 0xff200000
#define HPS_SDR_BASE_PADDR  0xffc25000
#define HPS_RST_MGR_PADDR   0xffd05000
#define START_FPGA_PHY_MEM  0x20000000

// --------------------------------------------------
// CLASS DEFINITION
// --------------------------------------------------

class fpgaSupport
{
private:
    // --------------------------------------------------
    // Local constant defining base addresses
    static const uint32_t hpsLwBridgePaddr  = 0xff200000;
    static const uint32_t hpsSdrBasePaddr   = 0xffc25000;
    static const uint32_t hpsRstMgrPaddr    = 0xffd05000;
    static const uint32_t startRsvdMemPaddr = 0x20000000;

public:
    // Constructor
    fpgaSupport(){
        memDevFd     = -1;
        fpgaVaddr    = nullptr;
        sdramVaddr   = nullptr;
        rstMgrVaddr  = nullptr;
        sdrCtrlVaddr = nullptr;
    };

    // --------------------------------------------------
    // Method to reset the FPGA
    bool fullResetFpga()
    {
        // Get a pointer to the Reset Manager
        if(rstMgrVaddr == nullptr)
        {
            rstMgrVaddr = (void *)getVirtualAddress((uint32_t*)hpsRstMgrPaddr, 0x1000);
        }

        if (rstMgrVaddr != nullptr)
        {
            //CDebug::log(CDebug::log_INFO,"CPrintControllerHIB::resetFpga() : Resetting FPGA\n");
            const uint32_t MiscMod_H2FResetMask = 0x40;
            uint32_t *pMiscModRst               = (uint32_t *)((uint8_t*)rstMgrVaddr + 0x20);
            uint32_t d                          = *pMiscModRst;

            // Assert the Hps2Fpga reset signal for 1us then release
            *pMiscModRst = d | MiscMod_H2FResetMask;
            usleep(1);
            *pMiscModRst = d & ~MiscMod_H2FResetMask;

            usleep(1000000); // time to recover
        }
        else
        {
            return false;
        }

        return true;
    };

    // --------------------------------------------------
    // Method that returns the virtual address of the
    // FPGA lightweight bridge that the CSR bus is
    // connected to.
    void* getFpgaVirtualBaseAddress()
    {
        if (fpgaVaddr == nullptr)
        {
            fpgaVaddr = getVirtualAddress((uint32_t*)hpsLwBridgePaddr, 0x200000);
        }

        return fpgaVaddr;
    };

    // --------------------------------------------------
    // Method to return the virtual address of the SDRAM
    // controller registers
    void* getSdrCtrlVirtualBaseAddress()
    {
        if (sdrCtrlVaddr == nullptr)
        {
            sdrCtrlVaddr = getVirtualAddress((uint32_t*)hpsSdrBasePaddr, 0x1000);
        }

        return sdrCtrlVaddr;
    };

    // --------------------------------------------------
    // Method to return the virtual address of the SDRAM
    // base
    void* getSdramVirtualBaseAddress()
    {
        if (sdramVaddr == nullptr)
        {
            sdramVaddr = getVirtualAddress((uint32_t*)startRsvdMemPaddr, 0x10000000);
        }

        return sdramVaddr;
    };

private:
    // --------------------------------------------------
    // Method to open the /dev/mem device file and return
    // the file descriptor
    int openMemDevice()
    {
        int fd = open("/dev/mem", ( O_RDWR | O_SYNC ) );

        if (fd < 0)
        {
            fprintf(stderr, "openMemDevice() : could not open /dev/mem\n");
        }

        return fd;
    };
    
    // --------------------------------------------------
    // Method to return the virtual address of the
    // specified physical address over the given range.
    void* getVirtualAddress(uint32_t* paddr, uint32_t range)
    {
        if (memDevFd < 0)
        {
            memDevFd = openMemDevice();
        }

        return mmap( NULL, range, ( PROT_READ | PROT_WRITE ), MAP_SHARED, memDevFd, (uint32_t)paddr);

    };

    // --------------------------------------------------
    // Private member variables
    int   memDevFd;
    void* fpgaVaddr;
    void* sdramVaddr;
    void* rstMgrVaddr;
    void* sdrCtrlVaddr;
};

#endif
