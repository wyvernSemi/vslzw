// -----------------------------------------------------------------------------
//  Title      : Verilog SLZW dictionary module
//  Project    : vslzw
// -----------------------------------------------------------------------------
//  File       : slzw_dict.v
//  Author     : Simon Southwell
//  Created    : 2022-02-03
//  Standard   : Verilog 2001
// -----------------------------------------------------------------------------
//  Description:
//  This file contains the dictionary functionality for the SLZW codec
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

// =============================================================================
// Dictionary module
// =============================================================================

module slzw_dict
#(parameter
  MEMSIZE                      = 10240
)
(
  input                        clk,
  input                        reset_n,

  input                        clr,

  // Mode
  input                        compress,

  // Entry match port (compress)
  input                        match,
  input      [11:0]            match_code,
  input       [7:0]            match_byte,
  output reg                   matched,
  output reg                   matched_valid,

  // Build entry port (decompress)
  input                        build_entry,
  input      [11:0]            build_code,
  input       [7:0]            build_byte,

  // Read Port (decompress)
  input      [11:0]            dict_decomp_ptr,
  output     [12:0]            dict_code,
  output      [7:0]            dict_byte,

  output reg  [3:0]            op_code_len

);

// -----------------------------------------------------------------------------
// Local parameter definitions
// -----------------------------------------------------------------------------

// Bounding definitions
localparam                     MINCWLEN           = 4'd9;
localparam                     DICTFULL           = 13'h1000;
localparam                     FIRSTCW            = 13'h0100;

// FSM state definitions
localparam                     state_idle         = 3'd0;
localparam                     state_rdmem        = 3'd1;
localparam                     state_rehash       = 3'd2;
localparam                     state_build        = 3'd3;
localparam                     state_rehash_retry = 3'd4;

// -----------------------------------------------------------------------------
// Register definitions
// -----------------------------------------------------------------------------

// FSM state
reg  [2:0]                     state;

// Dictionary state
reg  [12:0]                    next_avail_code;
reg  [12:0]                    nac_plus_1;

// Holding state for matching final values
reg  [13:0]                    last_match_addr;
reg  [13:0]                    last_match_code;
reg   [7:0]                    last_match_byte;

// Hashing state
reg  [13:0]                    seed;
reg                            rehash;
reg                            cmp_build;
reg                            occ_clr;

// -----------------------------------------------------------------------------
// Signal definitions
// -----------------------------------------------------------------------------

// Next available codeword compare value for generating o/p codewidth
wire [12:0]                    nac_cmp;

// Signalling for writing to dictionary memory
wire                           wr_dict;
wire [13:0]                    wr_addr;
wire [12:0]                    wr_code;
wire  [7:0]                    wr_byte;

// Signalling for reading from dictionary memory
wire [13:0]                    raddr;

// Signalling for rehash locations
wire [13:0]                    raddr1;
wire [13:0]                    raddr2;

// Signals for hash calculations
wire [12:0]                    hcode;
wire [13:0]                    haddr;
wire [13:0]                    addr1;
wire [13:0]                    addr2;

// Signals for dictionary status
wire                           dict_full;

// Signals for entry status
wire                           collision;
wire  [1:0]                    occupied;
wire                           occ_busy;
wire                           occ_set;

// -----------------------------------------------------------------------------
// Memory instantiations
// -----------------------------------------------------------------------------

  slzw_dictmem
  #(.MEMSIZE                   (MEMSIZE),
    .WIDTH                     (8)
  ) dictmem_byte
  (
    .clk                       (clk),

    .write                     (wr_dict),
    .waddr                     (wr_addr),
    .wdata                     (wr_byte),

    .raddr                     (raddr),
    .rdata                     (dict_byte)
  );

  slzw_dictmem
  #(.MEMSIZE                   (MEMSIZE),
    .WIDTH                     (13)
  ) dictmem_code
  (
    .clk                       (clk),

    .write                     (wr_dict),
    .waddr                     (wr_addr),
    .wdata                     (wr_code),

    .raddr                     (raddr),
    .rdata                     (dict_code)
  );

  slzw_mem_occupied
  #(.MEMSIZE                   (MEMSIZE)
  ) mem_occ
  (
    .clk                       (clk),
    .reset_n                   (reset_n),

    .clr                       (occ_clr),

    .waddr                     (haddr),
    .raddr                     (raddr1),
    .set                       (occ_set),

    .occupied                  (occupied[0]),
    .busy                      (occ_busy)
  );

  slzw_mem_occupied
  #(.MEMSIZE                   (MEMSIZE)
  ) mem_occ_aux
  (
    .clk                       (clk),
    .reset_n                   (reset_n),

    .clr                       (occ_clr),

    .waddr                     (haddr),
    .raddr                     (raddr2),
    .set                       (occ_set),

    .occupied                  (occupied[1]),
    .busy                      ()
  );
  
// -----------------------------------------------------------------------------
// Hash module instantiations
// -----------------------------------------------------------------------------

  slzw_hash hash_i
  (
    .code                      (hcode),
    .byte                      (match_byte),
    .haddr                     (haddr)
  );

  slzw_hash seed_hash_1
  (
    .code                      (seed[12:0]),
    .byte                      (match_byte),
    .haddr                     (addr1)
  );

  slzw_hash seed_hash_2
  (
    .code                      (seed[12:0]),
    .byte                      (last_match_byte),
    .haddr                     (addr2)
  );

// -----------------------------------------------------------------------------
// Combinatorial Logic
// -----------------------------------------------------------------------------

// Dictionary full if next_avail_code == 0x1000
assign dict_full               = next_avail_code[12];

// Dictionary frozen if seed == 0x2000
assign frozen                  = seed[13];

//assign build_done              = ~compress | (~occ_busy);

assign wr_dict                 = (~compress & build_entry & ~dict_full) | (compress & cmp_build & ~dict_full & ~frozen);

assign wr_addr                 = ~compress ? {1'b0, next_avail_code} : last_match_addr;
assign wr_code                 = ~compress ? {1'b0, build_code}      : next_avail_code;
assign wr_byte                 = ~compress ? build_byte              : last_match_byte;

assign raddr                   = ~compress ? dict_decomp_ptr         : haddr;
assign raddr1                  = rehash ? addr1                      : haddr;
assign raddr2                  = addr2;

// The next available code for comparison on output code width.
// On decompression we are one behind, so use next_avail_code + 1
// (nac_plus_1).
assign nac_cmp                 = ~compress ? nac_plus_1              : next_avail_code;

assign hcode                   = (state == state_idle) ? match_code  : dict_code;
assign collision               = dict_code[12];

// -----------------------------------------------------------------------------
// Dictionary state control
// -----------------------------------------------------------------------------

always @(posedge clk `RESET)
begin
  if (reset_n == 1'b0)
  begin
    next_avail_code            <= FIRSTCW;
    nac_plus_1                 <= FIRSTCW+1;
    op_code_len                <= MINCWLEN;
    occ_clr                    <= 1'b0;
  end
  else
  begin

    occ_clr                    <= 1'b0;

    if (clr)
    begin
      next_avail_code          <= FIRSTCW;
      nac_plus_1               <= FIRSTCW + 1;
      occ_clr                  <= 1'b1;
    end
    else if (build_entry | cmp_build)
    begin
      if (~dict_full)
      begin
        next_avail_code        <= next_avail_code + 13'h0001;
        nac_plus_1             <= nac_plus_1      + 13'h0001;
      end
      else
      begin
        next_avail_code        <= FIRSTCW;
        nac_plus_1             <= FIRSTCW+1;
        occ_clr                <= 1'b1;
      end

      case (nac_cmp)
        13'h0200 : op_code_len <= MINCWLEN + 1;
        13'h0400 : op_code_len <= MINCWLEN + 2;
        13'h0800 : op_code_len <= MINCWLEN + 3;
        13'h1000 : op_code_len <= MINCWLEN;
      endcase
    end
  end
end

// -----------------------------------------------------------------------------
// Control state machine.
// -----------------------------------------------------------------------------

always @(posedge clk `RESET)
begin
  if (reset_n == 1'b0)
  begin
    state                      <= state_idle;
    matched_valid              <= 1'b0;
    matched                    <= 1'b0;
    seed                       <= 14'h0000;

    rehash                     <= 1'b0;
    cmp_build                  <= 1'b0;
  end
  else
  begin
    // Default some state
    matched_valid              <= 1'b0;
    matched                    <= 1'b0;
    cmp_build                  <= 1'b0;

    case (state)
      state_idle:
      begin
        if (match && !occ_busy && !occ_clr)
        begin
          state                <= state_rdmem;
        end
      end

      state_rdmem:
      begin

        // Save off entry state for use in buliding a new entry
        last_match_addr        <= haddr;
        last_match_code        <= dict_code;
        last_match_byte        <= dict_byte;

        // If location not occupied, then match complete
        if (~occupied[0])
        begin
          matched_valid        <= 1'b1;
          state                <= state_build;
        end
        else
        begin
          // If not a collision site, then match complete. Note,
          // if there is a collision then do nothing. Want to remain
          // in this state---haddr is derived from code value of collided location
          // so will following link list until unoccupied or not a collision
          // site.
          if (!collision)
          begin
            matched_valid      <= 1'b1;

            // If input byte matches entry byte, then we matched. Flag
            // the match and return to idle.
            if (match_byte == dict_byte)
            begin
              state            <= state_idle;
              matched          <= 1'b1;
            end
            else
            begin
              state            <= state_rehash;
              rehash           <= 1'b1;
            end
          end
        end
      end

      state_build:
      begin
        cmp_build              <= 1'b1;
        rehash                 <= 1'b0;
        
        if (dict_full)
        begin
          seed                 <= 14'h0000;
        end
        state                  <= state_idle;
      end

      state_rehash:
      begin
        if (~frozen)
        begin
          state                <= state_rehash_retry;
          seed                 <= seed + 14'd1;
        end
        else
        begin
          rehash               <= 1'b0;
          state                <= state_idle;
        end
      end

      state_rehash_retry:
      begin
        if (~|occupied)
        begin
          state                <= state_build;
        end
        seed                   <= seed + 14'd1;
      end

      default:
        state                  <= state_idle;
    endcase

    // If external clear request, override all state updates and return to idle.
    if (clr)
    begin
      state                    <= state_idle;
      matched_valid            <= 1'b0;
      matched                  <= 1'b0;
      seed                     <= 14'h0000;
      rehash                   <= 1'b0;
      cmp_build                <= 1'b0;
    end
  end
end

endmodule