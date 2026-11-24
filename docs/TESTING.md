# Testing

How to run tests, lint and read waveforms: [TOOLS.md](TOOLS.md). Testbench rules, good examples and pitfalls: [tb/README.md](../tb/README.md).
Before opening a PR, try a **mutation test**: break one line of your RTL on purpose and check that your tb fails.

## Results (finished testbenches)
| Module | Testbench | Cases covered | Sim | Board |
|---|---|---|---|---|
| tetromino | tb_tetromino | all 28 type×rotation entries vs expected 4×4 masks · SRS clockwise rule (and 4 turns = start) · 4 distinct cells · 3×3 pieces stay in 3×3 box · type 0 = empty · 7 distinct spawn shapes | pass | — |
| board_memory | tb_board_memory | reference model compared after every clock · single write appears after 1 edge · 4 corners by raw bit index · overwrite with 0, we = 0 · out-of-range writes ignored · shift bottom/middle/top row, row 0 empty, rows below unchanged · shift_row ≥ 20 ignored · shift beats same-cycle write · bomb-style 3×3 clear at corners (0,19) and (9,0) · reset clears all | pass | — |
| uart_rx | tb_uart_rx | `send_byte` drives rx bit by bit · 0x80/0x81/0xBF · back-to-back bytes · bad stop bit → rx_error then recovery · glitch < ½ bit ignored · reset mid-byte · rx_valid is 1 cycle | pass | — |
| host_input | tb_host_input | real uart_rx in front · after reset keys 0 / link 0 · wrong headers dropped · key combos 0x89/0xBF/0x80 · steady heartbeat never times out · link lost while LEFT held → keys 0 + link 0 exactly TIMEOUT after last good byte (junk does not extend) · link returns · reset | pass | — |
| button_control | tb_button_control | bouncing button → 1 pulse · board + host together → 1 move · L/R repeat at DELAY then RATE (clock-exact) · rotate no repeat · L+R no move · BTNC+SW1 bomb/freeze, SW1 flip while held → no pulse · host BOMB/FREEZE · link_ok 0 ignores host · release stops repeat · soft_drop level · SW15/SW2 debounced, glitch ignored · actions still sent while paused · reset | pass | — |

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
