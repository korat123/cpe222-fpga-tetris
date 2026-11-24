// button_control.v — owner: Korat
// Board buttons + switches + host keys -> clean game actions. Spec: docs/input-controller.md §2, §5, §7.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   parameter REPEAT_DELAY_CLKS = 20_000_000  hold time before L/R auto-repeat (200 ms)
//   parameter REPEAT_RATE_CLKS = 8_000_000  L/R auto-repeat period (80 ms)
//   parameter DEBOUNCE_CLKS = 1_000_000  board button / switch must be stable this long (10 ms)
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
//
// Steps: (1) the 8 board signals (5 buttons, SW1, SW2, SW15) go through a 2-FF synchronizer and a
// debouncer; (2) host keys count only while link_ok = 1 and are OR-ed with the board buttons, so a
// key held on both sources is one press; (3) edges become 1-cycle pulses; (4) LEFT/RIGHT repeat
// after REPEAT_DELAY_CLKS, then every REPEAT_RATE_CLKS. This module knows nothing about the game:
// pause and chaos are handled in game_fsm, charges in powerup_controller.
`default_nettype none
`include "tetris_defs.vh"

module button_control #(
  parameter REPEAT_DELAY_CLKS = 20_000_000,
  parameter REPEAT_RATE_CLKS = 8_000_000,
  parameter DEBOUNCE_CLKS = 1_000_000
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

  function integer clog2(input integer value);
    integer v;
    begin
      clog2 = 0;
      for (v = value - 1; v > 0; v = v >> 1) clog2 = clog2 + 1;
    end
  endfunction

  localparam DW = (clog2(DEBOUNCE_CLKS) < 1) ? 1 : clog2(DEBOUNCE_CLKS);
  localparam RMAX = (REPEAT_DELAY_CLKS > REPEAT_RATE_CLKS) ? REPEAT_DELAY_CLKS : REPEAT_RATE_CLKS;
  localparam RW = (clog2(RMAX) < 1) ? 1 : clog2(RMAX);
  localparam [DW-1:0] DEB_LAST   = DEBOUNCE_CLKS - 1;
  localparam [RW-1:0] DELAY_LAST = REPEAT_DELAY_CLKS - 1;
  localparam [RW-1:0] RATE_LAST  = REPEAT_RATE_CLKS - 1;

  // bit positions of the 8 board signals after synchronization/debounce
  localparam SW_SEL = 5, SW_PAUSE = 6, SW_DEMO = 7;
  localparam [1:0] DIR_NONE = 2'b00, DIR_L = 2'b01, DIR_R = 2'b10;

  // ---------- (1) synchronizer + debouncer for the board signals ----------
  wire [7:0] raw = {sw_demo, sw_pause, sw_select, btn_raw};
  reg  [7:0] sync1_q, sync2_q;
  wire [7:0] db;  // debounced levels

  always @(posedge clk) begin
    if (rst) begin
      sync1_q <= 8'd0;
      sync2_q <= 8'd0;
    end else begin
      sync1_q <= raw;
      sync2_q <= sync1_q;
    end
  end

  genvar g;
  generate
    for (g = 0; g < 8; g = g + 1) begin : g_debounce
      reg [DW-1:0] cnt_q;
      reg          level_q;
      always @(posedge clk) begin
        if (rst) begin
          cnt_q   <= {DW{1'b0}};
          level_q <= 1'b0;
        end else if (sync2_q[g] == level_q) begin
          cnt_q <= {DW{1'b0}};          // input agrees with output: nothing to do
        end else if (cnt_q == DEB_LAST) begin
          cnt_q   <= {DW{1'b0}};
          level_q <= sync2_q[g];        // stable for DEBOUNCE_CLKS: accept the new value
        end else begin
          cnt_q <= cnt_q + 1'b1;
        end
      end
      assign db[g] = level_q;
    end
  endgenerate

  // ---------- (2) combine board and host ----------
  wire [5:0] host = link_ok ? host_keys : 6'd0;
  wire left_lv   = db[`BTN_L] | host[`KEY_LEFT];
  wire right_lv  = db[`BTN_R] | host[`KEY_RIGHT];
  wire rotate_lv = db[`BTN_U] | host[`KEY_ROTATE];
  wire drop_lv   = db[`BTN_D] | host[`KEY_SOFT_DROP];
  wire btnc_lv   = db[`BTN_C];
  wire bomb_lv   = host[`KEY_BOMB];
  wire freeze_lv = host[`KEY_FREEZE];

  wire [1:0] dir = (left_lv && !right_lv) ? DIR_L :
                   (right_lv && !left_lv) ? DIR_R : DIR_NONE;

  // ---------- (3) + (4) pulses and auto-repeat ----------
  reg          rotate_d, btnc_d, bomb_d, freeze_d;
  reg [1:0]    dir_q;
  reg          first_q;      // 1 = waiting for the first repeat (REPEAT_DELAY), 0 = repeating
  reg [RW-1:0] rep_q;
  reg          left_q, right_q, rotate_q, drop_q, bomb_q, freeze_q;

  always @(posedge clk) begin
    if (rst) begin
      rotate_d <= 1'b0; btnc_d <= 1'b0; bomb_d <= 1'b0; freeze_d <= 1'b0;
      dir_q    <= DIR_NONE;
      first_q  <= 1'b1;
      rep_q    <= {RW{1'b0}};
      left_q   <= 1'b0; right_q  <= 1'b0; rotate_q <= 1'b0;
      drop_q   <= 1'b0; bomb_q   <= 1'b0; freeze_q <= 1'b0;
    end else begin
      rotate_d <= rotate_lv;
      btnc_d   <= btnc_lv;
      bomb_d   <= bomb_lv;
      freeze_d <= freeze_lv;

      rotate_q <= rotate_lv & ~rotate_d;
      drop_q   <= drop_lv;
      // BTNC picks bomb or freeze from SW1 at the moment of the press only
      bomb_q   <= (btnc_lv & ~btnc_d & ~db[SW_SEL]) | (bomb_lv & ~bomb_d);
      freeze_q <= (btnc_lv & ~btnc_d &  db[SW_SEL]) | (freeze_lv & ~freeze_d);

      // left/right: move at once, again after REPEAT_DELAY, then every REPEAT_RATE
      left_q  <= 1'b0;
      right_q <= 1'b0;
      if (dir != dir_q) begin
        dir_q   <= dir;
        first_q <= 1'b1;
        rep_q   <= {RW{1'b0}};
        left_q  <= (dir == DIR_L);
        right_q <= (dir == DIR_R);
      end else if (dir != DIR_NONE) begin
        if ((first_q && rep_q == DELAY_LAST) || (!first_q && rep_q == RATE_LAST)) begin
          first_q <= 1'b0;
          rep_q   <= {RW{1'b0}};
          left_q  <= (dir == DIR_L);
          right_q <= (dir == DIR_R);
        end else begin
          rep_q <= rep_q + 1'b1;
        end
      end
    end
  end

  assign move_left    = left_q;
  assign move_right   = right_q;
  assign rotate       = rotate_q;
  assign soft_drop    = drop_q;
  assign use_bomb     = bomb_q;
  assign use_freeze   = freeze_q;
  assign pause_level  = db[SW_PAUSE];
  assign select_level = db[SW_SEL];
  assign demo_level   = db[SW_DEMO];

endmodule

`default_nettype wire
