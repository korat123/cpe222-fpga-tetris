# INTERFACES.md — port contract (source of truth)

Change a port only in the same PR as the RTL change, and tag everyone whose module connects to it.

## Conventions
- One clock `clk` (100 MHz). Slower rates are 1-cycle enables (`tick_pixel`, `tick_fall`) from `clock_enable`.
- Reset `rst`: synchronous, active-high. Only `tetris_top` converts the board's `CPU_RESETN` (active-low).
- Board: x 0–9 (left→right), y 0–19 (top→bottom); `board` bus index = (y*10 + x)*3, 3 bits per cell.
- Piece type 0 = empty, 1–7 = I O T S Z J L. Rotation 0–3 clockwise. Score is BCD (6 digits).
- Button bit order {C, D, U, R, L} = [4:0]. Constants live in `rtl/include/tetris_defs.vh`.

## `clock_enable` — `rtl/common/clock_enable.v` — owner: Korat

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` | 100 MHz clock |
| input | 1 | `rst` | sync active-high reset |
| input | [3:0] | `level` | current level 1-15 |
| input | 1 | `soft_drop` | BTND held |
| output | 1 | `tick_pixel` | 1-cycle pulse every 4 clocks (25 MHz) |
| output | 1 | `tick_fall` | 1-cycle pulse: gravity step |

## `button_control` — `rtl/io/button_control.v` — owner: Pholawath

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` |  |
| input | 1 | `rst` |  |
| input | [4:0] | `btn_raw` | raw buttons {C,D,U,R,L} |
| output | [4:0] | `btn_pulse` | 1-cycle pulse per press |
| output | [4:0] | `btn_level` | debounced level |

## `seven_segment` — `rtl/io/seven_segment.v` — owner: Nassasi

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` |  |
| input | 1 | `rst` |  |
| input | [23:0] | `score_bcd` | 6 BCD digits |
| output | [7:0] | `an` | digit enables, active-low |
| output | [6:0] | `seg` | segments g..a, active-low |

## `vga_sync` — `rtl/video/vga_sync.v` — owner: Korat

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` |  |
| input | 1 | `rst` |  |
| input | 1 | `tick_pixel` | 25 MHz enable |
| output | 1 | `hsync` | active-low |
| output | 1 | `vsync` | active-low |
| output | 1 | `video_on` | 1 inside 640x480 |
| output | [9:0] | `pixel_x` | 0-799 |
| output | [9:0] | `pixel_y` | 0-524 |

## `vga_renderer` — `rtl/video/vga_renderer.v` — owner: Korat

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` |  |
| input | 1 | `rst` |  |
| input | [9:0] | `pixel_x` |  |
| input | [9:0] | `pixel_y` |  |
| input | 1 | `video_on` |  |
| input | [599:0] | `board` | 200 cells x 3 bits, index y*10+x |
| input | [2:0] | `piece_type` |  |
| input | [2:0] | `next_type` |  |
| input | [1:0] | `piece_rot` |  |
| input | [3:0] | `piece_x` |  |
| input | [4:0] | `piece_y` |  |
| input | [23:0] | `score_bcd` |  |
| input | [3:0] | `level` |  |
| input | [2:0] | `game_state` |  |
| output | [3:0] | `vga_r` |  |
| output | [3:0] | `vga_g` |  |
| output | [3:0] | `vga_b` |  |

## `board_memory` — `rtl/game/board_memory.v` — owner: Korat

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` |  |
| input | 1 | `rst` | clears board |
| input | 1 | `we` | write one cell |
| input | [3:0] | `wx` |  |
| input | [4:0] | `wy` |  |
| input | [2:0] | `wdata` | 0 empty, 1-7 piece type |
| input | 1 | `shift_en` | remove row shift_row, rows above drop |
| input | [4:0] | `shift_row` |  |
| output | [599:0] | `board` |  |

## `tetromino` — `rtl/game/tetromino.v` — owner: Teerawit

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | [2:0] | `piece_type` | 1-7 = I O T S Z J L |
| input | [1:0] | `piece_rot` | 0-3 clockwise |
| output | [15:0] | `cells` | 4 x {dx[1:0],dy[1:0]} |

## `collision` — `rtl/game/collision.v` — owner: Teerawit

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | [4:0] | `test_x` | signed, may be negative |
| input | [4:0] | `test_y` |  |
| input | [15:0] | `cells` |  |
| input | [599:0] | `board` |  |
| output | 1 | `collide` | 1 = out of bounds or overlap |

## `lfsr` — `rtl/game/lfsr.v` — owner: Teerawit

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` |  |
| input | 1 | `rst` |  |
| input | 1 | `seed_load` |  |
| input | [15:0] | `seed` | from free-running counter at start |
| input | 1 | `step` |  |
| output | [2:0] | `piece_type` | always 1-7 |

## `game_fsm` — `rtl/game/game_fsm.v` — owner: Pornnapat

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` |  |
| input | 1 | `rst` |  |
| input | [4:0] | `btn_pulse` |  |
| input | 1 | `tick_fall` |  |
| input | 1 | `collide` |  |
| input | 1 | `clear_done` |  |
| input | [2:0] | `new_type` | from lfsr |
| output | [2:0] | `game_state` | IDLE SPAWN FALL LOCK CLEAR GAME_OVER |
| output | [2:0] | `piece_type` |  |
| output | [2:0] | `next_type` |  |
| output | [1:0] | `piece_rot` |  |
| output | [3:0] | `piece_x` |  |
| output | [4:0] | `piece_y` |  |
| output | [4:0] | `test_x` | signed |
| output | [4:0] | `test_y` |  |
| output | [1:0] | `test_rot` |  |
| output | 1 | `lock_we` |  |
| output | 1 | `start_clear` |  |
| output | 1 | `lfsr_step` |  |

## `line_clear` — `rtl/game/line_clear.v` — owner: Pornnapat

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` |  |
| input | 1 | `rst` |  |
| input | 1 | `start` |  |
| input | [599:0] | `board` |  |
| output | 1 | `busy` |  |
| output | 1 | `done` |  |
| output | 1 | `shift_en` |  |
| output | [4:0] | `shift_row` |  |
| output | [2:0] | `lines_cleared` | 0-4 |

## `score_level` — `rtl/game/score_level.v` — owner: Nassasi

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `clk` |  |
| input | 1 | `rst` |  |
| input | 1 | `clear_done` |  |
| input | [2:0] | `lines_cleared` |  |
| output | [23:0] | `score_bcd` | +100/300/500/800 |
| output | [7:0] | `lines` |  |
| output | [3:0] | `level` | 1 + lines/10 |

## `tetris_top` — `rtl/top/tetris_top.v` — owner: Pholawath

| Dir | Width | Port | Meaning |
|---|---|---|---|
| input | 1 | `CLK100MHZ` | board clock |
| input | 1 | `CPU_RESETN` | board reset, active-low |
| input | 1 | `BTNC` |  |
| input | 1 | `BTNU` |  |
| input | 1 | `BTNL` |  |
| input | 1 | `BTNR` |  |
| input | 1 | `BTND` |  |
| input | [15:0] | `SW` |  |
| output | [15:0] | `LED` |  |
| output | 1 | `CA` |  |
| output | 1 | `CB` |  |
| output | 1 | `CC` |  |
| output | 1 | `CD` |  |
| output | 1 | `CE` |  |
| output | 1 | `CF` |  |
| output | 1 | `CG` |  |
| output | 1 | `DP` |  |
| output | [7:0] | `AN` |  |
| output | [3:0] | `VGA_R` |  |
| output | [3:0] | `VGA_G` |  |
| output | [3:0] | `VGA_B` |  |
| output | 1 | `VGA_HS` |  |
| output | 1 | `VGA_VS` |  |

