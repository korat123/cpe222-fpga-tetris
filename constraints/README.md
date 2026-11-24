# constraints/
**Purpose:** board pin and clock constraints.
**What belongs here:** only `nexys_a7_100t.xdc`.
**What does NOT belong here:** a second XDC, hand-typed pins, Vivado-generated constraint files.
**Owner:** Pholawath. Changes: get a second person to look, or announce in the group chat before merging.

| tetris_top port | Board resource | Used for |
|---|---|---|
| CLK100MHZ | 100 MHz oscillator | system clock |
| CPU_RESETN | CPU RESET button | hardware reset (active-low) |
| BTNL/BTNR/BTNU/BTND/BTNC | push buttons | move / rotate / soft drop / start-pause |
| SW[0] | slide switch 0 | restart |
| LED[15:0] | LEDs | level / pause / game over |
| CA..CG, DP, AN[7:0] | 7-segment | score |
| VGA_R/G/B[3:0], VGA_HS, VGA_VS | VGA port | 640×480 display |
