// board_memory.v — owner: Korat
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          
//   input           rst          clears board
//   input           we           write one cell
//   input  [3:0]    wx           
//   input  [4:0]    wy           
//   input  [2:0]    wdata        0 empty, 1-7 piece type
//   input           shift_en     remove row shift_row, rows above drop
//   input  [4:0]    shift_row    
//   output [599:0]  board        
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
