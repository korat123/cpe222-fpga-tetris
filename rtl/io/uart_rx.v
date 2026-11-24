// uart_rx.v — owner: Pholawath
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   parameter CLKS_PER_BIT = 868  100 MHz / 115200 baud
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input           rx           UART line from the USB-UART bridge (idle 1), asynchronous
//   output [7:0]    rx_data      received byte, valid when rx_valid = 1
//   output          rx_valid     1-cycle pulse per byte with a good stop bit
//   output          rx_error     1-cycle pulse: bad stop bit, byte dropped
`default_nettype none

module uart_rx #(
  parameter CLKS_PER_BIT = 868
) (
  input  wire          clk,
  input  wire          rst,
  input  wire          rx,
  output wire [7:0]    rx_data,
  output wire          rx_valid,
  output wire          rx_error
);

  // TODO(Pholawath): implement. Stub outputs are tied to safe idle values.
  assign rx_data = 8'd0;
  assign rx_valid = 1'b0;
  assign rx_error = 1'b0;

endmodule

`default_nettype wire
