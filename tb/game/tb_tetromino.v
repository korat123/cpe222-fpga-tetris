// tb_tetromino.v — self-checking testbench for tetromino
// Contract: print exactly one `TB_PASS tb_tetromino` at the end, or `TB_FAIL tb_tetromino: <reason>`.
// Checks all 28 (type, rotation) entries two independent ways:
//   1) against a table of expected 4x4 masks (bit index = dy*4 + dx),
//   2) against the SRS rule "next rotation = previous one turned 90 degrees clockwise in its box".
// Plus: always exactly 4 distinct cells, 3x3 pieces stay in their 3x3 box, type 0 gives 0,
// and no two piece types share the same spawn shape.
`timescale 1ns/1ps
`include "tb_utils.vh"
`include "tetris_defs.vh"

module tb_tetromino;
  reg  [2:0]    piece_type = 0;
  reg  [1:0]    piece_rot = 0;
  wire [15:0]   cells;
  integer errors = 0;

  tetromino dut (
    .piece_type(piece_type),
    .piece_rot(piece_rot),
    .cells(cells)
  );

  // expected 4x4 occupancy mask per entry, index = type*4 + rot (type 0 = empty -> 0)
  reg [15:0] exp [0:31];
  reg [15:0] spawn [1:7];
  reg [15:0] m, prev;
  integer t, r, a, b, box;

  // turn the 4 {dx,dy} cells into a 16-bit mask; duplicate cells collapse into one bit
  function [15:0] to_mask(input [15:0] c);
    integer k;
    begin
      to_mask = 16'd0;
      for (k = 0; k < 4; k = k + 1)
        to_mask = to_mask | (16'd1 << (c[4*k+1 -: 2] * 4 + c[4*k+3 -: 2]));
    end
  endfunction

  // rotate a mask 90 degrees clockwise inside an n x n box: (x, y) -> (n-1-y, x)
  function [15:0] rot_cw(input [15:0] msk, input integer n);
    integer x, y;
    begin
      rot_cw = 16'd0;
      for (y = 0; y < n; y = y + 1)
        for (x = 0; x < n; x = x + 1)
          if (msk[y*4 + x]) rot_cw[x*4 + (n-1-y)] = 1'b1;
    end
  endfunction

  function integer ones(input [15:0] msk);
    integer k;
    begin
      ones = 0;
      for (k = 0; k < 16; k = k + 1) ones = ones + msk[k];
    end
  endfunction

  initial begin
    for (a = 0; a < 32; a = a + 1) exp[a] = 16'd0;
    exp[4] = 16'h00F0;  // I rot0: .... / #### / .... / ....
    exp[5] = 16'h4444;  // I rot1: ..#. / ..#. / ..#. / ..#.
    exp[6] = 16'h0F00;  // I rot2: .... / .... / #### / ....
    exp[7] = 16'h2222;  // I rot3: .#.. / .#.. / .#.. / .#..
    exp[8] = 16'h0066;  // O rot0: .##. / .##. / .... / ....
    exp[9] = 16'h0066;  // O rot1: .##. / .##. / .... / ....
    exp[10] = 16'h0066;  // O rot2: .##. / .##. / .... / ....
    exp[11] = 16'h0066;  // O rot3: .##. / .##. / .... / ....
    exp[12] = 16'h0072;  // T rot0: .#. / ### / ...
    exp[13] = 16'h0262;  // T rot1: .#. / .## / .#.
    exp[14] = 16'h0270;  // T rot2: ... / ### / .#.
    exp[15] = 16'h0232;  // T rot3: .#. / ##. / .#.
    exp[16] = 16'h0036;  // S rot0: .## / ##. / ...
    exp[17] = 16'h0462;  // S rot1: .#. / .## / ..#
    exp[18] = 16'h0360;  // S rot2: ... / .## / ##.
    exp[19] = 16'h0231;  // S rot3: #.. / ##. / .#.
    exp[20] = 16'h0063;  // Z rot0: ##. / .## / ...
    exp[21] = 16'h0264;  // Z rot1: ..# / .## / .#.
    exp[22] = 16'h0630;  // Z rot2: ... / ##. / .##
    exp[23] = 16'h0132;  // Z rot3: .#. / ##. / #..
    exp[24] = 16'h0071;  // J rot0: #.. / ### / ...
    exp[25] = 16'h0226;  // J rot1: .## / .#. / .#.
    exp[26] = 16'h0470;  // J rot2: ... / ### / ..#
    exp[27] = 16'h0322;  // J rot3: .#. / .#. / ##.
    exp[28] = 16'h0074;  // L rot0: ..# / ### / ...
    exp[29] = 16'h0622;  // L rot1: .#. / .#. / .##
    exp[30] = 16'h0170;  // L rot2: ... / ### / #..
    exp[31] = 16'h0223;  // L rot3: ##. / .#. / .#.
  end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_tetromino.vcd"); $dumpvars(0, tb_tetromino); end
    #10;
    for (t = 0; t < 8; t = t + 1) begin
      box = (t == `P_I) ? 4 : 3;
      for (r = 0; r < 4; r = r + 1) begin
        piece_type = t; piece_rot = r;
        #10;
        m = to_mask(cells);
        if (t == 0) begin
          `CHECK(cells == 16'd0, "type 0 (empty) must give cells = 0")
        end else begin
          `CHECK(m == exp[t*4 + r], "shape differs from the expected table")
          `CHECK(ones(m) == 4, "piece must have exactly 4 distinct cells")
          // begin/end around every `CHECK: the macro is an if, so a bare else would bind to it
          if (box == 3) begin
            `CHECK((m & ~16'h0777) == 16'd0, "3x3 piece left its 3x3 box")
          end
          if (r == 0) begin
            spawn[t] = m;
          end else if (t == `P_O) begin
            `CHECK(m == prev, "O must not change when rotated")
          end else begin
            `CHECK(m == rot_cw(prev, box), "rotation is not 90 degrees clockwise (SRS)")
          end
          if (r == 3 && t != `P_O) begin
            `CHECK(rot_cw(m, box) == spawn[t], "4 rotations must return to rot 0")
          end
        end
        if (errors != 0 && m != exp[t*4 + r])
          $display("  type %0d rot %0d: got mask %h, expected %h", t, r, m, exp[t*4 + r]);
        prev = m;
      end
    end
    for (a = 1; a < 8; a = a + 1)
      for (b = a + 1; b < 8; b = b + 1)
        `CHECK(spawn[a] != spawn[b], "two piece types share the same spawn shape")
    `TB_FINISH("tb_tetromino")
  end
endmodule
