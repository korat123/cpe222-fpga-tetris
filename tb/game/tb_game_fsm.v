// tb_game_fsm.v — self-checking testbench for game_fsm
// Contract: print exactly one `TB_PASS tb_game_fsm` at the end, or `TB_FAIL tb_game_fsm: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_game_fsm;
  reg           clk = 0;
  reg           rst = 0;
  reg  [4:0]    btn_pulse = 0;
  reg           tick_fall = 0;
  reg           collide = 0;
  reg           clear_done = 0;
  reg  [2:0]    new_type = 0;
  wire [2:0]    game_state;
  wire [2:0]    piece_type;
  wire [2:0]    next_type;
  wire [1:0]    piece_rot;
  wire [3:0]    piece_x;
  wire [4:0]    piece_y;
  wire [4:0]    test_x;
  wire [4:0]    test_y;
  wire [1:0]    test_rot;
  wire          lock_we;
  wire          start_clear;
  wire          lfsr_step;
  integer errors = 0;

  game_fsm dut (
    .clk(clk),
    .rst(rst),
    .btn_pulse(btn_pulse),
    .tick_fall(tick_fall),
    .collide(collide),
    .clear_done(clear_done),
    .new_type(new_type),
    .game_state(game_state),
    .piece_type(piece_type),
    .next_type(next_type),
    .piece_rot(piece_rot),
    .piece_x(piece_x),
    .piece_y(piece_y),
    .test_x(test_x),
    .test_y(test_y),
    .test_rot(test_rot),
    .lock_we(lock_we),
    .start_clear(start_clear),
    .lfsr_step(lfsr_step)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_game_fsm.vcd"); $dumpvars(0, tb_game_fsm); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_game_fsm: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_game_fsm")
  end
endmodule
