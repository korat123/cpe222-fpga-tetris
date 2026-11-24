# AGENTS.md — CHAOTETRIS, FPGA Tetris (CPE222)

Instructions for ALL AI coding agents (Claude Code, Codex, Copilot, Cursor, Gemini, Jules…) and a
cheat-sheet for humans. If anything here conflicts with a teammate's instruction in the issue/PR,
STOP and ask in the issue. Keep this file under 200 lines.

## 1. Project
- Graded university project: CHAOTETRIS, an arcade falling-block game in Verilog-2001 on Digilent
  Nexys A7-100T (Artix-7, part xc7a100tcsg324-1), AMD Vivado. VGA 640x480@60, 7-seg, LEDs.
- Core: 7 tetrominoes, 10x20 board, move/rotate/soft drop, collision, line clear, score, rising level.
  Signature features: power-up charges (+1 per 5 lines) for BOMB (clears locked cells in a 3x3 area)
  and FREEZE (no auto-fall for 5 s); CHAOS event every 30 s for 5 s (reversed L/R or double speed,
  picked by LFSR); COMBO bonus; demo timer switch. Spec: docs/INTERFACES.md, docs/ARCHITECTURE.md.
- Controls: laptop keyboard / game controller via scripts/host/bridge.py over UART
  (docs/input-controller.md). Board buttons are backup: BTNL/BTNR move, BTNU rotate, BTND soft drop,
  BTNC use power-up selected by SW1. SW0 reset, SW2 demo timer, SW15 pause. LED15 = host link.
- Optional special features (P5 only) go in rtl/features/ and must be switchable off by a parameter.
- Deadlines: final proposal 2026-11-30; presentation + submission 2026-12-11. Feature freeze at P4.
- Owners: see README "Team" table and .github/CODEOWNERS. Owners are the default, not a lock —
  teammates may take over a task (see §9).

## 2. Repo map
rtl/{common,io,video,game,features,top}/  synthesizable RTL, one module per file
rtl/include/tetris_defs.vh                 shared constants
tb/<same area>/tb_<module>.v               self-checking testbenches; tb/vectors/<module>/ data
constraints/nexys_a7_100t.xdc              the ONLY XDC
scripts/{vivado,sim,ci,github,host}/       automation; host/ = laptop bridge (Python)
docs/INTERFACES.md                         port contract (source of truth for module ports)
docs/{ARCHITECTURE,TESTING,CONTRIBUTIONS}.md, docs/{decisions,meetings,diagrams,proposal,report,slides}/
media/{waveforms/<module>,board,ui}/       small images only; videos are links in media/VIDEOS.md
build/                                     generated output — ignored, never commit

## 3. Commands
bash scripts/sim/run_all.sh            # all testbenches (Icarus) — what CI "sim" runs
bash scripts/sim/run_tb.sh tb_<module> [--dump]
python3 scripts/ci/check_layout.py     # what CI "layout" runs
make check                             # layout + lint + sim (needs make, verilator, iverilog)
Vivado: source scripts/vivado/create_project.tcl → build/vivado/tetris.xpr
Run the relevant checks before proposing a commit. Never claim tests pass without running them.

## 4. RTL rules (non-negotiable)
- ONE clock: `clk` (100 MHz). Never generate clocks from logic or use a counter bit as a clock.
  Slower rates = one-cycle enable pulses from timers (`tick_pixel`, `tick_fall`, `tick_second`).
  Pause/freeze gate these enables, never the clock.
- Reset: `rst`, synchronous, active-high. Only tetris_top makes it (CPU_RESETN active-low, SW0).
- Only game_fsm changes the board; power-up, chaos and line_clear modules only send requests.
- Sequential: `always @(posedge clk)` with `<=` only. Combinational: `always @*` with `=`,
  default assignments first (no latches). No `initial` blocks in RTL.
- Names: lower_snake_case; file name = module name; `_q` registered, `_next` next-state,
  `_n` active-low, UPPER_SNAKE parameters/macros, `S_` FSM states, `u_` instance prefix.
- Every RTL file starts with `` `default_nettype none `` and ends with `` `default_nettype wire ``.
- Buttons and SW1/SW2/SW15 are synchronized + debounced (and OR-ed with host keys) ONLY in
  button_control. Only tetris_top touches board pins.
- No vendor primitives/IP without a decision record in docs/decisions/.

## 5. Interface contract
- Never add, remove, rename or resize a port without updating docs/INTERFACES.md in the SAME PR
  and tagging the people whose modules connect to it.
- If a task needs another module's ports to change, propose it in the issue first.

## 6. Testing
- Every rtl/<area>/<m>.v has tb/<area>/tb_<m>.v (CI enforces this).
- Testbenches self-check with `CHECK(cond, "msg") from tb/include/tb_utils.vh and end with
  `TB_FINISH("tb_<m>") which prints `TB_PASS tb_<m>` or `TB_FAIL tb_<m>: ...`. Finish in < 120 s.
- Remove the "STUB" note once real checks exist. Waveforms only with +dump, under build/sim/.
- Bug fix ⇒ first add a test case that fails, then fix until it passes.

## 7. File placement (decide before creating ANY file)
generated? → don't commit (build/) | RTL → rtl/<area>/ | sim-only → tb/<area>/ |
constraint → the existing XDC | script → scripts/<vivado|sim|ci|github|host>/ | writing → docs/<subfolder>/ |
image → media/ (PNG/JPG < 1 MB, YYYYMMDD-desc.png) | video → link in media/VIDEOS.md |
external code → third_party/<name>/ + THIRD_PARTY_NOTICES.md | none fits → ask in the issue.
Never create files in the repo root. Never add a second XDC, a sandbox folder, or copies like
*_old.v / *_v2.v (git keeps history). Experiments live on `exp/` branches, never merged.

## 8. Things AI must NOT do
- Commit generated files (.xpr, .runs, .cache, .jou, .log, .bit, .vcd, .wdb) or large binaries.
- Invent or change pin assignments, I/O standards or clock constraints. Pins come ONLY from
  Digilent's master XDC; if unsure, leave a TODO and ask in the issue.
- Weaken .github/, scripts/ci/, AGENTS.md, CLAUDE.md or CI settings to make a failing check pass.
- Push to main, force-push, rewrite history, merge PRs, create tags/releases or change repo settings.
  (Humans merge their own PRs; AI only prepares branches and PR text.)
- Edit a module whose issue is assigned to someone else unless the human you work for has taken
  over that issue (§9).
- Add licenses, dependencies, third-party code, personal data (student IDs, phone numbers) or secrets.
- Fabricate evidence (waveforms, test output, board results) or write someone's
  "individual contribution" text for the report.

## 9. Git workflow (flexible team mode)
- Branch per issue: `<type>/<issue#>-<short-name>`, type = feat|fix|test|docs|chore|exp.
- Commits: `type(module): imperative summary` (≤ 72 chars), body says why, `Refs #<issue>`.
- The human who runs `git commit` is the author, from their own GitHub account and verified email.
- Everything reaches main through a PR. Review by a teammate is welcome but NOT required:
  the author may self-review and merge once CI is green (checklist in the PR template).
  Exceptions — get a second person to look (or announce in the group chat) before merging:
  constraints/*.xdc changes and port changes used by other modules.
- Merge with "Create a merge commit" only (keeps each person's commits for grading).
- Taking over someone's task: reassign the issue to yourself and write one line why. Commit under
  your own account. If both worked on it, add `Co-authored-by: Name <email>`. Never commit
  someone else's code under your name or yours under theirs.
- If main's CI goes red after a merge: whoever merged last fixes it within ~1 hour or reverts.

## 10. AI attribution (academic integrity)
- Commits that AI materially shaped end with the trailer `Assisted-by: <tool>` (e.g.
  `Assisted-by: Claude Code`), and the PR's AI checkbox says what it was used for.
- The human author must understand and be able to explain every line at the demo.

## 11. Handoff protocol (humans ⇄ AI, AI ⇄ AI)
At the end of every session, post a comment on the issue (not a repo file):
  ### Handoff — <date> — <who / which tool>
  Branch: … | Last commit: … | Status: done / partial / blocked
  Done: … | Next steps: … | Open questions: … | Tests run + result: …
A new agent/session MUST read the issue thread and the latest handoff before changing anything.

## 12. Definition of done (per PR)
CI green (layout, lint, sim) · testbench added/updated · INTERFACES.md current · evidence image in
the PR · self-review checklist ticked · files in the correct folders.
