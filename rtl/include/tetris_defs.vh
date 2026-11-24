// tetris_defs.vh — shared constants. Changing a value = interface change (see docs/INTERFACES.md).
`ifndef TETRIS_DEFS_VH
`define TETRIS_DEFS_VH
`define BOARD_W      10
`define BOARD_H      20
`define CELL_BITS    3
// piece types (0 = empty)
`define P_EMPTY 3'd0
`define P_I     3'd1
`define P_O     3'd2
`define P_T     3'd3
`define P_S     3'd4
`define P_Z     3'd5
`define P_J     3'd6
`define P_L     3'd7
// game states
`define S_IDLE      3'd0
`define S_SPAWN     3'd1
`define S_FALL      3'd2
`define S_LOCK      3'd3
`define S_CLEAR     3'd4
`define S_GAME_OVER 3'd5
// button bit order in btn_raw / btn_pulse
`define BTN_L 0
`define BTN_R 1
`define BTN_U 2
`define BTN_D 3
`define BTN_C 4
`endif
