// clock_enable.v — owner: Korat
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz clock
//   input           rst          sync active-high reset
//   input  [3:0]    level        current level 1-15
//   input           soft_drop    BTND held
//   output          tick_pixel   1-cycle pulse every 4 clocks (25 MHz)
//   output          tick_fall    1-cycle pulse: gravity step
`default_nettype none

module clock_enable (
  input  wire          clk,
  input  wire          rst,
  input  wire [3:0]    level,
  input  wire          soft_drop,
  output wire          tick_pixel,
  output wire          tick_fall
);

  // TODO(Korat): implement. Stub outputs are tied to safe idle values.
  assign tick_pixel = 1'b0;
  assign tick_fall = 1'b0;

endmodule

`default_nettype wire
