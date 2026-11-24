// timers.v — owner: Teerawit
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input  [3:0]    level        level 1-15 from score_combo (sets fall speed)
//   input           soft_drop    level: soft drop held -> faster tick_fall
//   input           freeze_active level: from powerup_controller -> no tick_fall
//   input           chaos_fast   level: from chaos_controller -> tick_fall twice as often
//   input           pause        level: SW15 paused -> no tick_fall, no tick_second
//   input           demo_mode    level: SW2 -> tick_second every DEMO_CLKS_PER_SECOND
//   output          tick_pixel   1-cycle pulse every 4 clocks (25 MHz); never gated
//   output          tick_fall    1-cycle pulse: one gravity step
//   output          tick_second  1-cycle pulse every game second; off while paused
`default_nettype none

module timers (
  input  wire          clk,
  input  wire          rst,
  input  wire [3:0]    level,
  input  wire          soft_drop,
  input  wire          freeze_active,
  input  wire          chaos_fast,
  input  wire          pause,
  input  wire          demo_mode,
  output wire          tick_pixel,
  output wire          tick_fall,
  output wire          tick_second
);

  // TODO(Teerawit): implement. Stub outputs are tied to safe idle values.
  assign tick_pixel = 1'b0;
  assign tick_fall = 1'b0;
  assign tick_second = 1'b0;

endmodule

`default_nettype wire
