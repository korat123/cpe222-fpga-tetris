// tetromino.v — owner: Korat
// Shape ROM: which 4 cells a piece covers for a given type and rotation (combinational, no clock).
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input  [2:0]    piece_type   1-7 = I O T S Z J L (0 = empty -> cells = 0)
//   input  [1:0]    piece_rot    0-3 clockwise, 0 = spawn orientation
//   output [15:0]   cells        4 x {dx[1:0],dy[1:0]}: cell k = cells[4k+3:4k], dx = [4k+3:4k+2]
//
// (dx, dy) are offsets from the top-left of the piece's 4x4 box = (piece_x, piece_y);
// dx grows to the right, dy grows down. Cell order has no meaning.
// Rotation follows SRS (no wall kicks — game_fsm cancels a rotation that collides):
//   I turns inside a 4x4 box, O never moves, T S Z J L turn inside the top-left 3x3 box.
// Each line below: 16'b cell3_cell2_cell1_cell0, then the shape drawn row by row (top / ... / bottom).
`default_nettype none
`include "tetris_defs.vh"

module tetromino (
  input  wire [2:0]    piece_type,
  input  wire [1:0]    piece_rot,
  output reg  [15:0]   cells
);

  always @* begin
    cells = 16'd0;  // default: empty / unknown type
    case ({piece_type, piece_rot})
      {`P_I, 2'd0}: cells = 16'b1101_1001_0101_0001;  // .... / #### / .... / ....
      {`P_I, 2'd1}: cells = 16'b1011_1010_1001_1000;  // ..#. / ..#. / ..#. / ..#.
      {`P_I, 2'd2}: cells = 16'b1110_1010_0110_0010;  // .... / .... / #### / ....
      {`P_I, 2'd3}: cells = 16'b0111_0110_0101_0100;  // .#.. / .#.. / .#.. / .#..
      {`P_O, 2'd0}: cells = 16'b1001_0101_1000_0100;  // .##. / .##. / .... / ....
      {`P_O, 2'd1}: cells = 16'b1001_0101_1000_0100;  // .##. / .##. / .... / ....
      {`P_O, 2'd2}: cells = 16'b1001_0101_1000_0100;  // .##. / .##. / .... / ....
      {`P_O, 2'd3}: cells = 16'b1001_0101_1000_0100;  // .##. / .##. / .... / ....
      {`P_T, 2'd0}: cells = 16'b1001_0101_0001_0100;  // .#. / ### / ...
      {`P_T, 2'd1}: cells = 16'b0110_1001_0101_0100;  // .#. / .## / .#.
      {`P_T, 2'd2}: cells = 16'b0110_1001_0101_0001;  // ... / ### / .#.
      {`P_T, 2'd3}: cells = 16'b0110_0101_0001_0100;  // .#. / ##. / .#.
      {`P_S, 2'd0}: cells = 16'b0101_0001_1000_0100;  // .## / ##. / ...
      {`P_S, 2'd1}: cells = 16'b1010_1001_0101_0100;  // .#. / .## / ..#
      {`P_S, 2'd2}: cells = 16'b0110_0010_1001_0101;  // ... / .## / ##.
      {`P_S, 2'd3}: cells = 16'b0110_0101_0001_0000;  // #.. / ##. / .#.
      {`P_Z, 2'd0}: cells = 16'b1001_0101_0100_0000;  // ##. / .## / ...
      {`P_Z, 2'd1}: cells = 16'b0110_1001_0101_1000;  // ..# / .## / .#.
      {`P_Z, 2'd2}: cells = 16'b1010_0110_0101_0001;  // ... / ##. / .##
      {`P_Z, 2'd3}: cells = 16'b0010_0101_0001_0100;  // .#. / ##. / #..
      {`P_J, 2'd0}: cells = 16'b1001_0101_0001_0000;  // #.. / ### / ...
      {`P_J, 2'd1}: cells = 16'b0110_0101_1000_0100;  // .## / .#. / .#.
      {`P_J, 2'd2}: cells = 16'b1010_1001_0101_0001;  // ... / ### / ..#
      {`P_J, 2'd3}: cells = 16'b0110_0010_0101_0100;  // .#. / .#. / ##.
      {`P_L, 2'd0}: cells = 16'b1001_0101_0001_1000;  // ..# / ### / ...
      {`P_L, 2'd1}: cells = 16'b1010_0110_0101_0100;  // .#. / .#. / .##
      {`P_L, 2'd2}: cells = 16'b0010_1001_0101_0001;  // ... / ### / #..
      {`P_L, 2'd3}: cells = 16'b0110_0101_0100_0000;  // ##. / .#. / .#.
      default:            cells = 16'd0;
    endcase
  end

endmodule

`default_nettype wire
