// seven_segment.v — owner: Pholawath
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input  [23:0]   score_bcd    6 BCD digits
//   output [7:0]    an           digit enables, active-low
//   output [6:0]    seg          segments g..a, active-low
`default_nettype none

module seven_segment (
  input  wire          clk,
  input  wire          rst,
  input  wire [23:0]   score_bcd,
  output wire [7:0]    an,
  output wire [6:0]    seg
);

  // TODO(Pholawath): implement. Stub outputs are tied to safe idle values.
  assign an = 8'hFF;
  assign seg = 7'h7F;

endmodule

`default_nettype wire
