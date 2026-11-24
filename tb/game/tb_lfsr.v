// tb_lfsr.v — self-checking testbench for lfsr
// Contract: print exactly one `TB_PASS tb_lfsr` at the end, or `TB_FAIL tb_lfsr: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_lfsr;
  reg           clk = 0;
  reg           rst = 0;
  reg           seed_load = 0;
  reg  [15:0]   seed = 0;
  reg           step = 0;
  wire [2:0]    piece_type;
  integer errors = 0;

  lfsr dut (
    .clk(clk),
    .rst(rst),
    .seed_load(seed_load),
    .seed(seed),
    .step(step),
    .piece_type(piece_type)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_lfsr.vcd"); $dumpvars(0, tb_lfsr); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_lfsr: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_lfsr")
  end
endmodule
