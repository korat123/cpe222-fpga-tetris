# Architecture

- **Clock:** one 100 MHz `clk`. `clock_enable` makes `tick_pixel` (every 4 clocks → 25 MHz VGA) and `tick_fall` (gravity, depends on level).
- **Reset:** `tetris_top` turns `CPU_RESETN` (active-low) into synchronous active-high `rst`.
- **Data flow:** buttons → `button_control` → `game_fsm` ⇄ `collision` (+ `tetromino`, `board_memory`) → `line_clear` → `score_level` → `seven_segment` / `vga_renderer` ← `vga_sync` → VGA.
- **Game FSM:** IDLE → SPAWN → FALL → LOCK → CLEAR → SPAWN …; SPAWN blocked → GAME_OVER; SW0 → IDLE.

Add the block diagram as `docs/diagrams/architecture.drawio` + `.svg` and link it here.
