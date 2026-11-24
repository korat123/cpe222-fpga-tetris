// vga_renderer.v — owner: Nassasi
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input  [9:0]    pixel_x      from vga_sync
//   input  [9:0]    pixel_y      from vga_sync
//   input           video_on     from vga_sync
//   input  [599:0]  board        200 cells x 3 bits, index y*10+x
//   input  [2:0]    piece_type   active piece
//   input  [2:0]    next_type    next-piece preview
//   input  [1:0]    piece_rot    
//   input  [3:0]    piece_x      
//   input  [4:0]    piece_y      
//   input  [23:0]   score_bcd    
//   input  [3:0]    level        
//   input  [3:0]    combo        from score_combo
//   input  [2:0]    game_state   S_* from tetris_defs.vh (GAME OVER text)
//   input  [3:0]    charges      power-up charges
//   input           select_level SW1: selected power-up 0 = bomb, 1 = freeze
//   input           freeze_active 
//   input  [2:0]    freeze_remaining seconds
//   input           chaos_reverse active chaos effect
//   input           chaos_fast   active chaos effect
//   input  [4:0]    chaos_countdown seconds until next chaos event
//   input  [2:0]    chaos_remaining seconds left in active chaos event
//   input           paused       show 'PAUSED - SW15 OFF to resume'
//   output [3:0]    vga_r        
//   output [3:0]    vga_g        
//   output [3:0]    vga_b        
`default_nettype none

module vga_renderer (
  input  wire          clk,
  input  wire          rst,
  input  wire [9:0]    pixel_x,
  input  wire [9:0]    pixel_y,
  input  wire          video_on,
  input  wire [599:0]  board,
  input  wire [2:0]    piece_type,
  input  wire [2:0]    next_type,
  input  wire [1:0]    piece_rot,
  input  wire [3:0]    piece_x,
  input  wire [4:0]    piece_y,
  input  wire [23:0]   score_bcd,
  input  wire [3:0]    level,
  input  wire [3:0]    combo,
  input  wire [2:0]    game_state,
  input  wire [3:0]    charges,
  input  wire          select_level,
  input  wire          freeze_active,
  input  wire [2:0]    freeze_remaining,
  input  wire          chaos_reverse,
  input  wire          chaos_fast,
  input  wire [4:0]    chaos_countdown,
  input  wire [2:0]    chaos_remaining,
  input  wire          paused,
  output wire [3:0]    vga_r,
  output wire [3:0]    vga_g,
  output wire [3:0]    vga_b
);

  // TODO(Nassasi): implement. Stub outputs are tied to safe idle values.
  assign vga_r = 4'd0;
  assign vga_g = 4'd0;
  assign vga_b = 4'd0;

endmodule

`default_nettype wire
