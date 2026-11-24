// tb_line_clear.v — self-checking testbench for line_clear
// Contract: print exactly one `TB_PASS tb_line_clear` at the end, or `TB_FAIL tb_line_clear: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_line_clear;
  reg           clk = 0;
  reg           rst = 0;
  reg           start = 0;
  reg  [599:0]  board = 0;
  wire          busy;
  wire          done;
  wire          shift_req;
  wire [4:0]    shift_row;
  wire [2:0]    lines_cleared;
  integer errors = 0;

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

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_line_clear.vcd"); $dumpvars(0, tb_line_clear); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_line_clear: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_line_clear")
  end
endmodule
