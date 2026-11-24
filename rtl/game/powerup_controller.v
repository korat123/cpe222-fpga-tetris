// powerup_controller.v — owner: Pornnapat
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input           tick_second  from timers (already off while paused)
//   input           playing      level from game_fsm
//   input           pause        level: ignore use_bomb/use_freeze while paused (not queued)
//   input           clear_done   1-cycle pulse from line_clear
//   input  [2:0]    lines_cleared 0-4, valid with clear_done
//   input           use_bomb     1-cycle pulse from button_control
//   input           use_freeze   1-cycle pulse from button_control
//   input           bomb_done    1-cycle pulse from game_fsm: bomb finished
//   output [3:0]    charges      0-MAX_CHARGES; +1 per LINES_PER_CHARGE lines
//   output          bomb_req     level: held until bomb_done
//   output          freeze_active level: FREEZE_LEN_S seconds
//   output [2:0]    freeze_remaining seconds left (UI)
//   output          no_charge    1-cycle pulse: request with 0 charges (UI flash)
`default_nettype none

module powerup_controller (
  input  wire          clk,
  input  wire          rst,
  input  wire          tick_second,
  input  wire          playing,
  input  wire          pause,
  input  wire          clear_done,
  input  wire [2:0]    lines_cleared,
  input  wire          use_bomb,
  input  wire          use_freeze,
  input  wire          bomb_done,
  output wire [3:0]    charges,
  output wire          bomb_req,
  output wire          freeze_active,
  output wire [2:0]    freeze_remaining,
  output wire          no_charge
);

  // TODO(Pornnapat): implement. Stub outputs are tied to safe idle values.
  assign charges = 4'd0;
  assign bomb_req = 1'b0;
  assign freeze_active = 1'b0;
  assign freeze_remaining = 3'd0;
  assign no_charge = 1'b0;

endmodule

`default_nettype wire
