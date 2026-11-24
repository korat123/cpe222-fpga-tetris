# CHAOTETRIS: FPGA Arcade Falling-Block Game

CPE222 Digital Electronics and Logic Design — final project by **PingPeem Fanclub Official TH**.
An arcade falling-block game written entirely in Verilog on the Digilent **Nexys A7-100T** (no CPU, no software), shown on VGA 640×480.
Signature features: **BOMB** and **FREEZE** power-ups (1 charge per 5 cleared lines), a **CHAOS** event every 30 s
(reversed controls or double speed for 5 s), **COMBO** bonus, and a demo timer switch. Play with a laptop keyboard or
game controller (via a small host bridge over USB-UART) or with the board buttons as backup.

![CI](../../actions/workflows/ci.yml/badge.svg)

## Team
| Member | GitHub | Owns |
|---|---|---|
| Korat Keaukob | @korat123 | tetromino, collision, line_clear, board_memory (core gameplay/movement) + tests, input path: uart_rx, host_input, button_control + host bridge (`scripts/host/bridge.py`) |
| Nassasi Treesuptavee | @miranassasi | vga_sync, vga_renderer (VGA timing, UI layout, visual effects, pause/effect overlays) + monitor tests |
| Teerawit Ekwonganan | @Atom7792 | game_fsm, lfsr, chaos_controller, timers (incl. pause gating) + timing tests |
| Pornnapat Poonpolsub | @penguinnoiii | powerup_controller (charges, bomb/freeze), testbenches & verification evidence |
| Pholawath Channukool | @XbunGam | score_combo, seven_segment, tetris_top, constraints, README, report, demo video |

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
Main input: laptop keyboard / game controller through the host bridge — see [docs/input-controller.md](docs/input-controller.md)
(←/→ move · ↑ rotate · ↓ soft drop · B bomb · F freeze).

| Board control | Action |
|---|---|
| BTNL / BTNR | move left / right (backup) |
| BTNU | rotate (backup) |
| BTND | soft drop (backup) |
| BTNC | use the power-up selected by SW1 (backup) |
| SW0 | reset |
| SW1 | select power-up for BTNC: 0 = bomb, 1 = freeze |
| SW2 | demo timer (short chaos/freeze timers) |
| SW15 | pause (ON = paused) |

7-segment = score · LEDs = power-up / chaos status, LED15 = host link.

## Status
See the Projects board and milestones P0–P6. Bitstreams are attached to GitHub Releases.

---
© 2026 PingPeem Fanclub Official TH. All rights reserved. Coursework for CPE222 — not licensed for reuse in coursework.
