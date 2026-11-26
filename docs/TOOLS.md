# Tools — install, run tests, read waveforms

Start with [GETTING-STARTED.md](GETTING-STARTED.md) if you are new. The commands below were tested on Windows 11.
Linux/macOS: install the same tools with your package manager and use the same commands.

## 1. What you need
| To do this | You need |
|---|---|
| Edit files, commit, open PRs | Git in a terminal ([CONTRIBUTING.md](../CONTRIBUTING.md)) |
| Run testbenches on your PC | Icarus Verilog (`iverilog`, `vvp`) + Git Bash |
| Lint like CI | Verilator |
| Look at waveforms | GTKWave |
| Build a bitstream / program the board | AMD Vivado (lab PC is fine) |
| Play with keyboard / controller | Python 3.10+, `pygame`, `pyserial` |

You can skip the simulator tools and let CI run the tests on every push, but local runs are much faster
when you are debugging.

## 2. Windows setup
1. **Git for Windows** (gives Git Bash): https://git-scm.com
2. **MSYS2**: install from https://www.msys2.org, then open the *MSYS2 UCRT64* terminal and run
   ```
   pacman -S --needed mingw-w64-ucrt-x86_64-iverilog mingw-w64-ucrt-x86_64-verilator mingw-w64-ucrt-x86_64-gtkwave
   ```
   Add `C:\msys64\ucrt64\bin` to your Windows `PATH` (Start → "Edit the system environment variables").
   Check in Git Bash: `iverilog -V` and `gtkwave --version`.
3. **Python** 3.10+ from https://www.python.org (tick "Add python.exe to PATH"), then in PowerShell:
   ```
   py -m pip install pygame pyserial
   ```
4. **Vivado**: see `scripts/vivado/` and CONTRIBUTING §5. Never commit the Vivado project; it lives in `build/`.

## 3. Run the tests
Run these in **Git Bash** from the repo folder.

| Command | What it does |
|---|---|
| `bash scripts/sim/run_tb.sh tb_board_memory` | compile + run one testbench, prints `TB_PASS` / `TB_FAIL` |
| `bash scripts/sim/run_tb.sh tb_board_memory --dump` | same, and writes `build/sim/tb_board_memory.vcd` for GTKWave |
| `bash scripts/sim/run_all.sh` | every testbench, like CI `sim` (stubs show "PASS (stub, no checks yet)") |
| `python scripts/ci/check_layout.py` | file names and places, like CI `layout` |
| lint (see below) | Verilog warnings/errors, like CI `lint` |

**Lint on Windows.** The `verilator` wrapper from MSYS2 needs Perl modules that Git Bash does not have,
so call the binary directly and tell it where its files are:
```
VERILATOR_ROOT="C:/msys64/ucrt64/share/verilator" verilator_bin --lint-only -Wall -Wno-fatal -Wno-DECLFILENAME \
  -Irtl/include $(find rtl -name '*.v' ! -path 'rtl/features/*') --top-module tetris_top
```
For one module only: `... -Irtl/include rtl/game/board_memory.v --top-module board_memory`. Aim for zero warnings in your own module.

**Reading a failure.** The log shows `CHECK FAILED at <time>: <message>`. The time is in picoseconds
(`150000` = 150 ns). Re-run with `--dump` and jump to that time in GTKWave.

**Mutation test (recommended before a PR).** Break one line of your RTL on purpose (a wrong condition,
a missing reset) and run your tb again. It must FAIL. If it still passes, your tb is missing a check.
Undo the change afterwards.

## 4. Read a waveform (GTKWave)
```
bash scripts/sim/run_tb.sh tb_uart_rx --dump
cd build/sim && gtkwave tb_uart_rx.vcd
```
- **Window:** the module tree is at top left (click `tb_<module>`) · the signal list is at bottom left · the
  chosen signals are in the middle · the waves are on the right.
- **Add signals:** select them in the bottom-left list (Ctrl for several) → *Append*, or drag them to the middle.
- **Zoom:** *Time → Zoom → Zoom Best Fit* first; then Ctrl + mouse wheel to zoom.
- **Read a value:** left-click in the wave area to put the red marker; the middle column shows every value at that time.
- **Number format:** right-click a signal → *Data Format* → Binary / Hex / Decimal.
- **Save your layout:** *File → Write Save File* (`.gtkw`, keep it in `build/sim/`), then open with
  `gtkwave tb_x.vcd tb_x.gtkw`. After a new run use *File → Reload Waveform*.
- **Screenshot for a PR:** Win + Shift + S, then paste into the PR.

**How to read it without getting lost:**
1. Look at `errors` first. If it is 0 the whole time, every check passed.
2. Then answer one question at a time. Zoom to the moment you care about and look only at 3–4 signals.
   For example:
   - **uart_rx:** `rx` goes 0 (start bit), then 8 data bits of equal length, then `rx_valid` is 1 for one clock
     and `rx_data` shows the byte.
   - **host_input:** `link_ok` falls to 0 and `host_keys` becomes `00` at the same time, after the timeout.
   - **button_control:** while `btn_raw` holds BTNL, `move_left` shows 1 pulse, a longer gap, then evenly spaced pulses.

## 5. Host bridge (laptop keyboard / controller)
```
py scripts/host/bridge.py --dry-run     # no board: prints the bytes it would send
py scripts/host/bridge.py               # finds the board's USB-UART port
py scripts/host/bridge.py --port COM5   # choose the port yourself
py scripts/host/bridge.py --list-pad    # show controller button numbers
```
Full guide in Thai: [scripts/host/README.md](../scripts/host/README.md). Protocol: [input-controller.md](input-controller.md).

## 6. Troubleshooting (problems we already hit)
| Symptom | Cause | Fix |
|---|---|---|
| `py scripts/host/bridge.py` → `No module named 'pygame'` although pip says it is installed | The Windows `py` launcher follows the first line of the script; `#!/usr/bin/env python3` picked MSYS2's Python | Fixed in the script (`#!/usr/bin/python3`). For other scripts use `py -3 script.py`. |
| `verilator` → `Can't locate Pod/Usage.pm` | MSYS2's Perl wrapper run from Git Bash | Use `verilator_bin` (section 3) |
| `verilator_bin` → `Cannot find verilated_std.sv` | Verilator does not know its install folder | Set `VERILATOR_ROOT="C:/msys64/ucrt64/share/verilator"` |
| Text shows `�` or `â€”` on GitHub | File saved in a Windows code page, not UTF-8 | Save as UTF-8 (VS Code: bottom bar → encoding → *Save with Encoding* → UTF-8) |
| Git warns `CRLF will be replaced by LF` | Windows line endings; `.gitattributes` normalises them | Nothing to do |
| A tb passes or fails "randomly" after a small change | Inputs change exactly at the clock edge, so the result depends on simulator order | Change inputs away from the edge: `@(posedge clk); #1 rst = 0;` |
| A `` `CHECK `` inside `if … else` never runs | `` `CHECK `` is an `if` inside, so a bare `else` attaches to it | Wrap it: `if (a) begin `CHECK(...) end else begin ... end` |
| `iverilog: command not found` | `C:\msys64\ucrt64\bin` is not in PATH | Add it (section 2) and reopen the terminal |
