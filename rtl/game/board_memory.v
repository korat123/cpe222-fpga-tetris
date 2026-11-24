// board_memory.v — owner: Korat
// The 10x20 playfield: 3 bits per cell (0 empty, 1-7 piece type), exposed as one flat bus.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high; clears the board
//   input           we           1-cycle: write one cell (from game_fsm only)
//   input  [3:0]    wx           0-9
//   input  [4:0]    wy           0-19
//   input  [2:0]    wdata        0 empty, 1-7 piece type
//   input           shift_en     1-cycle: remove row shift_row, rows above drop (from game_fsm only)
//   input  [4:0]    shift_row    0-19
//   output [599:0]  board        registered, cell (x,y) = board[(y*10+x)*3 +: 3]
//
// Layout: row y = board[y*30 +: 30], y = 0 is the top row.
// Priority on each clock edge: rst > shift_en > we (a write in the same cycle as a shift is dropped).
// Out-of-range inputs (wx > 9, wy > 19, shift_row > 19) are ignored, so a bomb clear that sends
// x = -1 (4'd15) or y = 20 near a corner never touches another cell.
`default_nettype none
`include "tetris_defs.vh"

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

  localparam ROW_BITS = `BOARD_W * `CELL_BITS;  // 30 bits per row

  reg [599:0] board_q;
  integer y;

  always @(posedge clk) begin
    if (rst) begin
      board_q <= 600'd0;
    end else if (shift_en && shift_row < `BOARD_H) begin
      // rows 1..shift_row take the row above them; row 0 becomes empty; rows below stay
      for (y = 1; y < `BOARD_H; y = y + 1)
        if (y <= shift_row)
          board_q[y*ROW_BITS +: ROW_BITS] <= board_q[(y-1)*ROW_BITS +: ROW_BITS];
      board_q[0 +: ROW_BITS] <= {ROW_BITS{1'b0}};
    end else if (we && wx < `BOARD_W && wy < `BOARD_H) begin
      board_q[(wy*`BOARD_W + wx)*`CELL_BITS +: `CELL_BITS] <= wdata;
    end
  end

  assign board = board_q;

endmodule

`default_nettype wire
