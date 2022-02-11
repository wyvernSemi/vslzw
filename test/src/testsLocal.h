// -----------------------------------------------------------------------------
//  Title      : Tests class local definitions header
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : testsLocal.h
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : C++11
// -----------------------------------------------------------------------------
//  Description:
//  This file contains the code for the tests class local definitions
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

#ifndef _TESTS_LOCAL_H_
#define _TESTS_LOCAL_H_

// Include top level HAL header
#include "hal/CCoreAuto.h"

// Address of physical memory where output data starts
#define START_PHY_MEM                           0x20000000

#define TEST_ERROR                              1
#define NOERROR                                 0

// This must match the test bench system clock period to get accurate sleep times in the software
#define SYS_CLK_PERIOD_NS                       10

#endif
