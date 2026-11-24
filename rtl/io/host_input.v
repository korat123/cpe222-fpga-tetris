// host_input.v — owner: Pholawath
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   parameter TIMEOUT_CLKS = 25_000_000  250 ms without a valid byte -> release all keys
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input  [7:0]    rx_data      from uart_rx
//   input           rx_valid     1-cycle pulse from uart_rx
//   output [5:0]    host_keys    level {FREEZE,BOMB,SOFT_DROP,ROTATE,RIGHT,LEFT}; 0 after reset/timeout
//   output          link_ok      level: 1 = valid byte (header 10) within TIMEOUT_CLKS
`default_nettype none

module host_input #(
  parameter TIMEOUT_CLKS = 25_000_000
) (
  input  wire          clk,
  input  wire          rst,
  input  wire [7:0]    rx_data,
  input  wire          rx_valid,
  output wire [5:0]    host_keys,
  output wire          link_ok
);

  // TODO(Pholawath): implement. Stub outputs are tied to safe idle values.
  assign host_keys = 6'd0;
  assign link_ok = 1'b0;

endmodule

`default_nettype wire
