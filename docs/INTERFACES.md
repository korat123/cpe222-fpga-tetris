# INTERFACES.md — port contract (source of truth)

Change a port only in the same PR as the RTL change, and tag everyone whose module connects to it.
Input path details (UART protocol, keymap, timeouts): [input-controller.md](input-controller.md).

## Conventions
- One clock `clk` (100 MHz). Slower rates are 1-cycle enables from `timers`:
  `tick_pixel` (25 MHz, never gated), `tick_fall` (gravity), `tick_second` (game seconds).
- Reset `rst`: synchronous, active-high. Only `tetris_top` makes it, from `CPU_RESETN` (active-low) OR `SW[0]`.
- **pulse** = high for exactly 1 `clk` cycle · **level** = holds its value until it changes.
- Board: x 0–9 (left→right), y 0–19 (top→bottom); `board` bus index = (y*10 + x)*3, 3 bits per cell.
- Piece type 0 = empty, 1–7 = I O T S Z J L. Rotation 0–3 clockwise. Score is BCD (6 digits).
- Board button bit order {C, D, U, R, L} = [4:0]. Host key bit order {FREEZE, BOMB, SOFT_DROP, ROTATE, RIGHT, LEFT} = [5:0].
- Constants live in `rtl/include/tetris_defs.vh`.
- **Only `game_fsm` changes the board** (`board_we`, `board_shift_en`). `line_clear`, `powerup_controller`
  and `chaos_controller` only send requests/status.
- **Pause (SW15)** is a level from `button_control`. It gates game enables only (`tick_fall`, `tick_second`,
  so also the chaos and freeze timers) — never `clk`, `tick_pixel` or VGA. See ARCHITECTURE.md.

## PROPOSED — see issue #43
Not decided by the proposal yet; ports exist, behaviour may change:
`DEMO_CLKS_PER_SECOND` (demo timer speed), `LINES_PER_LEVEL` and fall speeds, `MAX_CHARGES`,
combo bonus formula, bomb anchor + bomb scoring, LED mapping, how a game starts after reset,
power-up use during chaos.

## `timers` — `rtl/common/timers.v` — owner: Teerawit

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | [3:0] | `level` | level 1-15 from score_combo (sets fall speed) |
| input | 1 | `soft_drop` | level: soft drop held -> faster tick_fall |
| input | 1 | `freeze_active` | level: from powerup_controller -> no tick_fall |
| input | 1 | `chaos_fast` | level: from chaos_controller -> tick_fall twice as often |
| input | 1 | `pause` | level: SW15 paused -> no tick_fall, no tick_second |
| input | 1 | `demo_mode` | level: SW2 -> tick_second every DEMO_CLKS_PER_SECOND (PROPOSED — see issue #43) |
| output | 1 | `tick_pixel` | 1-cycle pulse every 4 clocks (25 MHz); never gated |
| output | 1 | `tick_fall` | 1-cycle pulse: one gravity step |
| output | 1 | `tick_second` | 1-cycle pulse every game second; off while paused |

## `button_control` — `rtl/io/button_control.v` — owner: Korat

| Parameter | Default | Meaning |
|---|---|---|
| `REPEAT_DELAY_CLKS` | 20_000_000 | hold time before L/R auto-repeat (200 ms) |
| `REPEAT_RATE_CLKS` | 8_000_000 | L/R auto-repeat period (80 ms) |
| `DEBOUNCE_CLKS` | 1_000_000 | board button / switch must be stable this long (10 ms) |

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | [4:0] | `btn_raw` | raw board buttons {C,D,U,R,L}, asynchronous |
| input | 1 | `sw_select` | raw SW1: 0 = bomb, 1 = freeze (BTNC only) |
| input | 1 | `sw_pause` | raw SW15: 1 = paused |
| input | 1 | `sw_demo` | raw SW2: 1 = demo timer |
| input | [5:0] | `host_keys` | from host_input, level {FREEZE,BOMB,SOFT_DROP,ROTATE,RIGHT,LEFT} |
| input | 1 | `link_ok` | from host_input: 1 = laptop connected; host_keys are ignored while 0 |
| output | 1 | `move_left` | 1-cycle pulse per press + auto-repeat; none while L and R both held |
| output | 1 | `move_right` | 1-cycle pulse per press + auto-repeat; none while L and R both held |
| output | 1 | `rotate` | 1-cycle pulse per press, no repeat |
| output | 1 | `soft_drop` | level: board BTND OR host SOFT_DROP, debounced |
| output | 1 | `use_bomb` | 1-cycle pulse: host BOMB, or BTNC with SW1 = 0 (SW1 read at the moment BTNC is pressed) |
| output | 1 | `use_freeze` | 1-cycle pulse: host FREEZE, or BTNC with SW1 = 1 |
| output | 1 | `pause_level` | level: synchronized SW15 (1 = paused) |
| output | 1 | `select_level` | level: synchronized SW1 (for the UI) |
| output | 1 | `demo_level` | level: synchronized SW2 (to timers) |

## `uart_rx` — `rtl/io/uart_rx.v` — owner: Korat

| Parameter | Default | Meaning |
|---|---|---|
| `CLKS_PER_BIT` | 868 | 100 MHz / 115200 baud |

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | 1 | `rx` | UART line from the USB-UART bridge (idle 1), asynchronous |
| output | [7:0] | `rx_data` | received byte, valid when rx_valid = 1 |
| output | 1 | `rx_valid` | 1-cycle pulse per byte with a good stop bit |
| output | 1 | `rx_error` | 1-cycle pulse: bad stop bit, byte dropped |

## `host_input` — `rtl/io/host_input.v` — owner: Korat

| Parameter | Default | Meaning |
|---|---|---|
| `TIMEOUT_CLKS` | 25_000_000 | 250 ms without a valid byte -> release all keys |

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | [7:0] | `rx_data` | from uart_rx |
| input | 1 | `rx_valid` | 1-cycle pulse from uart_rx |
| output | [5:0] | `host_keys` | level {FREEZE,BOMB,SOFT_DROP,ROTATE,RIGHT,LEFT}; 0 after reset/timeout |
| output | 1 | `link_ok` | level: 1 = valid byte (header 10) within TIMEOUT_CLKS |

## `seven_segment` — `rtl/io/seven_segment.v` — owner: Pholawath

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | [23:0] | `score_bcd` | 6 BCD digits |
| output | [7:0] | `an` | digit enables, active-low |
| output | [6:0] | `seg` | segments g..a, active-low |

## `vga_sync` — `rtl/video/vga_sync.v` — owner: Nassasi

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | 1 | `tick_pixel` | 25 MHz enable from timers |
| output | 1 | `hsync` | active-low |
| output | 1 | `vsync` | active-low |
| output | 1 | `video_on` | 1 inside 640x480 |
| output | [9:0] | `pixel_x` | 0-799 |
| output | [9:0] | `pixel_y` | 0-524 |

## `vga_renderer` — `rtl/video/vga_renderer.v` — owner: Nassasi

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | [9:0] | `pixel_x` | from vga_sync |
| input | [9:0] | `pixel_y` | from vga_sync |
| input | 1 | `video_on` | from vga_sync |
| input | [599:0] | `board` | 200 cells x 3 bits, index y*10+x |
| input | [2:0] | `piece_type` | active piece |
| input | [2:0] | `next_type` | next-piece preview |
| input | [1:0] | `piece_rot` |  |
| input | [3:0] | `piece_x` |  |
| input | [4:0] | `piece_y` |  |
| input | [23:0] | `score_bcd` |  |
| input | [3:0] | `level` |  |
| input | [3:0] | `combo` | from score_combo |
| input | [2:0] | `game_state` | S_* from tetris_defs.vh (GAME OVER text) |
| input | [3:0] | `charges` | power-up charges |
| input | 1 | `select_level` | SW1: selected power-up 0 = bomb, 1 = freeze |
| input | 1 | `freeze_active` |  |
| input | [2:0] | `freeze_remaining` | seconds |
| input | 1 | `chaos_reverse` | active chaos effect |
| input | 1 | `chaos_fast` | active chaos effect |
| input | [4:0] | `chaos_countdown` | seconds until next chaos event |
| input | [2:0] | `chaos_remaining` | seconds left in active chaos event |
| input | 1 | `paused` | show 'PAUSED - SW15 OFF to resume' |
| output | [3:0] | `vga_r` |  |
| output | [3:0] | `vga_g` |  |
| output | [3:0] | `vga_b` |  |

## `board_memory` — `rtl/game/board_memory.v` — owner: Korat

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high; clears the board. Priority each clock: `rst` > `shift_en` > `we` |
| input | 1 | `we` | 1-cycle: write one cell (from game_fsm only); ignored if `wx` > 9 or `wy` > 19, and dropped if `shift_en` is high in the same cycle |
| input | [3:0] | `wx` | 0-9 |
| input | [4:0] | `wy` | 0-19 |
| input | [2:0] | `wdata` | 0 empty, 1-7 piece type |
| input | 1 | `shift_en` | 1-cycle: remove row shift_row, rows above drop, row 0 becomes empty (from game_fsm only); ignored if `shift_row` > 19 |
| input | [4:0] | `shift_row` |  |
| output | [599:0] | `board` | registered, index y*10+x |

## `tetromino` — `rtl/game/tetromino.v` — owner: Korat

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | [2:0] | `piece_type` | 1-7 = I O T S Z J L |
| input | [1:0] | `piece_rot` | 0-3 clockwise |
| output | [15:0] | `cells` | combinational. Cell k = `cells[4k+3:4k]` = {dx[1:0], dy[1:0]}; (dx, dy) = offset from the top-left of the 4x4 piece box = (`piece_x`, `piece_y`), dx right, dy down; cell order has no meaning. SRS shapes: I in 4x4, O fixed, T S Z J L in the top-left 3x3. Type 0 → 0 |

## `collision` — `rtl/game/collision.v` — owner: Korat

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | [4:0] | `test_x` | signed, may be negative |
| input | [4:0] | `test_y` |  |
| input | [15:0] | `cells` | from tetromino |
| input | [599:0] | `board` |  |
| output | 1 | `collide` | combinational: 1 = out of bounds or overlap |

## `lfsr` — `rtl/game/lfsr.v` — owner: Teerawit

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | 1 | `seed_load` | 1-cycle pulse |
| input | [15:0] | `seed` | from free-running counter at start |
| input | 1 | `step` | 1-cycle pulse: next piece |
| output | [2:0] | `piece_type` | always 1-7 |
| output | [1:0] | `rand_bits` | free-running random bits for chaos_controller |

## `chaos_controller` — `rtl/game/chaos_controller.v` — owner: Teerawit

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | 1 | `tick_second` | from timers (already off while paused) |
| input | 1 | `playing` | level from game_fsm: count only while a game runs |
| input | [1:0] | `rand_bits` | from lfsr; picks the event |
| output | 1 | `chaos_reverse` | level: left/right swapped (used by game_fsm) |
| output | 1 | `chaos_fast` | level: double fall speed (used by timers) |
| output | [4:0] | `chaos_countdown` | seconds until the next event (UI) |
| output | [2:0] | `chaos_remaining` | seconds left in the active event, 0 = none (UI) |

## `powerup_controller` — `rtl/game/powerup_controller.v` — owner: Pornnapat

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | 1 | `tick_second` | from timers (already off while paused) |
| input | 1 | `playing` | level from game_fsm |
| input | 1 | `pause` | level: ignore use_bomb/use_freeze while paused (not queued) |
| input | 1 | `clear_done` | 1-cycle pulse from line_clear |
| input | [2:0] | `lines_cleared` | 0-4, valid with clear_done |
| input | 1 | `use_bomb` | 1-cycle pulse from button_control |
| input | 1 | `use_freeze` | 1-cycle pulse from button_control |
| input | 1 | `bomb_done` | 1-cycle pulse from game_fsm: bomb finished |
| output | [3:0] | `charges` | 0-MAX_CHARGES (PROPOSED — see issue #43); +1 per LINES_PER_CHARGE lines |
| output | 1 | `bomb_req` | level: held until bomb_done |
| output | 1 | `freeze_active` | level: FREEZE_LEN_S seconds |
| output | [2:0] | `freeze_remaining` | seconds left (UI) |
| output | 1 | `no_charge` | 1-cycle pulse: request with 0 charges (UI flash) |

## `game_fsm` — `rtl/game/game_fsm.v` — owner: Teerawit

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | 1 | `move_left` | 1-cycle pulse from button_control |
| input | 1 | `move_right` | 1-cycle pulse from button_control |
| input | 1 | `rotate` | 1-cycle pulse from button_control |
| input | 1 | `pause` | level: in FALL ignore actions and hold the piece |
| input | 1 | `chaos_reverse` | level: swap move_left/move_right |
| input | 1 | `tick_fall` | 1-cycle pulse from timers |
| input | 1 | `collide` | from collision for test_x/test_y/test_rot |
| input | [2:0] | `new_type` | from lfsr |
| input | 1 | `bomb_req` | level from powerup_controller; served at a safe point in FALL |
| input | 1 | `clear_shift_req` | 1-cycle pulse from line_clear |
| input | [4:0] | `clear_shift_row` | row to remove, valid with clear_shift_req |
| input | 1 | `clear_done` | 1-cycle pulse from line_clear |
| output | [2:0] | `game_state` | S_RESET S_SPAWN S_FALL S_LOCK S_CLEAR S_GAME_OVER S_BOMB |
| output | 1 | `playing` | level: game running (not RESET / GAME_OVER) |
| output | [2:0] | `piece_type` |  |
| output | [2:0] | `next_type` |  |
| output | [1:0] | `piece_rot` |  |
| output | [3:0] | `piece_x` |  |
| output | [4:0] | `piece_y` |  |
| output | [4:0] | `test_x` | signed, to collision |
| output | [4:0] | `test_y` | to collision |
| output | [1:0] | `test_rot` | to tetromino (test copy) |
| output | 1 | `board_we` | 1-cycle: write one cell (lock = piece type, bomb = 0) |
| output | [3:0] | `board_wx` |  |
| output | [4:0] | `board_wy` |  |
| output | [2:0] | `board_wdata` |  |
| output | 1 | `board_shift_en` | 1-cycle: remove board_shift_row |
| output | [4:0] | `board_shift_row` |  |
| output | 1 | `start_clear` | 1-cycle pulse to line_clear |
| output | 1 | `piece_locked` | 1-cycle pulse per locked piece (score_combo) |
| output | 1 | `bomb_done` | 1-cycle pulse to powerup_controller |
| output | 1 | `lfsr_step` | 1-cycle pulse |

## `line_clear` — `rtl/game/line_clear.v` — owner: Korat

| Parameter | Default | Meaning |
|---|---|---|
| `SHIFT_WAIT_CLKS` | 2 | clocks to wait after `shift_req` before checking the same row again (min 1) |

Contract with `game_fsm`: forward `shift_req`/`shift_row` to `board_memory` as `board_shift_en`/`shift_row`
directly or through at most one register, so the board shows the shift within `SHIFT_WAIT_CLKS` + 1 clocks.
`start` is ignored while `busy`; `done` comes in the cycle `busy` falls.

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | 1 | `start` | 1-cycle pulse from game_fsm |
| input | [599:0] | `board` |  |
| output | 1 | `busy` | level |
| output | 1 | `done` | 1-cycle pulse: finished (clear_done) |
| output | 1 | `shift_req` | 1-cycle pulse: ask game_fsm to remove shift_row |
| output | [4:0] | `shift_row` |  |
| output | [2:0] | `lines_cleared` | 0-4, valid with done |

## `score_combo` — `rtl/game/score_combo.v` — owner: Pholawath

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz system clock |
| input | 1 | `rst` | sync, active-high |
| input | 1 | `clear_done` | 1-cycle pulse from line_clear |
| input | [2:0] | `lines_cleared` | 0-4, valid with clear_done |
| input | 1 | `piece_locked` | 1-cycle pulse from game_fsm; a lock with no clear resets combo |
| output | [23:0] | `score_bcd` | 6 BCD digits: +100/300/500/800 + combo bonus (formula PROPOSED — see issue #43) |
| output | [7:0] | `lines` | total cleared lines |
| output | [3:0] | `level` | 1 + lines/LINES_PER_LEVEL, max 15 (PROPOSED — see issue #43) |
| output | [3:0] | `combo` | consecutive clearing pieces |

## `tetris_top` — `rtl/top/tetris_top.v` — owner: Pholawath

Only module that touches board pins. Pins come only from Digilent's master XDC (see constraints/README.md).

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `CLK100MHZ` | board clock |
| input | 1 | `CPU_RESETN` | board reset, active-low |
| input | 1 | `BTNC` | use selected power-up (backup input) |
| input | 1 | `BTNU` | rotate (backup input) |
| input | 1 | `BTNL` | move left (backup input) |
| input | 1 | `BTNR` | move right (backup input) |
| input | 1 | `BTND` | soft drop (backup input) |
| input | [15:0] | `SW` | SW0 reset · SW1 power-up select · SW2 demo timer · SW15 pause |
| input | 1 | `UART_TXD_IN` | UART laptop → FPGA (115200 8N1), idle 1 |
| output | [15:0] | `LED` | power-up / chaos status, LED15 = host link (PROPOSED — see issue #43) |
| output | 1 | `CA` | 7-seg segment a, active-low |
| output | 1 | `CB` | segment b |
| output | 1 | `CC` | segment c |
| output | 1 | `CD` | segment d |
| output | 1 | `CE` | segment e |
| output | 1 | `CF` | segment f |
| output | 1 | `CG` | segment g |
| output | 1 | `DP` | decimal point, active-low |
| output | [7:0] | `AN` | digit enables, active-low |
| output | [3:0] | `VGA_R` |  |
| output | [3:0] | `VGA_G` |  |
| output | [3:0] | `VGA_B` |  |
| output | 1 | `VGA_HS` | active-low |
| output | 1 | `VGA_VS` | active-low |
