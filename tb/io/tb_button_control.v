// tb_button_control.v — self-checking testbench for button_control
// Contract: print exactly one `TB_PASS tb_button_control` at the end, or `TB_FAIL tb_button_control: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_button_control;
  reg           clk = 0;
  reg           rst = 0;
  reg  [4:0]    btn_raw = 0;
  reg           sw_select = 0;
  reg           sw_pause = 0;
  reg           sw_demo = 0;
  reg  [5:0]    host_keys = 0;
  reg           link_ok = 0;
  wire          move_left;
  wire          move_right;
  wire          rotate;
  wire          soft_drop;
  wire          use_bomb;
  wire          use_freeze;
  wire          pause_level;
  wire          select_level;
  wire          demo_level;
  integer errors = 0;

  button_control #(.REPEAT_DELAY_CLKS(20), .REPEAT_RATE_CLKS(8)) dut (
    .clk(clk),
    .rst(rst),
    .btn_raw(btn_raw),
    .sw_select(sw_select),
    .sw_pause(sw_pause),
    .sw_demo(sw_demo),
    .host_keys(host_keys),
    .link_ok(link_ok),
    .move_left(move_left),
    .move_right(move_right),
    .rotate(rotate),
    .soft_drop(soft_drop),
    .use_bomb(use_bomb),
    .use_freeze(use_freeze),
    .pause_level(pause_level),
    .select_level(select_level),
    .demo_level(demo_level)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_button_control.vcd"); $dumpvars(0, tb_button_control); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_button_control: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_button_control")
  end
endmodule
