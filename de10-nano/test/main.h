// -----------------------------------------------------------------------------
//  Title      : Main platform test code header
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : main.cpp
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : C++11
// -----------------------------------------------------------------------------
//  Description:
//  This file has the top level code header for platform test
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

#include "CCoreAuto.h"

#ifndef _MAIN_H_
#define _MAIN_H_

extern bool        fullResetFpga();
extern void*       getFpgaVirtualBaseAddress();
extern void        write_mem(uint32_t addr, uint32_t word, uint32_t type, bool &access_fault);

#endif
