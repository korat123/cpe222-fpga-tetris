// vga_sync.v — owner: Korat
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          
//   input           rst          
//   input           tick_pixel   25 MHz enable
//   output          hsync        active-low
//   output          vsync        active-low
//   output          video_on     1 inside 640x480
//   output [9:0]    pixel_x      0-799
//   output [9:0]    pixel_y      0-524
`default_nettype none

module vga_sync (
  input  wire          clk,
  input  wire          rst,
  input  wire          tick_pixel,
  output wire          hsync,
  output wire          vsync,
  output wire          video_on,
  output wire [9:0]    pixel_x,
  output wire [9:0]    pixel_y
);

  // TODO(Korat): implement. Stub outputs are tied to safe idle values.
  assign hsync = 1'b1;
  assign vsync = 1'b1;
  assign video_on = 1'b0;
  assign pixel_x = 10'd0;
  assign pixel_y = 10'd0;

endmodule

`default_nettype wire
