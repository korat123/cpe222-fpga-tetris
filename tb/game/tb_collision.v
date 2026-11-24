// tb_collision.v — self-checking testbench for collision
// Contract: print exactly one `TB_PASS tb_collision` at the end, or `TB_FAIL tb_collision: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_collision;
  reg  [4:0]    test_x = 0;
  reg  [4:0]    test_y = 0;
  reg  [15:0]   cells = 0;
  reg  [599:0]  board = 0;
  wire          collide;
  integer errors = 0;

  collision dut (
    .test_x(test_x),
    .test_y(test_y),
    .cells(cells),
    .board(board),
    .collide(collide)
  );


  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_collision.vcd"); $dumpvars(0, tb_collision); end
    #100;
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_collision: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_collision")
  end
endmodule
