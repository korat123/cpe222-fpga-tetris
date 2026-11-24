# constraints/
**Purpose:** board pin and clock constraints.
**What belongs here:** only `nexys_a7_100t.xdc`.
**What does NOT belong here:** a second XDC, hand-typed pins, Vivado-generated constraint files.
**Owner:** Pholawath. Changes: get a second person to look, or announce in the group chat before merging.

Pins for every row come later from Digilent's master XDC — never typed by hand.

| tetris_top port | Board resource | Used for |
|---|---|---|
| CLK100MHZ | 100 MHz oscillator | system clock |
| CPU_RESETN | CPU RESET button | hardware reset (active-low) |
| BTNL/BTNR/BTNU/BTND/BTNC | push buttons | backup input: move left/right · rotate · soft drop · use selected power-up |
| SW[0] | slide switch 0 | reset |
| SW[1] | slide switch 1 | power-up for BTNC: 0 = bomb, 1 = freeze |
| SW[2] | slide switch 2 | demo timer (short chaos/freeze timers) |
| SW[15] | slide switch 15 | pause (ON = paused) |
| UART_TXD_IN | USB-UART bridge (FT2232, micro-USB) | laptop → FPGA host input, 115200 8N1 |
| LED[15:0] | LEDs | power-up / chaos status; LED15 = host link (PROPOSED — see issue #43) |
| CA..CG, DP, AN[7:0] | 7-segment | score |
| VGA_R/G/B[3:0], VGA_HS, VGA_VS | VGA port | 640×480 display |
