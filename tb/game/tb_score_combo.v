// tb_score_combo.v — self-checking testbench for score_combo
// Contract: print exactly one `TB_PASS tb_score_combo` at the end, or `TB_FAIL tb_score_combo: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_score_combo;
  reg           clk = 0;
  reg           rst = 0;
  reg           clear_done = 0;
  reg  [2:0]    lines_cleared = 0;
  reg           piece_locked = 0;
  wire [23:0]   score_bcd;
  wire [7:0]    lines;
  wire [3:0]    level;
  wire [3:0]    combo;
  integer errors = 0;

  score_combo dut (
    .clk(clk),
    .rst(rst),
    .clear_done(clear_done),
    .lines_cleared(lines_cleared),
    .piece_locked(piece_locked),
    .score_bcd(score_bcd),
    .lines(lines),
    .level(level),
    .combo(combo)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_score_combo.vcd"); $dumpvars(0, tb_score_combo); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_score_combo: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_score_combo")
  end
endmodule
