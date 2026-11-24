// tb_game_fsm.v — self-checking testbench for game_fsm
// Contract: print exactly one `TB_PASS tb_game_fsm` at the end, or `TB_FAIL tb_game_fsm: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_game_fsm;
  reg           clk = 0;
  reg           rst = 0;
  reg           move_left = 0;
  reg           move_right = 0;
  reg           rotate = 0;
  reg           pause = 0;
  reg           chaos_reverse = 0;
  reg           tick_fall = 0;
  reg           collide = 0;
  reg  [2:0]    new_type = 0;
  reg           bomb_req = 0;
  reg           clear_shift_req = 0;
  reg  [4:0]    clear_shift_row = 0;
  reg           clear_done = 0;
  wire [2:0]    game_state;
  wire          playing;
  wire [2:0]    piece_type;
  wire [2:0]    next_type;
  wire [1:0]    piece_rot;
  wire [3:0]    piece_x;
  wire [4:0]    piece_y;
  wire [4:0]    test_x;
  wire [4:0]    test_y;
  wire [1:0]    test_rot;
  wire          board_we;
  wire [3:0]    board_wx;
  wire [4:0]    board_wy;
  wire [2:0]    board_wdata;
  wire          board_shift_en;
  wire [4:0]    board_shift_row;
  wire          start_clear;
  wire          piece_locked;
  wire          bomb_done;
  wire          lfsr_step;
  integer errors = 0;

  game_fsm dut (
    .clk(clk),
    .rst(rst),
    .move_left(move_left),
    .move_right(move_right),
    .rotate(rotate),
    .pause(pause),
    .chaos_reverse(chaos_reverse),
    .tick_fall(tick_fall),
    .collide(collide),
    .new_type(new_type),
    .bomb_req(bomb_req),
    .clear_shift_req(clear_shift_req),
    .clear_shift_row(clear_shift_row),
    .clear_done(clear_done),
    .game_state(game_state),
    .playing(playing),
    .piece_type(piece_type),
    .next_type(next_type),
    .piece_rot(piece_rot),
    .piece_x(piece_x),
    .piece_y(piece_y),
    .test_x(test_x),
    .test_y(test_y),
    .test_rot(test_rot),
    .board_we(board_we),
    .board_wx(board_wx),
    .board_wy(board_wy),
    .board_wdata(board_wdata),
    .board_shift_en(board_shift_en),
    .board_shift_row(board_shift_row),
    .start_clear(start_clear),
    .piece_locked(piece_locked),
    .bomb_done(bomb_done),
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
