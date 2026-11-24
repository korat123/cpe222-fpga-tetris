# rtl/
**Purpose:** all synthesizable Verilog — one module per file, file name = module name.
**What belongs here:** `rtl/<common|io|video|game|features|top>/<module>.v`, shared constants in `rtl/include/`.
**What does NOT belong here:** testbenches (→ `tb/`), constraints (→ `constraints/`), copies like `*_old.v`.
**Owners:** see table and `.github/CODEOWNERS`. Port contract: `docs/INTERFACES.md`.

| Module | Folder | Owner | Status (stub / sim-pass / board-pass) |
|---|---|---|---|
| timers | common | Teerawit | stub |
| uart_rx | io | Pholawath | stub |
| host_input | io | Pholawath | stub |
| button_control | io | Pholawath | stub |
| seven_segment | io | Pholawath | stub |
| vga_sync | video | Nassasi | stub |
| vga_renderer | video | Nassasi | stub |
| tetromino | game | Korat | stub |
| collision | game | Korat | stub |
| line_clear | game | Korat | stub |
| board_memory | game | Korat | stub |
| game_fsm | game | Teerawit | stub |
| lfsr | game | Teerawit | stub |
| chaos_controller | game | Teerawit | stub |
| powerup_controller | game | Pornnapat | stub |
| score_combo | game | Pholawath | stub |
| tetris_top | top | Pholawath | stub |
