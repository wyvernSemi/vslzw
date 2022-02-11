// -----------------------------------------------------------------------------
//  Title      : Tests class definition header
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : tests.h
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : C++11
// -----------------------------------------------------------------------------
//  Description:
//  This file contains the code for the tests class definition
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

#ifndef _TESTS_H_
#define _TESTS_H_

// VProc user API has C linkage
#ifdef HDL_SIM
extern "C" {
#include "VUser.h"
}
#endif

#include "utils.h"

// Include top level HAL header
#include "hal/CCoreAuto.h"

class tests 
{
public:

    tests() {};
    
    int      start      (uint32_t* coreBaseAddr, config_t config, int node);

private:

    int      codecTest  (CCoreAuto* pCore, const config_t config, const int node);

};

#endif
