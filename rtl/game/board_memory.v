// board_memory.v — owner: Korat
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high; clears the board
//   input           we           1-cycle: write one cell (from game_fsm only)
//   input  [3:0]    wx           0-9
//   input  [4:0]    wy           0-19
//   input  [2:0]    wdata        0 empty, 1-7 piece type
//   input           shift_en     1-cycle: remove row shift_row, rows above drop (from game_fsm only)
//   input  [4:0]    shift_row    
//   output [599:0]  board        registered, index y*10+x
`default_nettype none

module board_memory (
  input  wire          clk,
  input  wire          rst,
  input  wire          we,
  input  wire [3:0]    wx,
  input  wire [4:0]    wy,
  input  wire [2:0]    wdata,
  input  wire          shift_en,
  input  wire [4:0]    shift_row,
  output wire [599:0]  board
);

  // TODO(Korat): implement. Stub outputs are tied to safe idle values.
  assign board = 600'd0;

endmodule

`default_nettype wire
