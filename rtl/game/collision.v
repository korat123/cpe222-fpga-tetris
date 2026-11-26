// collision.v — owner: Korat
// Says whether a piece at a test position would leave the board or overlap a locked cell
// (combinational, no clock). game_fsm asks before every move, rotation, fall and spawn.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input  [4:0]    test_x       signed, may be negative (the 4x4 box can hang left of the board)
//   input  [4:0]    test_y       unsigned, top of the 4x4 box
//   input  [15:0]   cells        from tetromino: cell k = cells[4k+3:4k] = {dx[1:0], dy[1:0]}
//   input  [599:0]  board        locked cells, cell (x, y) = board[(y*10+x)*3 +: 3], 0 = empty
//   output          collide      1 = some cell is outside x 0..9 / y 0..19, or on a non-empty cell
//
// For each of the 4 cells: x = test_x + dx (6-bit signed, -16..18), y = test_y + dy (6-bit, 0..34).
`default_nettype none
`include "tetris_defs.vh"

module collision (
  input  wire [4:0]    test_x,
  input  wire [4:0]    test_y,
  input  wire [15:0]   cells,
  input  wire [599:0]  board,
  output reg           collide
);

  integer k;
  reg signed [5:0] cell_x;
  reg        [5:0] cell_y;
  reg        [8:0] cell_idx;   // y*10 + x, 0..199

  always @* begin
    collide  = 1'b0;
    cell_x   = 6'sd0;
    cell_y   = 6'd0;
    cell_idx = 9'd0;
    for (k = 0; k < 4; k = k + 1) begin
      cell_x = $signed({test_x[4], test_x}) + $signed({4'b0000, cells[4*k+2 +: 2]});
      cell_y = {1'b0, test_y} + {4'b0000, cells[4*k +: 2]};
      if (cell_x < 0 || cell_x > `BOARD_W - 1 || cell_y > `BOARD_H - 1) begin
        collide = 1'b1;
      end else begin
        cell_idx = cell_y[4:0] * 4'd10 + {5'd0, cell_x[3:0]};
        if (board[cell_idx*3 +: 3] != 3'd0)
          collide = 1'b1;
      end
    end
  end

endmodule

`default_nettype wire
