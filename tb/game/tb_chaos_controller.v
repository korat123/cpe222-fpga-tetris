// tb_chaos_controller.v — self-checking testbench for chaos_controller
// Contract: print exactly one `TB_PASS tb_chaos_controller` at the end, or `TB_FAIL tb_chaos_controller: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_chaos_controller;
  reg           clk = 0;
  reg           rst = 0;
  reg           tick_second = 0;
  reg           playing = 0;
  reg  [1:0]    rand_bits = 0;
  wire          chaos_reverse;
  wire          chaos_fast;
  wire [4:0]    chaos_countdown;
  wire [2:0]    chaos_remaining;
  integer errors = 0;

  chaos_controller dut (
    .clk(clk),
    .rst(rst),
    .tick_second(tick_second),
    .playing(playing),
    .rand_bits(rand_bits),
    .chaos_reverse(chaos_reverse),
    .chaos_fast(chaos_fast),
    .chaos_countdown(chaos_countdown),
    .chaos_remaining(chaos_remaining)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_chaos_controller.vcd"); $dumpvars(0, tb_chaos_controller); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_chaos_controller: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_chaos_controller")
  end
endmodule
