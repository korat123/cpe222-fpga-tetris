// tb_seven_segment.v — self-checking testbench for seven_segment
// Contract: print exactly one `TB_PASS tb_seven_segment` at the end, or `TB_FAIL tb_seven_segment: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_seven_segment;
  reg           clk = 0;
  reg           rst = 0;
  reg  [23:0]   score_bcd = 0;
  wire [7:0]    an;
  wire [6:0]    seg;
  integer errors = 0;

  seven_segment dut (
    .clk(clk),
    .rst(rst),
    .score_bcd(score_bcd),
    .an(an),
    .seg(seg)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_seven_segment.vcd"); $dumpvars(0, tb_seven_segment); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_seven_segment: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_seven_segment")
  end
endmodule
