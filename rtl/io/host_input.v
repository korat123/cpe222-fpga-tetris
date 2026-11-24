// host_input.v — owner: Korat
// Turns bytes from uart_rx into the 6 held host keys. Spec: docs/input-controller.md section 4.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   parameter TIMEOUT_CLKS = 25_000_000  250 ms without a valid byte -> release all keys
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input  [7:0]    rx_data      from uart_rx
//   input           rx_valid     1-cycle pulse from uart_rx
//   output [5:0]    host_keys    level {FREEZE,BOMB,SOFT_DROP,ROTATE,RIGHT,LEFT}; 0 after reset/timeout
//   output          link_ok      level: 1 = valid byte (header 10) within TIMEOUT_CLKS
//
// A byte is valid only if bits [7:6] = 2'b10. Invalid bytes are dropped and do NOT restart the
// timeout, so a crashed bridge or a pulled cable releases every key within TIMEOUT_CLKS.
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

  function integer clog2(input integer value);
    integer v;
    begin
      clog2 = 0;
      for (v = value - 1; v > 0; v = v >> 1) clog2 = clog2 + 1;
    end
  endfunction

  localparam TW = (clog2(TIMEOUT_CLKS) < 1) ? 1 : clog2(TIMEOUT_CLKS);
  localparam [TW-1:0] LAST = TIMEOUT_CLKS - 1;

  reg [5:0]    keys_q;
  reg          link_q;
  reg [TW-1:0] timer_q;

  wire good_byte = rx_valid && (rx_data[7:6] == 2'b10);

  always @(posedge clk) begin
    if (rst) begin
      keys_q  <= 6'd0;
      link_q  <= 1'b0;
      timer_q <= {TW{1'b0}};
    end else if (good_byte) begin
      keys_q  <= rx_data[5:0];
      link_q  <= 1'b1;
      timer_q <= {TW{1'b0}};
    end else if (link_q) begin
      if (timer_q == LAST) begin
        keys_q <= 6'd0;   // timeout: release every key
        link_q <= 1'b0;
      end else begin
        timer_q <= timer_q + 1'b1;
      end
    end
  end

  assign host_keys = keys_q;
  assign link_ok   = link_q;

endmodule

`default_nettype wire
