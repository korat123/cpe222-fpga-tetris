// tb_button_control.v — self-checking testbench for button_control
// Contract: print exactly one `TB_PASS tb_button_control` at the end, or `TB_FAIL tb_button_control: <reason>`.
// Covers docs/input-controller.md section 8 (tb_button_control) and the input-layer cases of
// section 7: bouncing button -> one pulse, board OR host counted once, L/R auto-repeat timing,
// rotate never repeats, L+R = no move, BTNC + SW1 -> use_bomb / use_freeze, host BOMB/FREEZE,
// host keys ignored while link_ok = 0, keys released (timeout) stop the repeat, switches
// synchronized + debounced, actions still sent while paused (game_fsm ignores them, not this module).
`timescale 1ns/1ps
`include "tb_utils.vh"
`include "tetris_defs.vh"

module tb_button_control;
  localparam DEB   = 4;   // DEBOUNCE_CLKS
  localparam DELAY = 40;  // REPEAT_DELAY_CLKS
  localparam RATE  = 16;  // REPEAT_RATE_CLKS

  reg           clk = 0;
  reg           rst = 0;
  reg  [4:0]    btn_raw = 0;
  reg           sw_select = 0;
  reg           sw_pause = 0;
  reg           sw_demo = 0;
  reg  [5:0]    host_keys = 0;
  reg           link_ok = 0;
  wire          move_left;
  wire          move_right;
  wire          rotate;
  wire          soft_drop;
  wire          use_bomb;
  wire          use_freeze;
  wire          pause_level;
  wire          select_level;
  wire          demo_level;
  integer errors = 0;

  button_control #(.REPEAT_DELAY_CLKS(DELAY), .REPEAT_RATE_CLKS(RATE), .DEBOUNCE_CLKS(DEB)) dut (
    .clk(clk),
    .rst(rst),
    .btn_raw(btn_raw),
    .sw_select(sw_select),
    .sw_pause(sw_pause),
    .sw_demo(sw_demo),
    .host_keys(host_keys),
    .link_ok(link_ok),
    .move_left(move_left),
    .move_right(move_right),
    .rotate(rotate),
    .soft_drop(soft_drop),
    .use_bomb(use_bomb),
    .use_freeze(use_freeze),
    .pause_level(pause_level),
    .select_level(select_level),
    .demo_level(demo_level)
  );

  always #5 clk = ~clk;  // 100 MHz

  // ---------- pulse counters ----------
  integer now = 0;
  integer n_l = 0, n_r = 0, n_rot = 0, n_bomb = 0, n_frz = 0;
  integer t_l [0:31];
  always @(posedge clk) begin
    now <= now + 1;
    if (move_left)  begin t_l[n_l] <= now; n_l <= n_l + 1; end
    if (move_right) n_r <= n_r + 1;
    if (rotate)     n_rot <= n_rot + 1;
    if (use_bomb)   n_bomb <= n_bomb + 1;
    if (use_freeze) n_frz <= n_frz + 1;
  end

  task clocks(input integer n); begin repeat (n) @(posedge clk); #1; end endtask
  task settle; clocks(DEB + 6); endtask  // sync (2) + debounce + output register

  task clear_counts;
    begin n_l = 0; n_r = 0; n_rot = 0; n_bomb = 0; n_frz = 0; end
  endtask

  // bouncing press: a few fast toggles, then stable high
  task bounce_press(input integer b);
    begin
      btn_raw[b] = 1; clocks(1); btn_raw[b] = 0; clocks(2);
      btn_raw[b] = 1; clocks(1); btn_raw[b] = 0; clocks(1);
      btn_raw[b] = 1;
    end
  endtask

  integer i;

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_button_control.vcd"); $dumpvars(0, tb_button_control); end
    #1;
    rst = 1; clocks(4); rst = 0; clocks(DEB + 10);
    `CHECK({move_left, move_right, rotate, soft_drop, use_bomb, use_freeze} == 6'd0, "idle after reset")
    `CHECK({pause_level, select_level, demo_level} == 3'd0, "switch levels 0 after reset")

    // 1) bouncing BTNU, held long: exactly one rotate (no repeat), also after a bouncy release
    clear_counts;
    bounce_press(`BTN_U); clocks(DELAY + 4 * RATE);
    btn_raw[`BTN_U] = 0; clocks(1); btn_raw[`BTN_U] = 1; clocks(1); btn_raw[`BTN_U] = 0; settle;
    `CHECK(n_rot == 1, "bouncing BTNU held: exactly one rotate")

    // 2) BTNL held: first move at once, then after DELAY, then every RATE
    clear_counts;
    btn_raw[`BTN_L] = 1; clocks(10 + DELAY + 3 * RATE);
    btn_raw[`BTN_L] = 0; settle;
    `CHECK(n_l == 5, "BTNL held: 1 + 1 (after delay) + 3 (rate) moves")
    if (n_l == 5) begin
      `CHECK(t_l[1] - t_l[0] == DELAY, "auto-repeat starts after REPEAT_DELAY_CLKS")
      `CHECK(t_l[2] - t_l[1] == RATE && t_l[4] - t_l[3] == RATE, "auto-repeat every REPEAT_RATE_CLKS")
    end
    `CHECK(n_r == 0, "no right move")

    // 3) board BTNL + host LEFT together: counted once
    clear_counts; link_ok = 1;
    host_keys[`KEY_LEFT] = 1; btn_raw[`BTN_L] = 1; clocks(DELAY / 2);
    host_keys[`KEY_LEFT] = 0; clocks(3); btn_raw[`BTN_L] = 0; settle;
    `CHECK(n_l == 1, "board + host pressed together: one move")

    // 4) L and R together: no move; release L while R still held -> one right move
    clear_counts;
    host_keys[`KEY_LEFT] = 1; host_keys[`KEY_RIGHT] = 1; clocks(DELAY + 2 * RATE);
    `CHECK(n_l == 0 && n_r == 0, "L+R together: no move")
    host_keys[`KEY_LEFT] = 0; clocks(5);
    `CHECK(n_r == 1 && n_l == 0, "release L while R held: one right move")
    host_keys = 6'd0; clocks(5);

    // 5) host ROTATE held: one pulse only
    clear_counts;
    host_keys[`KEY_ROTATE] = 1; clocks(DELAY + 4 * RATE); host_keys = 6'd0; clocks(3);
    `CHECK(n_rot == 1, "host ROTATE held: one rotate")

    // 6) BTNC with SW1 = 0 -> bomb, SW1 = 1 -> freeze; flipping SW1 while BTNC is held: no new pulse
    clear_counts;
    bounce_press(`BTN_C); settle; btn_raw[`BTN_C] = 0; settle;
    `CHECK(n_bomb == 1 && n_frz == 0, "BTNC + SW1=0 -> use_bomb")
    sw_select = 1; settle;
    `CHECK(select_level == 1'b1, "select_level follows SW1")
    btn_raw[`BTN_C] = 1; settle;
    `CHECK(n_bomb == 1 && n_frz == 1, "BTNC + SW1=1 -> use_freeze")
    sw_select = 0; settle; sw_select = 1; settle;
    btn_raw[`BTN_C] = 0; settle;
    `CHECK(n_bomb == 1 && n_frz == 1, "flipping SW1 while BTNC held: no new pulse")
    sw_select = 0; settle;

    // 7) host BOMB / FREEZE keys, held: one pulse each
    clear_counts;
    host_keys[`KEY_BOMB] = 1; clocks(DELAY); host_keys = 6'd0; clocks(3);
    host_keys[`KEY_FREEZE] = 1; clocks(DELAY); host_keys = 6'd0; clocks(3);
    `CHECK(n_bomb == 1 && n_frz == 1, "host BOMB and FREEZE: one pulse each")

    // 8) host keys ignored while link_ok = 0
    clear_counts; link_ok = 0;
    host_keys = 6'h3F; clocks(DELAY + RATE);
    `CHECK(n_l + n_r + n_rot + n_bomb + n_frz == 0 && !soft_drop, "link_ok = 0: host keys ignored")
    host_keys = 6'd0; link_ok = 1; clocks(3);

    // 9) host LEFT held (auto-repeat running), then keys released by host_input timeout: moves stop
    clear_counts;
    host_keys[`KEY_LEFT] = 1; clocks(DELAY + RATE + 4);
    `CHECK(n_l == 3, "host LEFT repeating")
    host_keys = 6'd0;  // what host_input does after TIMEOUT_CLKS
    clocks(DELAY + 4 * RATE);
    `CHECK(n_l == 3, "keys released: repeat stops")

    // 10) soft drop is a level: board BTND (debounced) and host SOFT_DROP
    btn_raw[`BTN_D] = 1; clocks(2);
    `CHECK(!soft_drop, "BTND not yet debounced")
    settle; `CHECK(soft_drop, "BTND held -> soft_drop")
    btn_raw[`BTN_D] = 0; settle; `CHECK(!soft_drop, "BTND released")
    host_keys[`KEY_SOFT_DROP] = 1; clocks(2); `CHECK(soft_drop, "host SOFT_DROP -> soft_drop")
    host_keys = 6'd0; clocks(2); `CHECK(!soft_drop, "host SOFT_DROP released")

    // 11) SW15 pause and SW2 demo are synchronized + debounced; a short glitch is ignored
    sw_pause = 1; clocks(1); sw_pause = 0; settle;
    `CHECK(!pause_level, "1-clock glitch on SW15 ignored")
    sw_pause = 1; clocks(2);
    `CHECK(!pause_level, "SW15 not yet debounced")
    settle; `CHECK(pause_level, "SW15 ON -> pause_level")
    sw_demo = 1; settle; `CHECK(demo_level, "SW2 ON -> demo_level")

    // 12) while paused the input layer still sends actions (game_fsm ignores them)
    clear_counts;
    host_keys[`KEY_ROTATE] = 1; clocks(3); host_keys = 6'd0; clocks(3);
    `CHECK(n_rot == 1, "actions are still sent while pause_level = 1")
    sw_pause = 0; sw_demo = 0; settle;
    `CHECK(!pause_level && !demo_level, "switches OFF")

    // 13) reset clears everything
    btn_raw = 5'b11111; settle;
    rst = 1; clocks(1); `CHECK(!soft_drop && !pause_level, "reset clears levels")
    rst = 0; btn_raw = 0; settle;

    `TB_FINISH("tb_button_control")
  end
endmodule
