// game_fsm.v — owner: Teerawit
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input           move_left    1-cycle pulse from button_control
//   input           move_right   1-cycle pulse from button_control
//   input           rotate       1-cycle pulse from button_control
//   input           pause        level: in FALL ignore actions and hold the piece
//   input           chaos_reverse level: swap move_left/move_right
//   input           tick_fall    1-cycle pulse from timers
//   input           collide      from collision for test_x/test_y/test_rot
//   input  [2:0]    new_type     from lfsr
//   input           bomb_req     level from powerup_controller; served at a safe point in FALL
//   input           clear_shift_req 1-cycle pulse from line_clear
//   input  [4:0]    clear_shift_row row to remove, valid with clear_shift_req
//   input           clear_done   1-cycle pulse from line_clear
//   output [2:0]    game_state   S_RESET S_SPAWN S_FALL S_LOCK S_CLEAR S_GAME_OVER S_BOMB
//   output          playing      level: game running (not RESET / GAME_OVER)
//   output [2:0]    piece_type   
//   output [2:0]    next_type    
//   output [1:0]    piece_rot    
//   output [3:0]    piece_x      
//   output [4:0]    piece_y      
//   output [4:0]    test_x       signed, to collision
//   output [4:0]    test_y       to collision
//   output [1:0]    test_rot     to tetromino (test copy)
//   output          board_we     1-cycle: write one cell (lock = piece type, bomb = 0)
//   output [3:0]    board_wx     
//   output [4:0]    board_wy     
//   output [2:0]    board_wdata  
//   output          board_shift_en 1-cycle: remove board_shift_row
//   output [4:0]    board_shift_row 
//   output          start_clear  1-cycle pulse to line_clear
//   output          piece_locked 1-cycle pulse per locked piece (score_combo)
//   output          bomb_done    1-cycle pulse to powerup_controller
//   output          lfsr_step    1-cycle pulse
`default_nettype none

module game_fsm (
  input  wire          clk,
  input  wire          rst,
  input  wire          move_left,
  input  wire          move_right,
  input  wire          rotate,
  input  wire          pause,
  input  wire          chaos_reverse,
  input  wire          tick_fall,
  input  wire          collide,
  input  wire [2:0]    new_type,
  input  wire          bomb_req,
  input  wire          clear_shift_req,
  input  wire [4:0]    clear_shift_row,
  input  wire          clear_done,
  output wire [2:0]    game_state,
  output wire          playing,
  output wire [2:0]    piece_type,
  output wire [2:0]    next_type,
  output wire [1:0]    piece_rot,
  output wire [3:0]    piece_x,
  output wire [4:0]    piece_y,
  output wire [4:0]    test_x,
  output wire [4:0]    test_y,
  output wire [1:0]    test_rot,
  output wire          board_we,
  output wire [3:0]    board_wx,
  output wire [4:0]    board_wy,
  output wire [2:0]    board_wdata,
  output wire          board_shift_en,
  output wire [4:0]    board_shift_row,
  output wire          start_clear,
  output wire          piece_locked,
  output wire          bomb_done,
  output wire          lfsr_step
);

  // TODO(Teerawit): implement. Stub outputs are tied to safe idle values.
  assign game_state = 3'd0;
  assign playing = 1'b0;
  assign piece_type = 3'd0;
  assign next_type = 3'd0;
  assign piece_rot = 2'd0;
  assign piece_x = 4'd0;
  assign piece_y = 5'd0;
  assign test_x = 5'd0;
  assign test_y = 5'd0;
  assign test_rot = 2'd0;
  assign board_we = 1'b0;
  assign board_wx = 4'd0;
  assign board_wy = 5'd0;
  assign board_wdata = 3'd0;
  assign board_shift_en = 1'b0;
  assign board_shift_row = 5'd0;
  assign start_clear = 1'b0;
  assign piece_locked = 1'b0;
  assign bomb_done = 1'b0;
  assign lfsr_step = 1'b0;

endmodule

`default_nettype wire
