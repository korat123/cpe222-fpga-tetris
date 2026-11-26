// tb_collision.v — self-checking testbench for collision
// Contract: print exactly one `TB_PASS tb_collision` at the end, or `TB_FAIL tb_collision: <reason>`.
// cells come from the real tetromino ROM. Three layers of checks:
//   1. hand-written cases (walls, floor, negative x, locked cells, board corners) — easy to read
//   2. every piece x rotation x test_x (all 32 values) x test_y (all 32 values) on an empty board,
//      against a reference model written with plain integers (independent of the RTL)
//   3. random boards + random positions against the same reference model
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_collision;
  reg  [4:0]    test_x = 0;
  reg  [4:0]    test_y = 0;
  reg  [2:0]    piece_type = 1;
  reg  [1:0]    piece_rot = 0;
  wire [15:0]   cells;
  reg  [599:0]  board = 0;
  wire          collide;
  integer errors = 0;

  tetromino u_tetromino (
    .piece_type(piece_type),
    .piece_rot(piece_rot),
    .cells(cells)
  );

  collision dut (
    .test_x(test_x),
    .test_y(test_y),
    .cells(cells),
    .board(board),
    .collide(collide)
  );

  // ---------- reference model ----------
  // x = signed test_x + dx, y = test_y + dy; hit when outside 0..9 / 0..19 or the board cell is not 0
  function ref_collide(input [4:0] tx, input [4:0] ty, input [15:0] c, input [599:0] b);
    integer k, ax, ay, sx;
    begin
      ref_collide = 1'b0;
      sx = tx;
      if (tx[4]) sx = tx - 32;          // 5-bit two's complement -> integer
      for (k = 0; k < 4; k = k + 1) begin
        ax = sx + c[4*k+2 +: 2];        // dx = bits [4k+3:4k+2]
        ay = ty + c[4*k +: 2];          // dy = bits [4k+1:4k]
        if (ax < 0 || ax > 9 || ay > 19)
          ref_collide = 1'b1;
        else if (b[(ay*10 + ax)*3 +: 3] != 3'd0)
          ref_collide = 1'b1;
      end
    end
  endfunction

  task put_cell(input integer x, input integer y, input [2:0] v);
    begin
      board[(y*10 + x)*3 +: 3] = v;
    end
  endtask

  // set inputs, wait for the combinational result, compare with an expected value
  task expect_hit(input [2:0] t, input [1:0] r, input integer x, input integer y, input exp,
                  input [8*40-1:0] what);
    begin
      piece_type = t; piece_rot = r; test_x = x; test_y = y;
      #1;
      if (collide !== exp) begin
        `CHECK(1'b0, what)
        $display("  type=%0d rot=%0d x=%0d y=%0d collide=%b expected=%b", t, r, x, y, collide, exp);
      end
    end
  endtask

  integer t, r, x, y, n, i;
  reg exp_c;

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_collision.vcd"); $dumpvars(0, tb_collision); end

    // ---------- 1. hand-written cases (empty board) ----------
    // change the ROM inputs after time 0 so tetromino's always @* runs once (cells is X before that)
    piece_type = 0; #1;
    board = 0;
    // I rot0 = row dy=1, dx 0..3
    expect_hit(1, 0,  0,  0, 1'b0, "I0 at left wall fits");
    expect_hit(1, 0, -1,  0, 1'b1, "I0 one left of wall");
    expect_hit(1, 0,  6,  0, 1'b0, "I0 at right wall fits");
    expect_hit(1, 0,  7,  0, 1'b1, "I0 one right of wall");
    expect_hit(1, 0,  0, 18, 1'b0, "I0 on the floor fits");
    expect_hit(1, 0,  0, 19, 1'b1, "I0 below the floor");
    // I rot1 = column dx=2, dy 0..3: the box may hang 2 columns left of the board
    expect_hit(1, 1, -2,  0, 1'b0, "I1 negative x, cells inside");
    expect_hit(1, 1, -3,  0, 1'b1, "I1 negative x, cell outside");
    expect_hit(1, 1,  7,  0, 1'b0, "I1 dx=2 at right wall fits");
    expect_hit(1, 1,  8,  0, 1'b1, "I1 one right of wall");
    expect_hit(1, 1,  0, 16, 1'b0, "I1 on the floor fits");
    expect_hit(1, 1,  0, 17, 1'b1, "I1 below the floor");
    // I rot3 = column dx=1: may hang 1 column left
    expect_hit(1, 3, -1,  5, 1'b0, "I3 x=-1 fits");
    expect_hit(1, 3, -2,  5, 1'b1, "I3 x=-2 hits wall");
    // O = dx 1..2, dy 0..1
    expect_hit(2, 0, -1,  0, 1'b0, "O x=-1 fits");
    expect_hit(2, 0,  7,  0, 1'b0, "O x=7 fits");
    expect_hit(2, 0,  8,  0, 1'b1, "O x=8 hits wall");
    expect_hit(2, 0,  0, 18, 1'b0, "O on the floor fits");
    // largest positive / negative test_x must not wrap into the board
    expect_hit(1, 1, 15,  0, 1'b1, "x=15 is far right");
    expect_hit(1, 1, -16, 0, 1'b1, "x=-16 is far left");
    expect_hit(2, 0,  0, 31, 1'b1, "y=31 is far below");

    // locked cells
    board = 0; put_cell(4, 10, 3'd5);
    expect_hit(2, 0, 3,  8, 1'b0, "O just above block");
    expect_hit(2, 0, 3,  9, 1'b1, "O lower row overlaps block");
    expect_hit(2, 0, 3, 10, 1'b1, "O overlaps block at (4,10)");
    expect_hit(2, 0, 2, 10, 1'b1, "O overlaps block with dx=2");
    expect_hit(2, 0, 4, 10, 1'b0, "O just right of block");
    expect_hit(2, 0, 3, 11, 1'b0, "O just below block");
    // every non-zero cell value counts as a block
    for (i = 1; i < 8; i = i + 1) begin
      board = 0; put_cell(4, 10, i);
      expect_hit(2, 0, 3, 10, 1'b1, "any non-zero cell value blocks");
    end
    // corners of the board (check the bit index of the first and last cell)
    board = 0; put_cell(0, 0, 3'd1);
    expect_hit(1, 1, -2, 0, 1'b1, "block at (0,0)");
    expect_hit(1, 1, -1, 0, 1'b0, "free column next to (0,0)");
    board = 0; put_cell(9, 19, 3'd7);
    expect_hit(1, 1,  7, 16, 1'b1, "block at (9,19)");
    expect_hit(1, 1,  7, 15, 1'b0, "above (9,19)");
    // full board except one hole: only the matching piece fits
    board = {200{3'd1}}; put_cell(2, 19, 3'd0); put_cell(3, 19, 3'd0);
    put_cell(4, 19, 3'd0); put_cell(5, 19, 3'd0);
    expect_hit(1, 0, 2, 18, 1'b0, "I0 fits the 4-wide hole");
    expect_hit(1, 0, 3, 18, 1'b1, "I0 shifted by one hits");

    // ---------- 2. exhaustive on an empty board ----------
    board = 0;
    n = 0;
    for (t = 1; t < 8; t = t + 1)
      for (r = 0; r < 4; r = r + 1)
        for (x = 0; x < 32; x = x + 1)
          for (y = 0; y < 32; y = y + 1) begin
            piece_type = t; piece_rot = r; test_x = x; test_y = y;
            #1;
            exp_c = ref_collide(test_x, test_y, cells, board);
            if (collide !== exp_c) begin
              n = n + 1;
              if (n <= 5) $display("  empty board: type=%0d rot=%0d x=%0d y=%0d got=%b exp=%b",
                                   t, r, x, y, collide, exp_c);
            end
          end
    `CHECK(n == 0, "exhaustive empty-board sweep")

    // ---------- 3. random boards ----------
    n = 0;
    for (i = 0; i < 3000; i = i + 1) begin
      for (y = 0; y < 20; y = y + 1)
        for (x = 0; x < 10; x = x + 1)
          board[(y*10 + x)*3 +: 3] = (($random & 3) == 0) ? ($random & 7) : 3'd0;  // ~1/4 filled
      piece_type = 1 + ({$random} % 7); piece_rot = $random; test_x = $random; test_y = $random;
      #1;
      exp_c = ref_collide(test_x, test_y, cells, board);
      if (collide !== exp_c) begin
        n = n + 1;
        if (n <= 5) $display("  random: type=%0d rot=%0d x=%0d y=%0d got=%b exp=%b",
                             piece_type, piece_rot, test_x, test_y, collide, exp_c);
      end
    end
    `CHECK(n == 0, "random boards vs reference model")

    `TB_FINISH("tb_collision")
  end
endmodule
