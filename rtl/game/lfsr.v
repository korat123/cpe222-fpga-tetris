// lfsr.v — owner: Teerawit
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          
//   input           rst          
//   input           seed_load    
//   input  [15:0]   seed         from free-running counter at start
//   input           step         
//   output [2:0]    piece_type   always 1-7
`default_nettype none

module lfsr (
  input  wire          clk,
  input  wire          rst,
  input  wire          seed_load,
  input  wire [15:0]   seed,
  input  wire          step,
  output wire [2:0]    piece_type
);

  // TODO(Teerawit): implement. Stub outputs are tied to safe idle values.
  assign piece_type = 3'd1;

endmodule

`default_nettype wire
