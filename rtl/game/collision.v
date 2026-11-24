// collision.v — owner: Korat
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input  [4:0]    test_x       signed, may be negative
//   input  [4:0]    test_y       
//   input  [15:0]   cells        from tetromino
//   input  [599:0]  board        
//   output          collide      combinational: 1 = out of bounds or overlap
`default_nettype none

module collision (
  input  wire [4:0]    test_x,
  input  wire [4:0]    test_y,
  input  wire [15:0]   cells,
  input  wire [599:0]  board,
  output wire          collide
);

  // TODO(Korat): implement. Stub outputs are tied to safe idle values.
  assign collide = 1'b0;

endmodule

`default_nettype wire
