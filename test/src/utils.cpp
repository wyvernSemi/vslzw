// -----------------------------------------------------------------------------
//  Title      : Test utilities
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : utils.cpp
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Standard   : C++11
// -----------------------------------------------------------------------------
//  Description:
//  This file contains the test utilities functions
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

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "utils.h"

// --------------------------------------------------
// DEFINES
// --------------------------------------------------

#define MAXARGS 100

#ifndef HDL_SIM
#define CFGFILENAME "host.cfg"
#else
#define CFGFILENAME "vusermain.cfg"
#endif


// --------------------------------------------------
// Parse configuration file arguments
// --------------------------------------------------

int parseArgs(int argcIn, char** argvIn, config_t &cfg)
{
    int    c;
    int    argc = 0;
    char*  argvBuf[MAXARGS];
    char** argv = NULL;

    char*  argstr = NULL;
    size_t len = 0;
    char   delim[2];
    FILE* fp;
    
    cfg.testnum    = 0;

    if (argcIn > 1)
    {
        argc = argcIn;
        argv = argvIn;
    }
    else
    {

        fp = fopen(CFGFILENAME, "r");
        if (fp == NULL)
            return 1;

        strcpy(delim, " ");

        getline(&argstr, &len, fp);
        strtok(argstr, delim);

        fclose(fp);

        if (argvBuf[0] != NULL)
        {
            argc = 1;
        }

        while((argvBuf[argc] = strtok(NULL, " ")) != NULL && argc < MAXARGS)
        {
           argc++;
        }

        argv = argvBuf;
    }

    int returnVal = 0;


    opterr = 0;
    while ((c = getopt (argc, argv, "ht:")) != -1)
    {
        switch (c)
        {
        case 't':
            cfg.testnum      = atoi(optarg);
            break;
        case 'h':
        default:
            printf("Usage: vusermain.cfg [-h] [-t <test num>]\n");
            printf("         -t Specify test (default 0)\n");
            printf("\n");
            returnVal = 1;
            break;
        }
    }

    return returnVal;
}
