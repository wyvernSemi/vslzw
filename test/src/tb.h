// -----------------------------------------------------------------------------
//  Title      : Test bench specific definitions
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : tb.h
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : C++11
// -----------------------------------------------------------------------------
//  Description:
//  This header file contains definitions test bench specific definitions
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

#include <stdio.h>
#include <stdlib.h>

#ifndef _TB_H_
#define _TB_H_

// Address of physical memory where output data starts
#define START_PHY_MEM                           0x20000000

#define MEM_BASE_ADDR                           START_PHY_MEM

// Test bench address for local registers
#define TB_BASE_ADDR                            0x60000000
#define TB_SIM_CTRL_REG                         (TB_BASE_ADDR + 0)
#define TB_CAPTURE_ADDR                         (TB_BASE_ADDR + 4)
#define TB_IMG_WIDTH_PX                         (TB_BASE_ADDR + 8)

#define TB_SIM_CTRL_ERROR_MASK                  0x00000001
#define TB_SIM_CTRL_STOP_MASK                   0x00000002
#define TB_SIM_CTRL_FINISH_MASK                 0x00000004

#define TEST_ERROR                              1
#define NOERROR                                 0

#endif
