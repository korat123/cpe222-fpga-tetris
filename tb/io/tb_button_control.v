// tb_button_control.v — self-checking testbench for button_control
// Contract: print exactly one `TB_PASS tb_button_control` at the end, or `TB_FAIL tb_button_control: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_button_control;
  reg           clk = 0;
  reg           rst = 0;
  reg  [4:0]    btn_raw = 0;
  wire [4:0]    btn_pulse;
  wire [4:0]    btn_level;
  integer errors = 0;

  button_control dut (
    .clk(clk),
    .rst(rst),
    .btn_raw(btn_raw),
    .btn_pulse(btn_pulse),
    .btn_level(btn_level)
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
