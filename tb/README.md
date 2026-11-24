# tb/
**Purpose:** self-checking testbenches, mirroring `rtl/` (`tb/<area>/tb_<module>.v`).
**What belongs here:** testbenches, `tb/include/tb_utils.vh`, small test data in `tb/vectors/<module>/` (.mem/.hex/.txt, < 1 MB), optional `.wcfg` waveform layouts.
**What does NOT belong here:** waveform dumps (.vcd/.wdb → `build/sim/`), screenshots (→ PR or `media/`).
**Owner:** Pornnapat (verification lead); each module owner writes their own testbench.

## Contract
- Use `` `CHECK(cond, "msg") `` for every expectation and end with `` `TB_FINISH("tb_<module>") ``.
- Output must contain `TB_PASS tb_<module>` (and no `TB_FAIL`). Must finish in < 120 s.
- Stubs print a "STUB" note — remove it when real checks exist.
- Run one: `bash scripts/sim/run_tb.sh tb_<module> [--dump]` · all: `bash scripts/sim/run_all.sh`.
