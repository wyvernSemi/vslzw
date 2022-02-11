// -----------------------------------------------------------------------------
//  Title      : Test utilities header
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : utils.h
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : C++11
// -----------------------------------------------------------------------------
//  Description:
//  This block is the header for the test utilities
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

#include <string>

#ifndef _UTILS_H_
#define _UTILS_H_

typedef struct {
    int         testnum;
    uint32_t    clkFreqMHz;

} config_t;

extern int           parseArgs   (int argcIn, char** argvIn, config_t &cfg);

#endif
