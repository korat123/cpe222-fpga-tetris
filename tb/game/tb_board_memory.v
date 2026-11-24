// tb_board_memory.v — self-checking testbench for board_memory
// Contract: print exactly one `TB_PASS tb_board_memory` at the end, or `TB_FAIL tb_board_memory: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_board_memory;
  reg           clk = 0;
  reg           rst = 0;
  reg           we = 0;
  reg  [3:0]    wx = 0;
  reg  [4:0]    wy = 0;
  reg  [2:0]    wdata = 0;
  reg           shift_en = 0;
  reg  [4:0]    shift_row = 0;
  wire [599:0]  board;
  integer errors = 0;

  board_memory dut (
    .clk(clk),
    .rst(rst),
    .we(we),
    .wx(wx),
    .wy(wy),
    .wdata(wdata),
    .shift_en(shift_en),
    .shift_row(shift_row),
    .board(board)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_board_memory.vcd"); $dumpvars(0, tb_board_memory); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_board_memory: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_board_memory")
  end
endmodule
