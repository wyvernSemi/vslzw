// -----------------------------------------------------------------------------
//  Title      : Avalon bus functoinal model process
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : avsproc.v
//  Author     : aSimon Southwell
//  Created    : 2022-02-11
//  Platform   :
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This block is a Virtual processor with Avalon memory mapped master BFM,
//  based on VProc co-simulation element.
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

module avsvproc
#(parameter
  NODE_NUM       = 0,
  AUTO_VALID_CSR = 0
)
(
  input         clk,
  input         rst_n,

  // Avalon memory mapped master interface
  output [31:0] avs_csr_address,
  output        avs_csr_write,
  output [31:0] avs_csr_writedata,
  output        avs_csr_read,
  input  [31:0] avs_csr_readdata,
  input         avs_csr_readdatavalid,

  // Interrupt
  input         irq
);

// Signals for VProc
wire        update;
wire        RD;

wire [31:0] Addr;
wire        WE;
wire [31:0] DataOut;
wire [31:0] DataIn;
wire        RDAck;

// Avalon  bus protocol signals
wire       avs_read;

reg RDLast;
reg avs_csr_readdatavalid_int;

// If auto-generation of read valid for CSR bus is selected, generate in cycle after avs_csr_read
generate
if (AUTO_VALID_CSR != 0)
  // Generate a read data valid for the CSR bus, as the UUT does not do so
  always @(posedge clk or negedge rst_n)
  begin
    if (rst_n == 1'b0)
      avs_csr_readdatavalid_int        <= 1'b0;
    else
    begin
      avs_csr_readdatavalid_int        <= 1'b0;
      if (avs_csr_read == 1'b1)
      begin
        avs_csr_readdatavalid_int      <= 1'b1;
      end
    end
  end
else 
  // If auto-generation of read valid for CSR bus is not selected, connect up the input port
  always @(avs_csr_readdatavalid)
    avs_csr_readdatavalid_int          <= avs_csr_readdatavalid;
endgenerate

// Note. VProc produces byte addresses, but bus is 32 bit word addresses
assign avs_csr_read                    = avs_read;
assign avs_csr_write                   = WE;
assign avs_csr_writedata               = DataOut;
assign avs_csr_address                 = {2'h0, Addr[31:2]};


assign DataIn                          = avs_csr_readdata;
assign RDAck                           = avs_csr_readdatavalid_int;

  // ---------------------------------------
  //  VProc instantiation
  // ---------------------------------------

  VProc vproc_inst (
      .Clk                             (clk),
      .Addr                            (Addr),
      .WE                              (WE),
      .RD                              (RD),
      .DataOut                         (DataOut),
      .DataIn                          (DataIn),
      .WRAck                           (WE),
      .RDAck                           (RDAck),
      .Interrupt                       ({2'h0,  irq}),
      .Update                          (update),
      .UpdateResponse                  (update),
      .Node                            (NODE_NUM[3:0])
    );

  // ---------------------------------------
  //  Generate a delayed version of the RD
  //  output of VProc
  // ---------------------------------------
  always @(posedge clk or negedge rst_n)
  begin
    if (rst_n == 1'b0)
      RDLast                           <= 1'b0;
    else                               
      RDLast                           <= RD;
  end

  // Pulse the AVS read signal only for the first cycles of RD, which won't be
  // deasserted until the RDAck/avs_readdatavalid is returned.
  assign avs_read                      = RD & ~RDLast;

endmodule
