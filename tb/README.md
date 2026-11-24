# tb/
**Purpose:** self-checking testbenches, mirroring `rtl/` (`tb/<area>/tb_<module>.v`).
**What belongs here:** testbenches, `tb/include/tb_utils.vh`, small test data in `tb/vectors/<module>/` (.mem/.hex/.txt, < 1 MB), optional `.wcfg` waveform layouts.
**What does NOT belong here:** waveform dumps (.vcd/.wdb → `build/sim/`), screenshots (→ PR or `media/`).
**Owner:** Pornnapat (verification lead, testbenches & evidence); each module owner writes their own testbench.

## Contract
- Use `` `CHECK(cond, "msg") `` for every expectation and end with `` `TB_FINISH("tb_<module>") ``.
- Output must contain `TB_PASS tb_<module>` (and no `TB_FAIL`). Must finish in < 120 s.
- Stubs print a "STUB" note — remove it when real checks exist.
- Run one: `bash scripts/sim/run_tb.sh tb_<module> [--dump]` · all: `bash scripts/sim/run_all.sh` · details in [docs/TOOLS.md](../docs/TOOLS.md).
- Write the tb **before** the RTL: it must fail on the stub first (AGENTS §6).

## Good examples to copy
| Testbench | Shows how to… |
|---|---|
| `tb/game/tb_board_memory.v` | keep a reference model and compare the whole output after every clock |
| `tb/io/tb_uart_rx.v` | drive an input bit by bit with a task (`send_byte`) and count output pulses in an `always` block |
| `tb/io/tb_host_input.v` | test two modules together (real `uart_rx` in front of `host_input`) and measure a timeout in clocks |
| `tb/io/tb_button_control.v` | use small parameter values so long timers simulate fast; measure pulse spacing |
| `tb/game/tb_tetromino.v` | check a combinational table two independent ways (expected table + a rule) |

## Pitfalls we already hit
- **Change inputs away from the clock edge.** `@(posedge clk); rst = 0;` races with the DUT. Use `@(posedge clk); #1 rst = 0;`.
- **Wrap `` `CHECK `` in `begin`/`end` inside `if … else`.** The macro is an `if`, so a bare `else` attaches to it and silently skips checks.
