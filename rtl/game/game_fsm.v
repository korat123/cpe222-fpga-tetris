// game_fsm.v — owner: Pornnapat
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          
//   input           rst          
//   input  [4:0]    btn_pulse    
//   input           tick_fall    
//   input           collide      
//   input           clear_done   
//   input  [2:0]    new_type     from lfsr
//   output [2:0]    game_state   IDLE SPAWN FALL LOCK CLEAR GAME_OVER
//   output [2:0]    piece_type   
//   output [2:0]    next_type    
//   output [1:0]    piece_rot    
//   output [3:0]    piece_x      
//   output [4:0]    piece_y      
//   output [4:0]    test_x       signed
//   output [4:0]    test_y       
//   output [1:0]    test_rot     
//   output          lock_we      
//   output          start_clear  
//   output          lfsr_step    
`default_nettype none

module game_fsm (
  input  wire          clk,
  input  wire          rst,
  input  wire [4:0]    btn_pulse,
  input  wire          tick_fall,
  input  wire          collide,
  input  wire          clear_done,
  input  wire [2:0]    new_type,
  output wire [2:0]    game_state,
  output wire [2:0]    piece_type,
  output wire [2:0]    next_type,
  output wire [1:0]    piece_rot,
  output wire [3:0]    piece_x,
  output wire [4:0]    piece_y,
  output wire [4:0]    test_x,
  output wire [4:0]    test_y,
  output wire [1:0]    test_rot,
  output wire          lock_we,
  output wire          start_clear,
  output wire          lfsr_step
);

  // TODO(Pornnapat): implement. Stub outputs are tied to safe idle values.
  assign game_state = 3'd0;
  assign piece_type = 3'd0;
  assign next_type = 3'd0;
  assign piece_rot = 2'd0;
  assign piece_x = 4'd0;
  assign piece_y = 5'd0;
  assign test_x = 5'd0;
  assign test_y = 5'd0;
  assign test_rot = 2'd0;
  assign lock_we = 1'b0;
  assign start_clear = 1'b0;
  assign lfsr_step = 1'b0;

endmodule

`default_nettype wire
