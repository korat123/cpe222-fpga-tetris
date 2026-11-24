// tb_clock_enable.v — self-checking testbench for clock_enable
// Contract: print exactly one `TB_PASS tb_clock_enable` at the end, or `TB_FAIL tb_clock_enable: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_clock_enable;
  reg           clk = 0;
  reg           rst = 0;
  reg  [3:0]    level = 0;
  reg           soft_drop = 0;
  wire          tick_pixel;
  wire          tick_fall;
  integer errors = 0;

  clock_enable dut (
    .clk(clk),
    .rst(rst),
    .level(level),
    .soft_drop(soft_drop),
    .tick_pixel(tick_pixel),
    .tick_fall(tick_fall)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_clock_enable.vcd"); $dumpvars(0, tb_clock_enable); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_clock_enable: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_clock_enable")
  end
endmodule
