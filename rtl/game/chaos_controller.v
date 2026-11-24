// chaos_controller.v — owner: Teerawit
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input           tick_second  from timers (already off while paused)
//   input           playing      level from game_fsm: count only while a game runs
//   input  [1:0]    rand_bits    from lfsr; picks the event
//   output          chaos_reverse level: left/right swapped (used by game_fsm)
//   output          chaos_fast   level: double fall speed (used by timers)
//   output [4:0]    chaos_countdown seconds until the next event (UI)
//   output [2:0]    chaos_remaining seconds left in the active event, 0 = none (UI)
`default_nettype none

module chaos_controller (
  input  wire          clk,
  input  wire          rst,
  input  wire          tick_second,
  input  wire          playing,
  input  wire [1:0]    rand_bits,
  output wire          chaos_reverse,
  output wire          chaos_fast,
  output wire [4:0]    chaos_countdown,
  output wire [2:0]    chaos_remaining
);

  // TODO(Teerawit): implement. Stub outputs are tied to safe idle values.
  assign chaos_reverse = 1'b0;
  assign chaos_fast = 1'b0;
  assign chaos_countdown = 5'd0;
  assign chaos_remaining = 3'd0;

endmodule

`default_nettype wire
