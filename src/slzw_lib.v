// -----------------------------------------------------------------------------
//  Title      : Verilog SLZW utility modules library
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : slzw_lib.v
//  Author     : Simon Southwell
//  Created    : 2022-02-02
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This file contains the base utility modules for the SLZW codec
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

`timescale 1ns / 10ps

// -----------------------------------------------------------------------------
// DEFINITIONS
// -----------------------------------------------------------------------------


`ifndef RESET
//`RESET
`define RESET or negedge reset_n
`endif

// -----------------------------------------------------------------------------
// Hash
// -----------------------------------------------------------------------------

module slzw_hash
(
  input  [12:0] code,
  input   [7:0] byte,

  output [13:0] haddr

 );

wire [13:0] num1 = {1'b0, byte[4:0], byte[7:0]};
wire [13:0] num2 = {1'b0, code[ 0], code[ 1], code[ 2], code[ 3],
                          code[ 4], code[ 5], code[ 6], code[ 7],
                          code[ 8], code[ 9], code[10], code[11],
                          code[12]};

assign haddr      = num1 + num2;

endmodule

// -----------------------------------------------------------------------------
// Occupied flag memory
// -----------------------------------------------------------------------------

module slzw_mem_occupied
#(parameter
   MEMSIZE                     = 10240
)
(
  input             clk,
  input             reset_n,

  input             clr,

  input      [13:0] waddr,
  input      [13:0] raddr,
  input             set,

  output            occupied,
  output            busy
);

localparam  OCCMEMSIZE         = MEMSIZE/32;

reg  [31:0] occmem [0:OCCMEMSIZE-1];
reg         set_last;
reg  [13:0] addr_last;
reg  [31:0] rval;
reg         clr_last;
reg   [8:0] clr_count;

wire        out_of_range       = (waddr > (OCCMEMSIZE[13:0]-14'b1)) ? 1'b1 : 1'b0;

assign      occupied           = rval[waddr[4:0]] | (set_last && (addr_last == waddr)) | out_of_range;
assign      busy               = (clr_count > 9'h000);

always @ (posedge clk `RESET)
begin
  if (reset_n == 1'b0)
  begin
    set_last                   <= 1'b0;
    clr_last                   <= 1'b0;
    clr_count                  <= 9'h000;
  end
  else
  begin
    // Carry some signals over to the next cycle
    clr_last                   <= clr;
    set_last                   <= set;
    addr_last                  <= waddr;

    // If a valid address, read the occupied flag memory
    if (!out_of_range)
    begin
      rval                     <= occmem[raddr[13:5]];
    end

    // If a rising edge on the clear input, or already clearing, reset the memory
    if ((clr && !clr_last && clr_count == 9'h000) || busy)
    begin
      occmem[clr_count]        <= 32'h00000000;
      clr_count                <= clr_count + 9'h001;
      if (clr_count == (OCCMEMSIZE[8:0]-9'd1))
      begin
        clr_count              <= 9'h00;
      end
    end

    // When not clearing, and setting an occupied bit, OR the
    // relevant bit of the value just read with 1.
    else if (set_last && !out_of_range)
    begin
      occmem[addr_last[13:5]]  <= rval | (32'h1 << addr_last[4:0]);
    end
  end
end

endmodule

// -----------------------------------------------------------------------------
// Dictionary memory
// -----------------------------------------------------------------------------

module slzw_dictmem
#(parameter
   MEMSIZE                     = 10240,
   WIDTH                       = 8
)
(
  input                        clk,

  input           [13:0]       waddr,
  input                        write,
  input      [WIDTH-1:0]       wdata,

  input           [13:0]       raddr,
  output reg [WIDTH-1:0]       rdata

);

reg [WIDTH-1:0] mem[0:MEMSIZE];

always @ (posedge clk)
begin
  rdata                        <= mem[raddr];

  if (write)
  begin
    mem[waddr]                 <= wdata;
  end
end

endmodule

// -----------------------------------------------------------------------------
// LIFO
// -----------------------------------------------------------------------------

module slzw_lifo
#(parameter
   DEPTH                       = 128,
   WIDTH                       = 8
)
(
  input                        clk,
  input                        reset_n,

  input                        clr,

  input                        push,
  input      [WIDTH-1:0]       wdata,

  input                        pop,
  output reg [WIDTH-1:0]       rdata,

  output reg                   empty,
  output                       full
);

localparam                     LOG2DEPTH = $clog2(DEPTH);

reg  [WIDTH-1:0]               mem [0:DEPTH-1];
reg  [LOG2DEPTH:0]             ptr;

wire [LOG2DEPTH:0]             ptr_minus1 = ptr - 1;

wire                           pushval    = push && ~full;
wire                           popval     = pop  && ptr != 0;

wire [LOG2DEPTH-1:0]           nextptr    = ptr + ((pushval & ~popval)  ? {{LOG2DEPTH{1'b0}}, 1'b1} :  // + 1
                                                   (popval  & ~pushval) ? {LOG2DEPTH+1{1'b1}}       :  // - 1
                                                                          {LOG2DEPTH+1{1'b0}});        // + 0

assign                         full       = ptr[LOG2DEPTH];

always @(posedge clk `RESET)
begin
  if (reset_n == 1'b0)
  begin
    ptr                        <= {LOG2DEPTH-1{1'b0}};
    empty                      <= 1'b1;
  end
  else
  begin
    rdata                      <= mem[ptr_minus1];
    ptr                        <= nextptr & {LOG2DEPTH{~clr}};
    empty                      <= clr ?                               1'b0 :
                                  (popval  && ~pushval && ptr == 1) ? 1'b1 :
                                                                      empty;
    if (pushval)
    begin
      mem[ptr]                 <= wdata;
      empty                    <= 1'b0;
    end
  end
end

endmodule

// -----------------------------------------------------------------------------
// FIFO
// -----------------------------------------------------------------------------

module slzw_fifo
#(parameter
   DEPTH                       = 8,
   WIDTH                       = 32,
   NEARLYFULL                  = (DEPTH/2)
)
(
  input                        clk,
  input                        reset_n,

  input                        clr,

  input                        write,
  input      [WIDTH-1:0]       wdata,

  input                        read,
  output reg [WIDTH-1:0]       rdata,

  output reg                   empty,
  output reg                   full,
  output reg                   nearly_full
);

localparam                     LOG2DEPTH = $clog2(DEPTH);

reg  [WIDTH-1:0]               mem [0:DEPTH-1];
reg  [LOG2DEPTH:0]             wptr;
reg  [LOG2DEPTH:0]             rptr;

// The number of words in the FIFO is the write pointer minus the read pointer
wire [LOG2DEPTH:0]             word_count = (wptr - rptr);

always @(posedge clk `RESET)
begin
  if (reset_n == 1'b0)
  begin
    wptr                       <= {LOG2DEPTH{1'b0}};
    rptr                       <= {LOG2DEPTH{1'b0}};
    empty                      <= 1'b1;
    full                       <= 1'b0;
    nearly_full                <= 1'b0;
  end
  else
  begin
    // If a write arrives, and not full, write to memory and update write pointer
    if (write && ~full)
    begin
      mem[wptr[LOG2DEPTH-1:0]] <= wdata;
      wptr                     <= wptr + 1;
    end

    // If a read arrives, and not empty, fetch data from memory and update read pointer
    if (read && ~empty)
    begin
      rdata                    <= mem[rptr[LOG2DEPTH-1:0]];
      rptr                     <= rptr + 1;
    end

    // If writing, but not reading, update full status when last space being written.
    // The nearly full flag is asserted when about to reach the threshold, or is greater.
    // A write (without read) always clears the empty flag
    if (write & ~(read & ~empty))
    begin
      full                     <= (word_count == DEPTH-1)      ? 1'b1 : 1'b0;
      nearly_full              <= (word_count >= NEARLYFULL-1) ? 1'b1 : 1'b0;
      empty                    <= 1'b0;
    end

    // If reading (but not writing), update empty status when last data is being read.
    // The nearly full flag is deasserted when about to drop below the threshold, or
    // is smaller. A read (without a write), always clears the full status.
    if (read & ~(write & ~full))
    begin
      empty                    <= (word_count == 1)            ? 1'b1 : 1'b0;
      nearly_full              <= (word_count <= NEARLYFULL)   ? 1'b0 : 1'b1;
      full                     <= 1'b0;
    end
  end
end

endmodule