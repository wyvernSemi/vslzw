// -----------------------------------------------------------------------------
//  Title      : Core directed test bench control
// -----------------------------------------------------------------------------
//  File       : tb_ctrl.v
//  Author     : Simon Southwell
//  Created    : 2022-02-11
//  Platform   :
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This block is test control block for the core component top level
//  test bench
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

`timescale 1ps / 1ps

module tb_ctrl
#(parameter
    GUI_RUN           = 0,
    CLK_FREQ_MHZ      = 200
)
(
  // Clock and reset outputs
  output reg       clk_x2,
  output reg       clk,
  output reg       clk_div2,
  output reg       rst_n,

  output [31:0] count_vec,
  input  [31:0] timeout,

  // Simulation status and control inputs
  input         error,
  input         do_stop,
  input         do_finish,
  input         partial_test,

  output        failed,
  output        passed
);

integer         count;
wire            end_sim;

real            clk_x2_period;

initial
begin
  clk_x2                               = 1'b1;
  clk                                  = 1'b1;
  clk_div2                             = 1'b1;
  rst_n                                = 1'b0;

  count                                = 0;
  clk_x2_period                        = 1000000.0/(CLK_FREQ_MHZ*2.0);
end

// ---------------------------------------
//  Clock and reset generation
// ---------------------------------------

// Clock generation with concurrent procedure call
always
  #(clk_x2_period/2.0) clk_x2        <= ~clk_x2;

// Export counter
assign count_vec                     = count;

// Derive system clock from master clock
always @(posedge clk_x2)
begin
  clk                                <= ~clk;
end

always @(posedge clk)
begin
  clk_div2                           <= ~clk_div2;
end

// Generate a reset
always @(posedge clk)
begin
  count                              <= count + 1;
  rst_n                              <= (count > 10) ? 1'b1 : 1'b0;
end

// End-of-simulation signals
assign end_sim                       = (count == timeout || do_stop == 1'b1 || do_finish == 1'b1) ? 1'b1 : 1'b0;
assign failed                        = (end_sim == 1'b1 && (error == 1'b1 || count == timeout)) ? 1'b1 : 1'b0;
assign passed                        = (end_sim == 1'b1 && error == 1'b0) ? 1'b1 : 1'b0;

// ---------------------------------------
//  Simulation control from VProc over
//  CSR bus
// ---------------------------------------

always @(posedge clk)
begin


  // ---------------------------------------
  //  End simulation
  // ---------------------------------------

  // If end of simulation, stop
  if (end_sim == 1'b1)
  begin
    if (error == 1'b1)
        $display("*** FAIL: errors found");
    else
    begin
       if (count >= timeout)
         $display("*** FAIL: timeout");
       else if (partial_test == 1'b1)
         $display("NO FAILURES");
       else
         $display("SUCCESS");
    end

    if (GUI_RUN != 0 || (do_stop == 1'b1 && do_finish == 1'b0))
      $stop;
    else
      $finish;
  end

end

endmodule