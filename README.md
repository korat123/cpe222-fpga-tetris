# FPGA Tetris: Adaptive Falling Block Puzzle Game

CPE222 Digital Electronics and Logic Design — final project by **PingPeem Fanclub Official TH**.
Tetris written entirely in Verilog on the Digilent **Nexys A7-100T** (no CPU, no software), shown on VGA 640×480.

![CI](../../actions/workflows/ci.yml/badge.svg)

## Team
| Member | GitHub | Owns |
|---|---|---|
| Korat Keaukob | @korat-gh | vga_sync, vga_renderer, screen layout, board_memory, clock_enable |
| Nassasi Treesuptavee | @nassasi-gh | score_level, seven_segment, game UI, documentation |
| Teerawit Ekwonganan | @teerawit-gh | tetromino, collision, movement, lfsr |
| Pornnapat Poonpolsub | @pornnapat-gh | game_fsm, line_clear, testbenches & verification |
| Pholawath Channukool | @pholawath-gh | tetris_top, button_control, constraints, board testing, demo |

Ownership is the default; tasks can be taken over openly (see [CONTRIBUTING.md](CONTRIBUTING.md)). Actual contributions: [docs/CONTRIBUTIONS.md](docs/CONTRIBUTIONS.md).

## Quick start
- **New here?** Read [CONTRIBUTING.md](CONTRIBUTING.md) (Thai, GitHub Desktop steps).
- **Simulate:** `bash scripts/sim/run_all.sh` (needs Icarus Verilog) — or just push and let CI run it.
- **Vivado:** Tcl Console → `source scripts/vivado/create_project.tcl` → open `build/vivado/tetris.xpr`.
- **Rules for humans and AI agents:** [AGENTS.md](AGENTS.md).

## Repository map
| Folder | What lives there |
|---|---|
| `rtl/` | Synthesizable Verilog, one module per file (`common`, `io`, `video`, `game`, `features`, `top`) |
| `tb/` | Self-checking testbenches mirroring `rtl/` |
| `constraints/` | The single Nexys A7 XDC |
| `scripts/` | Vivado, simulation, CI and GitHub scripts |
| `docs/` | Interfaces, architecture, testing, meetings, decisions, proposal, report, slides |
| `media/` | Small images (waveforms, board photos, UI); video links in `media/VIDEOS.md` |

## Controls
BTNL/BTNR move · BTNU rotate · BTND soft drop · BTNC start/pause · SW0 restart

## Status
See the Projects board and milestones P0–P6. Bitstreams are attached to GitHub Releases.

---
© 2026 PingPeem Fanclub Official TH. All rights reserved. Coursework for CPE222 — not licensed for reuse in coursework.
