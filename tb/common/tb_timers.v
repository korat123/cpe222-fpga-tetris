// tb_timers.v — self-checking testbench for timers
// Contract: print exactly one `TB_PASS tb_timers` at the end, or `TB_FAIL tb_timers: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_timers;
  reg           clk = 0;
  reg           rst = 0;
  reg  [3:0]    level = 0;
  reg           soft_drop = 0;
  reg           freeze_active = 0;
  reg           chaos_fast = 0;
  reg           pause = 0;
  reg           demo_mode = 0;
  wire          tick_pixel;
  wire          tick_fall;
  wire          tick_second;
  integer errors = 0;

  timers dut (
    .clk(clk),
    .rst(rst),
    .level(level),
    .soft_drop(soft_drop),
    .freeze_active(freeze_active),
    .chaos_fast(chaos_fast),
    .pause(pause),
    .demo_mode(demo_mode),
    .tick_pixel(tick_pixel),
    .tick_fall(tick_fall),
    .tick_second(tick_second)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_timers.vcd"); $dumpvars(0, tb_timers); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_timers: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_timers")
  end
endmodule
