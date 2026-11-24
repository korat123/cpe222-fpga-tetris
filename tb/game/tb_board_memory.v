// tb_board_memory.v — self-checking testbench for board_memory
// Contract: print exactly one `TB_PASS tb_board_memory` at the end, or `TB_FAIL tb_board_memory: <reason>`.
// A reference model (written independently of the RTL, cell by cell) is updated with every
// operation and the whole 600-bit bus is compared after each clock edge. A few cells are also
// checked by raw bit index to prove the (y*10+x)*3 layout.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_board_memory;
  reg           clk = 0;
  reg           rst = 0;
  reg           we = 0;
  reg  [3:0]    wx = 0;
  reg  [4:0]    wy = 0;
  reg  [2:0]    wdata = 0;
  reg           shift_en = 0;
  reg  [4:0]    shift_row = 0;
  wire [599:0]  board;
  integer errors = 0;

  board_memory dut (
    .clk(clk),
    .rst(rst),
    .we(we),
    .wx(wx),
    .wy(wy),
    .wdata(wdata),
    .shift_en(shift_en),
    .shift_row(shift_row),
    .board(board)
  );

  always #5 clk = ~clk;  // 100 MHz

  // ---------- reference model ----------
  reg [2:0] model [0:9][0:19];   // model[x][y]
  integer x, y, i, j;

  function [599:0] model_bus(input dummy);
    integer mx, my;
    begin
      model_bus = 600'd0;
      for (my = 0; my < 20; my = my + 1)
        for (mx = 0; mx < 10; mx = mx + 1)
          model_bus[(my*10 + mx)*3 +: 3] = model[mx][my];
    end
  endfunction

  task model_clear;
    begin
      for (y = 0; y < 20; y = y + 1)
        for (x = 0; x < 10; x = x + 1) model[x][y] = 3'd0;
    end
  endtask

  task check_all(input [8*48-1:0] what);
    begin
      `CHECK(board === model_bus(1'b0), what)
    end
  endtask

  // drive inputs away from the clock edge, let one posedge happen, then compare
  task step;
    begin
      @(posedge clk); #1;
      we = 0; shift_en = 0; rst = 0;
    end
  endtask

  task do_write(input [3:0] cx, input [4:0] cy, input [2:0] d);
    begin
      we = 1; wx = cx; wy = cy; wdata = d;
      step;
      if (cx < 10 && cy < 20) model[cx][cy] = d;  // out of range: board must not change
      check_all("write");
    end
  endtask

  task do_shift(input [4:0] row);
    integer r, c;
    begin
      shift_en = 1; shift_row = row;
      step;
      if (row < 20) begin
        for (r = row; r > 0; r = r - 1)
          for (c = 0; c < 10; c = c + 1) model[c][r] = model[c][r-1];
        for (c = 0; c < 10; c = c + 1) model[c][0] = 3'd0;
      end
      check_all("shift");
    end
  endtask

  task do_reset;
    begin
      rst = 1;
      step;
      model_clear;
      check_all("reset");
      `CHECK(board === 600'd0, "reset must clear every cell")
    end
  endtask

  // fill every row with its own pattern so a wrong shift is easy to see
  task fill_pattern;
    begin
      for (y = 0; y < 20; y = y + 1)
        for (x = 0; x < 10; x = x + 1) do_write(x, y, ((x + y) % 7) + 1);
    end
  endtask

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_board_memory.vcd"); $dumpvars(0, tb_board_memory); end
    model_clear;
    #2;

    // 1) reset clears everything
    do_reset;

    // 2) single write appears after exactly one clock edge and touches only 3 bits
    we = 1; wx = 4; wy = 7; wdata = 3'd5;
    #1; `CHECK(board[(7*10+4)*3 +: 3] == 3'd0, "write must not appear before the clock edge")
    we = 0;
    do_write(4, 7, 3'd5);
    `CHECK(board[(7*10+4)*3 +: 3] == 3'd5, "cell (4,7) written")

    // 3) corners, checked by raw bit index too
    do_write(0, 0, 3'd1);
    do_write(9, 0, 3'd2);
    do_write(0, 19, 3'd3);
    do_write(9, 19, 3'd4);
    `CHECK(board[2:0] == 3'd1,       "corner (0,0) at bits [2:0]")
    `CHECK(board[29:27] == 3'd2,     "corner (9,0) at bits [29:27]")
    `CHECK(board[572:570] == 3'd3,   "corner (0,19) at bits [572:570]")
    `CHECK(board[599:597] == 3'd4,   "corner (9,19) at bits [599:597]")

    // 4) overwrite with 0 clears a cell; we = 0 writes nothing
    do_write(4, 7, 3'd0);
    wx = 1; wy = 1; wdata = 3'd7; step; check_all("we=0 must not write");

    // 5) out-of-range writes are ignored
    do_write(10, 5, 3'd7);
    do_write(15, 5, 3'd7);
    do_write(3, 20, 3'd7);
    do_write(3, 31, 3'd7);

    // 6) shift the bottom row: rows 0..18 drop by one, row 0 becomes empty
    do_reset;
    fill_pattern;
    do_shift(19);
    for (x = 0; x < 10; x = x + 1)
      `CHECK(board[x*3 +: 3] == 3'd0, "row 0 must be empty after a shift")

    // 7) shift a middle row (rows below unchanged) and row 0 (only row 0 cleared)
    do_reset;
    fill_pattern;
    do_shift(10);
    do_shift(0);

    // 8) shift_row out of range is ignored
    do_shift(20);
    do_shift(31);

    // 9) shift and write in the same cycle: shift wins, the write is dropped
    we = 1; wx = 2; wy = 15; wdata = 3'd7;
    do_shift(19);

    // 10) bomb-style 3x3 clear around a corner: game_fsm may send all 9 positions,
    //     out-of-range ones (x = -1 -> 4'd15, y = 20) must not touch any cell
    do_reset;
    fill_pattern;
    for (i = -1; i <= 1; i = i + 1)
      for (j = -1; j <= 1; j = j + 1)
        do_write(0 + i, 19 + j, 3'd0);           // around (0,19)
    `CHECK(board[(18*10+2)*3 +: 3] != 3'd0, "cell (2,18) outside the bomb must stay")
    for (i = -1; i <= 1; i = i + 1)
      for (j = -1; j <= 1; j = j + 1)
        do_write(9 + i, 0 + j, 3'd0);            // around (9,0): x = 10, y = -1 -> 31
    `CHECK(board[(1*10+7)*3 +: 3] != 3'd0, "cell (7,1) outside the bomb must stay")

    // 11) reset in the middle of a game clears everything
    do_reset;

    `TB_FINISH("tb_board_memory")
  end
endmodule
