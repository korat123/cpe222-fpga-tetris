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
// game states (game_fsm.game_state)
`define S_RESET     3'd0
`define S_SPAWN     3'd1
`define S_FALL      3'd2
`define S_LOCK      3'd3
`define S_CLEAR     3'd4
`define S_GAME_OVER 3'd5
`define S_BOMB      3'd6
// button bit order in btn_raw (board buttons)
`define BTN_L 0
`define BTN_R 1
`define BTN_U 2
`define BTN_D 3
`define BTN_C 4
// host key bit order in host_keys (docs/input-controller.md section 4)
`define KEY_LEFT      0
`define KEY_RIGHT     1
`define KEY_ROTATE    2
`define KEY_SOFT_DROP 3
`define KEY_BOMB      4
`define KEY_FREEZE    5
// timing
`define CLKS_PER_SECOND      100000000
`define DEMO_CLKS_PER_SECOND 25000000   // PROPOSED — see issue #43 (SW2: 1 s ticks run 4x faster)
// power-ups (proposal)
`define LINES_PER_CHARGE 5
`define BOMB_SIZE        3              // 3x3 area around the active piece anchor
`define FREEZE_LEN_S     5
`define MAX_CHARGES      9              // PROPOSED — see issue #43
// chaos events (proposal)
`define CHAOS_PERIOD_S   30
`define CHAOS_LEN_S      5
`define CHAOS_REVERSE    1'b0           // rand bit value that selects reversed left/right
`define CHAOS_FAST       1'b1           // rand bit value that selects double falling speed
// difficulty
`define LINES_PER_LEVEL  10             // PROPOSED — see issue #43
`endif
