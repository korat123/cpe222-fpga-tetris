// tb_tetromino.v — self-checking testbench for tetromino
// Contract: print exactly one `TB_PASS tb_tetromino` at the end, or `TB_FAIL tb_tetromino: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_tetromino;
  reg  [2:0]    piece_type = 0;
  reg  [1:0]    piece_rot = 0;
  wire [15:0]   cells;
  integer errors = 0;

  tetromino dut (
    .piece_type(piece_type),
    .piece_rot(piece_rot),
    .cells(cells)
  );


  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_tetromino.vcd"); $dumpvars(0, tb_tetromino); end
    #100;
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_tetromino: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_tetromino")
  end
endmodule
