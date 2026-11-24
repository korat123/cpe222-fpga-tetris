// vga_renderer.v — owner: Korat
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          
//   input           rst          
//   input  [9:0]    pixel_x      
//   input  [9:0]    pixel_y      
//   input           video_on     
//   input  [599:0]  board        200 cells x 3 bits, index y*10+x
//   input  [2:0]    piece_type   
//   input  [2:0]    next_type    
//   input  [1:0]    piece_rot    
//   input  [3:0]    piece_x      
//   input  [4:0]    piece_y      
//   input  [23:0]   score_bcd    
//   input  [3:0]    level        
//   input  [2:0]    game_state   
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
  input  wire [2:0]    game_state,
  output wire [3:0]    vga_r,
  output wire [3:0]    vga_g,
  output wire [3:0]    vga_b
);

  // TODO(Korat): implement. Stub outputs are tied to safe idle values.
  assign vga_r = 4'd0;
  assign vga_g = 4'd0;
  assign vga_b = 4'd0;

endmodule

`default_nettype wire
