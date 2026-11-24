// score_level.v — owner: Nassasi
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          
//   input           rst          
//   input           clear_done   
//   input  [2:0]    lines_cleared 
//   output [23:0]   score_bcd    +100/300/500/800
//   output [7:0]    lines        
//   output [3:0]    level        1 + lines/10
`default_nettype none

module score_level (
  input  wire          clk,
  input  wire          rst,
  input  wire          clear_done,
  input  wire [2:0]    lines_cleared,
  output wire [23:0]   score_bcd,
  output wire [7:0]    lines,
  output wire [3:0]    level
);

  // TODO(Nassasi): implement. Stub outputs are tied to safe idle values.
  assign score_bcd = 24'd0;
  assign lines = 8'd0;
  assign level = 4'd0;

endmodule

`default_nettype wire
