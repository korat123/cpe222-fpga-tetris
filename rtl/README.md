# rtl/
**Purpose:** all synthesizable Verilog — one module per file, file name = module name.
**What belongs here:** `rtl/<common|io|video|game|features|top>/<module>.v`, shared constants in `rtl/include/`.
**What does NOT belong here:** testbenches (→ `tb/`), constraints (→ `constraints/`), copies like `*_old.v`.
**Owners:** see table and `.github/CODEOWNERS`. Port contract: `docs/INTERFACES.md`.

| Module | Folder | Owner | Status (stub / sim-pass / board-pass) |
|---|---|---|---|
| clock_enable | common | Korat | stub |
| button_control | io | Pholawath | stub |
| seven_segment | io | Nassasi | stub |
| vga_sync | video | Korat | stub |
| vga_renderer | video | Korat | stub |
| board_memory | game | Korat | stub |
| tetromino | game | Teerawit | stub |
| collision | game | Teerawit | stub |
| lfsr | game | Teerawit | stub |
| game_fsm | game | Pornnapat | stub |
| line_clear | game | Pornnapat | stub |
| score_level | game | Nassasi | stub |
| tetris_top | top | Pholawath | stub |
