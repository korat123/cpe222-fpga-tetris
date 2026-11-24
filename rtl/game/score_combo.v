// score_combo.v — owner: Pholawath
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input           clear_done   1-cycle pulse from line_clear
//   input  [2:0]    lines_cleared 0-4, valid with clear_done
//   input           piece_locked 1-cycle pulse from game_fsm; a lock with no clear resets combo
//   output [23:0]   score_bcd    6 BCD digits: +100/300/500/800 + combo bonus
//   output [7:0]    lines        total cleared lines
//   output [3:0]    level        1 + lines/LINES_PER_LEVEL, max 15
//   output [3:0]    combo        consecutive clearing pieces
`default_nettype none

module score_combo (
  input  wire          clk,
  input  wire          rst,
  input  wire          clear_done,
  input  wire [2:0]    lines_cleared,
  input  wire          piece_locked,
  output wire [23:0]   score_bcd,
  output wire [7:0]    lines,
  output wire [3:0]    level,
  output wire [3:0]    combo
);

  // TODO(Pholawath): implement. Stub outputs are tied to safe idle values.
  assign score_bcd = 24'd0;
  assign lines = 8'd0;
  assign level = 4'd0;
  assign combo = 4'd0;

endmodule

`default_nettype wire
