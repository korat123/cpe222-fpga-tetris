// lfsr.v — owner: Teerawit
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input           seed_load    1-cycle pulse
//   input  [15:0]   seed         from free-running counter at start
//   input           step         1-cycle pulse: next piece
//   output [2:0]    piece_type   always 1-7
//   output [1:0]    rand_bits    free-running random bits for chaos_controller
`default_nettype none

module lfsr (
  input  wire          clk,
  input  wire          rst,
  input  wire          seed_load,
  input  wire [15:0]   seed,
  input  wire          step,
  output wire [2:0]    piece_type,
  output wire [1:0]    rand_bits
);

  // TODO(Teerawit): implement. Stub outputs are tied to safe idle values.
  assign piece_type = 3'd0;
  assign rand_bits = 2'd0;

endmodule

`default_nettype wire
