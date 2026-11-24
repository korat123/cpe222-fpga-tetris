// button_control.v — owner: Pholawath
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          
//   input           rst          
//   input  [4:0]    btn_raw      raw buttons {C,D,U,R,L}
//   output [4:0]    btn_pulse    1-cycle pulse per press
//   output [4:0]    btn_level    debounced level
`default_nettype none

module button_control (
  input  wire          clk,
  input  wire          rst,
  input  wire [4:0]    btn_raw,
  output wire [4:0]    btn_pulse,
  output wire [4:0]    btn_level
);

  // TODO(Pholawath): implement. Stub outputs are tied to safe idle values.
  assign btn_pulse = 5'd0;
  assign btn_level = 5'd0;

endmodule

`default_nettype wire
