// tb_line_clear.v — self-checking testbench for line_clear
// Contract: print exactly one `TB_PASS tb_line_clear` at the end, or `TB_FAIL tb_line_clear: <reason>`.
// line_clear is connected to the real board_memory the way game_fsm will connect it:
// shift_req/shift_row -> shift_en/shift_row. The forwarding is tested both direct (same cycle)
// and through one register (fwd_delay = 1), the two cases SHIFT_WAIT_CLKS = 2 must cover.
// After every run the board is compared with a reference model that removes full rows.
// A monitor checks on every clock: shift_req and done are 1-cycle pulses, shift_req only while
// busy, done only when busy has just dropped, exactly one done per start.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_line_clear;
  reg           clk = 0;
  reg           rst = 0;
  reg           start = 0;
  wire [599:0]  board;
  wire          busy;
  wire          done;
  wire          shift_req;
  wire [4:0]    shift_row;
  wire [2:0]    lines_cleared;
  integer errors = 0;

  // board_memory write port, driven by the tb to load a board
  reg           we = 0;
  reg  [3:0]    wx = 0;
  reg  [4:0]    wy = 0;
  reg  [2:0]    wdata = 0;

  // shift forwarding: like game_fsm, either direct or through one register
  reg           fwd_delay = 0;
  reg           shift_req_d = 0;
  reg  [4:0]    shift_row_d = 0;
  always @(posedge clk) begin
    shift_req_d <= shift_req;
    shift_row_d <= shift_row;
  end
  wire          mem_shift_en  = fwd_delay ? shift_req_d : shift_req;
  wire [4:0]    mem_shift_row = fwd_delay ? shift_row_d : shift_row;

  line_clear dut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .board(board),
    .busy(busy),
    .done(done),
    .shift_req(shift_req),
    .shift_row(shift_row),
    .lines_cleared(lines_cleared)
  );

  board_memory u_board_memory (
    .clk(clk),
    .rst(rst),
    .we(we),
    .wx(wx),
    .wy(wy),
    .wdata(wdata),
    .shift_en(mem_shift_en),
    .shift_row(mem_shift_row),
    .board(board)
  );

  always #5 clk = ~clk;  // 100 MHz

  // ---------- monitor (every clock) ----------
  reg     shift_req_q = 0, done_q = 0, busy_q = 0;
  integer n_shift = 0, n_done = 0, n_mon_err = 0;
  always @(posedge clk) begin
    if (!rst) begin
      if (shift_req && shift_req_q) n_mon_err = n_mon_err + 1;  // longer than 1 cycle
      if (done && done_q)           n_mon_err = n_mon_err + 1;
      if (shift_req && !busy)       n_mon_err = n_mon_err + 1;
      if (done && (busy || !busy_q)) n_mon_err = n_mon_err + 1; // done exactly when busy falls
      if (shift_req) n_shift = n_shift + 1;
      if (done)      n_done  = n_done + 1;
    end
    shift_req_q <= shift_req;
    done_q      <= done;
    busy_q      <= busy;
  end

  // ---------- reference model ----------
  reg [2:0] grid [0:9][0:19];        // board the tb wants to load: grid[x][y]
  reg [599:0] exp_board;
  integer exp_lines;

  // remove every full row (rows above drop), count them
  task model_clear;
    integer x, y, src, full;
    reg [2:0] tmp [0:9][0:19];
    begin
      exp_lines = 0;
      for (y = 0; y < 20; y = y + 1) for (x = 0; x < 10; x = x + 1) tmp[x][y] = 3'd0;
      src = 19;
      for (y = 19; y >= 0; y = y - 1) begin
        full = 1;
        for (x = 0; x < 10; x = x + 1) if (grid[x][y] == 3'd0) full = 0;
        if (full) exp_lines = exp_lines + 1;
        else begin
          for (x = 0; x < 10; x = x + 1) tmp[x][src] = grid[x][y];
          src = src - 1;
        end
      end
      exp_board = 600'd0;
      for (y = 0; y < 20; y = y + 1)
        for (x = 0; x < 10; x = x + 1) exp_board[(y*10 + x)*3 +: 3] = tmp[x][y];
    end
  endtask

  task cells_empty;
    integer x, y;
    begin
      for (y = 0; y < 20; y = y + 1) for (x = 0; x < 10; x = x + 1) grid[x][y] = 3'd0;
    end
  endtask

  task row_full(input integer y, input [2:0] v);
    integer x;
    begin
      for (x = 0; x < 10; x = x + 1) grid[x][y] = v;
    end
  endtask

  // full except one hole
  task row_hole(input integer y, input integer hole);
    integer x;
    begin
      for (x = 0; x < 10; x = x + 1) grid[x][y] = (x == hole) ? 3'd0 : 3'd1 + (x % 7);
    end
  endtask

  // reset board_memory and line_clear, then write every non-empty cell
  task load_board;
    integer x, y;
    begin
      @(posedge clk); #1 rst = 1;
      @(posedge clk); #1 rst = 0;
      for (y = 0; y < 20; y = y + 1)
        for (x = 0; x < 10; x = x + 1)
          if (grid[x][y] != 3'd0) begin
            we = 1; wx = x; wy = y; wdata = grid[x][y];
            @(posedge clk); #1;
          end
      we = 0;
    end
  endtask

  // load, pulse start, wait for done, compare. extra_start = also pulse start while busy.
  task run_case(input [8*40-1:0] what, input extra_start);
    integer cyc, shifts0, done0, err0;
    begin
      load_board;
      model_clear;
      shifts0 = n_shift; done0 = n_done; err0 = n_mon_err;
      `CHECK(busy == 1'b0, "busy low before start")
      start = 1; @(posedge clk); #1 start = 0;
      `CHECK(busy == 1'b1, "busy high the cycle after start")
      if (extra_start) begin
        repeat (3) @(posedge clk);
        #1 start = 1; @(posedge clk); #1 start = 0;
      end
      cyc = 0;
      while (!done && cyc < 400) begin @(posedge clk); #1 cyc = cyc + 1; end
      if (!done) begin
        `CHECK(1'b0, what)
        $display("  %0s: no done within 400 cycles (fwd_delay=%0d)", what, fwd_delay);
      end else begin
        if (lines_cleared !== exp_lines[2:0] || board !== exp_board ||
            n_shift - shifts0 != exp_lines) begin
          `CHECK(1'b0, what)
          $display("  %0s (fwd_delay=%0d): lines=%0d exp=%0d shifts=%0d board %0s",
                   what, fwd_delay, lines_cleared, exp_lines, n_shift - shifts0,
                   (board === exp_board) ? "ok" : "WRONG");
        end
      end
      repeat (10) @(posedge clk); #1;
      `CHECK(busy == 1'b0, "busy low after done")
      `CHECK(n_done - done0 == 1, "exactly one done per start")
      `CHECK(n_mon_err == err0, "pulse/busy rules (monitor)")
      `CHECK(lines_cleared === exp_lines[2:0], "lines_cleared still valid after done")
    end
  endtask

  integer m, i, x, y;

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_line_clear.vcd"); $dumpvars(0, tb_line_clear); end
    rst = 1; repeat (4) @(posedge clk); #1 rst = 0;
    `CHECK(busy == 1'b0 && done == 1'b0 && shift_req == 1'b0, "idle after reset")

    for (m = 0; m < 2; m = m + 1) begin
      fwd_delay = m;

      cells_empty;                                   run_case("empty board", 0);
      cells_empty; row_hole(19, 4); row_hole(18, 0); run_case("no full row (holes)", 0);
      cells_empty; row_full(19, 3);                  run_case("1 row at the bottom", 0);
      cells_empty; row_full(19, 1); row_full(18, 2); row_hole(17, 9);
                                                     run_case("2 rows + partial row drops", 0);
      cells_empty; row_full(19, 1); row_full(18, 2); row_full(17, 3); row_hole(16, 5);
                                                     run_case("3 rows", 0);
      cells_empty; row_full(19, 7); row_full(18, 6); row_full(17, 5); row_full(16, 4);
      row_hole(15, 2); row_hole(14, 8);              run_case("4 rows (tetris), rows above drop", 0);
      cells_empty; row_full(19, 1); row_hole(18, 3); row_full(17, 2); row_hole(16, 6);
                                                     run_case("non-adjacent rows 19 and 17", 0);
      cells_empty; row_full(10, 4); row_hole(9, 1); row_hole(11, 2);
                                                     run_case("one row in the middle", 0);
      cells_empty; row_full(0, 5);                   run_case("top row (row 0)", 0);
      cells_empty; row_full(0, 1); row_full(5, 2); row_full(10, 3); row_full(15, 4); row_full(19, 5);
      row_hole(18, 0);                               run_case("5 scattered rows", 0);
      cells_empty; row_full(19, 2); row_full(18, 2); row_hole(17, 1);
                                                     run_case("start pulsed again while busy", 1);

      // random boards: each row full with probability 1/3, otherwise random with a hole
      for (i = 0; i < 25; i = i + 1) begin
        cells_empty;
        for (y = 13; y < 20; y = y + 1) begin   // at most 7 full rows (lines_cleared is 3 bits)
          if (({$random} % 3) == 0) row_full(y, 1 + ({$random} % 7));
          else for (x = 0; x < 10; x = x + 1) grid[x][y] = $random;
          if (grid[0][y] != 0 && grid[1][y] != 0 && ({$random} % 2)) grid[{$random} % 10][y] = 3'd0;
        end
        run_case("random board", 0);
      end
    end

    // reset in the middle of a run stops it
    fwd_delay = 0;
    cells_empty; row_full(19, 1); row_full(18, 1);
    load_board;
    start = 1; @(posedge clk); #1 start = 0;
    @(posedge clk); #1 rst = 1; @(posedge clk); #1 rst = 0;
    `CHECK(busy == 1'b0 && done == 1'b0 && shift_req == 1'b0, "reset mid-run returns to idle")
    repeat (60) @(posedge clk); #1;
    `CHECK(busy == 1'b0, "stays idle after reset (no start)")

    `TB_FINISH("tb_line_clear")
  end
endmodule
