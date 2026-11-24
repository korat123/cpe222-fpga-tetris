# Testing

| Module | Testbench | Cases covered | Sim | Board |
|---|---|---|---|---|
| tetromino | tb_tetromino | all 28 type×rotation entries vs expected 4×4 masks · SRS clockwise rule (and 4 turns = start) · 4 distinct cells · 3×3 pieces stay in 3×3 box · type 0 = empty · 7 distinct spawn shapes | pass | — |
| board_memory | tb_board_memory | reference model compared after every clock · single write appears after 1 edge · 4 corners by raw bit index · overwrite with 0, we = 0 · out-of-range writes ignored · shift bottom/middle/top row, row 0 empty, rows below unchanged · shift_row ≥ 20 ignored · shift beats same-cycle write · bomb-style 3×3 clear at corners (0,19) and (9,0) · reset clears all | pass | — |

## Planned test cases (CHAOTETRIS)
Use small timer parameters in testbenches so they finish in < 120 s.

| Area | Testbench | Cases |
|---|---|---|
| Collision | tb_collision | left/right wall, floor, overlap with locked cells, every piece × rotation at both walls |
| Row clearing | tb_line_clear, tb_game_fsm | clear 1/2/3/4 rows, non-adjacent rows, rows above drop correctly |
| Bomb | tb_game_fsm, tb_powerup_controller | 3×3 in the middle, at left/right edges, at corners and the top row (no out-of-bounds write), active piece never removed, no charge → nothing happens |
| Freeze | tb_powerup_controller, tb_timers | no `tick_fall` for FREEZE_LEN_S, movement/rotation/soft drop still work, expires on time, second freeze while active is ignored |
| Chaos | tb_chaos_controller, tb_timers | event every CHAOS_PERIOD_S, lasts CHAOS_LEN_S, both event types reachable from LFSR, double speed doubles `tick_fall`, reversed L/R in game_fsm |
| Combo / score | tb_score_combo | +100/300/500/800, combo grows on consecutive clearing pieces, resets on a lock with no clear, level from lines |
| Demo timer | tb_timers | SW2 makes `tick_second` faster |
| Pause | tb_timers, tb_game_fsm, tb_powerup_controller | pause in FALL freezes the piece and all timers · actions ignored while paused (not queued) · pause during LOCK/CLEAR waits until they finish · pause + freeze keeps the remaining freeze time · reset with SW15 ON starts paused |
| Input | tb_uart_rx, tb_host_input, tb_button_control | see [input-controller.md](input-controller.md) §8 |

Board test checklist (P3): every button and keyboard/controller key · rotate at left/right wall · land on floor ·
clear 1/2/3/4 lines · score on 7-seg and VGA · level speed-up · bomb at an edge · freeze · chaos (with SW2) ·
pause/resume with SW15 · unplug the bridge while holding a key · game over · reset.
