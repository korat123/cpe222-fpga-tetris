// tetromino.v — owner: Teerawit
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input  [2:0]    piece_type   1-7 = I O T S Z J L
//   input  [1:0]    piece_rot    0-3 clockwise
//   output [15:0]   cells        4 x {dx[1:0],dy[1:0]}
`default_nettype none

module tetromino (
  input  wire [2:0]    piece_type,
  input  wire [1:0]    piece_rot,
  output wire [15:0]   cells
);

  // TODO(Teerawit): implement. Stub outputs are tied to safe idle values.
  assign cells = 16'd0;

endmodule

`default_nettype wire
