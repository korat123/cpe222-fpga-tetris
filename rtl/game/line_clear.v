// line_clear.v — owner: Pornnapat
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          
//   input           rst          
//   input           start        
//   input  [599:0]  board        
//   output          busy         
//   output          done         
//   output          shift_en     
//   output [4:0]    shift_row    
//   output [2:0]    lines_cleared 0-4
`default_nettype none

module line_clear (
  input  wire          clk,
  input  wire          rst,
  input  wire          start,
  input  wire [599:0]  board,
  output wire          busy,
  output wire          done,
  output wire          shift_en,
  output wire [4:0]    shift_row,
  output wire [2:0]    lines_cleared
);

  // TODO(Pornnapat): implement. Stub outputs are tied to safe idle values.
  assign busy = 1'b0;
  assign done = 1'b0;
  assign shift_en = 1'b0;
  assign shift_row = 5'd0;
  assign lines_cleared = 3'd0;

endmodule

`default_nettype wire
