// button_control.v — owner: Pholawath
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   parameter REPEAT_DELAY_CLKS = 20_000_000  hold time before L/R auto-repeat (200 ms)
//   parameter REPEAT_RATE_CLKS = 8_000_000  L/R auto-repeat period (80 ms)
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input  [4:0]    btn_raw      raw board buttons {C,D,U,R,L}, asynchronous
//   input           sw_select    raw SW1: 0 = bomb, 1 = freeze (BTNC only)
//   input           sw_pause     raw SW15: 1 = paused
//   input           sw_demo      raw SW2: 1 = demo timer
//   input  [5:0]    host_keys    from host_input, level {FREEZE,BOMB,SOFT_DROP,ROTATE,RIGHT,LEFT}
//   input           link_ok      from host_input: 1 = laptop connected
//   output          move_left    1-cycle pulse per press + auto-repeat; none while L and R both held
//   output          move_right   1-cycle pulse per press + auto-repeat; none while L and R both held
//   output          rotate       1-cycle pulse per press, no repeat
//   output          soft_drop    level: board BTND OR host SOFT_DROP, debounced
//   output          use_bomb     1-cycle pulse: host BOMB, or BTNC with SW1 = 0
//   output          use_freeze   1-cycle pulse: host FREEZE, or BTNC with SW1 = 1
//   output          pause_level  level: synchronized SW15 (1 = paused)
//   output          select_level level: synchronized SW1 (for the UI)
//   output          demo_level   level: synchronized SW2 (to timers)
`default_nettype none

module button_control #(
  parameter REPEAT_DELAY_CLKS = 20_000_000,
  parameter REPEAT_RATE_CLKS = 8_000_000
) (
  input  wire          clk,
  input  wire          rst,
  input  wire [4:0]    btn_raw,
  input  wire          sw_select,
  input  wire          sw_pause,
  input  wire          sw_demo,
  input  wire [5:0]    host_keys,
  input  wire          link_ok,
  output wire          move_left,
  output wire          move_right,
  output wire          rotate,
  output wire          soft_drop,
  output wire          use_bomb,
  output wire          use_freeze,
  output wire          pause_level,
  output wire          select_level,
  output wire          demo_level
);

  // TODO(Pholawath): implement. Stub outputs are tied to safe idle values.
  assign move_left = 1'b0;
  assign move_right = 1'b0;
  assign rotate = 1'b0;
  assign soft_drop = 1'b0;
  assign use_bomb = 1'b0;
  assign use_freeze = 1'b0;
  assign pause_level = 1'b0;
  assign select_level = 1'b0;
  assign demo_level = 1'b0;

endmodule

`default_nettype wire
