// tb_uart_rx.v — self-checking testbench for uart_rx
// Contract: print exactly one `TB_PASS tb_uart_rx` at the end, or `TB_FAIL tb_uart_rx: <reason>`.
// Covers docs/input-controller.md section 8 (tb_uart_rx): 0x80, 0x81, 0xBF, back-to-back bytes,
// bad stop bit -> rx_error, a short glitch is not a start bit. The task send_byte drives the rx
// line bit by bit (start, 8 data bits LSB first, stop) for CLKS_PER_BIT clocks each.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_uart_rx;
  localparam CPB = 8;  // small CLKS_PER_BIT so the simulation is fast

  reg           clk = 0;
  reg           rst = 0;
  reg           rx = 1;
  wire [7:0]    rx_data;
  wire          rx_valid;
  wire          rx_error;
  integer errors = 0;

  uart_rx #(.CLKS_PER_BIT(CPB)) dut (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .rx_error(rx_error)
  );

  always #5 clk = ~clk;  // 100 MHz

  // ---------- monitors ----------
  integer n_valid = 0, n_error = 0;
  reg [7:0] got [0:15];
  reg       valid_d = 0;
  always @(posedge clk) begin
    valid_d <= rx_valid;
    if (rx_valid) begin got[n_valid] <= rx_data; n_valid <= n_valid + 1; end
    if (rx_error) n_error <= n_error + 1;
    if (rx_valid && valid_d) begin errors = errors + 1; $display("CHECK FAILED at %0t: rx_valid longer than 1 cycle", $time); end
    if (rx_valid && rx_error) begin errors = errors + 1; $display("CHECK FAILED at %0t: rx_valid and rx_error together", $time); end
  end

  // ---------- rx driver ----------
  task bit_time(input b);
    begin rx = b; repeat (CPB) @(posedge clk); end
  endtask

  task send_byte(input [7:0] data, input stop);
    integer i;
    begin
      bit_time(1'b0);                                   // start bit
      for (i = 0; i < 8; i = i + 1) bit_time(data[i]);  // LSB first
      bit_time(stop);                                   // stop bit (1 = good)
      rx = 1'b1;
    end
  endtask

  task idle(input integer n);
    begin rx = 1'b1; repeat (n) @(posedge clk); end
  endtask

  task expect_byte(input [7:0] data, input integer count, input [8*40-1:0] what);
    begin
      idle(3 * CPB);
      `CHECK(n_valid == count, what)
      if (n_valid == count) `CHECK(got[count-1] == data, what)
      `CHECK(n_error == 0, "no rx_error expected")
    end
  endtask

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_uart_rx.vcd"); $dumpvars(0, tb_uart_rx); end

    // reset, line idle: nothing comes out
    rst = 1; repeat (4) @(posedge clk); rst = 0;
    idle(5 * CPB);
    `CHECK(n_valid == 0 && n_error == 0, "idle line must not produce pulses")

    // single bytes from the protocol table
    send_byte(8'h80, 1'b1); expect_byte(8'h80, 1, "0x80 (no key)");
    send_byte(8'h81, 1'b1); expect_byte(8'h81, 2, "0x81 (LEFT)");
    send_byte(8'hBF, 1'b1); expect_byte(8'hBF, 3, "0xBF (all keys)");
    `CHECK(rx_data == 8'hBF, "rx_data must hold the last byte")

    // back-to-back bytes: next start bit right after the stop bit
    send_byte(8'h81, 1'b1); send_byte(8'h89, 1'b1); send_byte(8'hA5, 1'b1);
    idle(3 * CPB);
    `CHECK(n_valid == 6, "three back-to-back bytes")
    `CHECK(got[3] == 8'h81 && got[4] == 8'h89 && got[5] == 8'hA5, "back-to-back bytes in order")

    // bad stop bit: rx_error, no rx_valid, and the receiver recovers afterwards
    send_byte(8'h55, 1'b0);
    repeat (2) @(posedge clk);
    idle(4 * CPB);
    `CHECK(n_error == 1, "bad stop bit must give rx_error")
    `CHECK(n_valid == 6, "bad stop bit must not give rx_valid")
    send_byte(8'h80, 1'b1); idle(3 * CPB);
    `CHECK(n_valid == 7 && got[6] == 8'h80, "receiver recovers after a bad stop bit")

    // short glitch (shorter than half a bit) is not a start bit
    rx = 1'b0; repeat (CPB/2 - 1) @(posedge clk); rx = 1'b1;
    idle(12 * CPB);
    `CHECK(n_valid == 7 && n_error == 1, "glitch must be ignored")
    send_byte(8'h83, 1'b1); idle(3 * CPB);
    `CHECK(n_valid == 8 && got[7] == 8'h83, "good byte after a glitch")

    // reset in the middle of a byte: no pulse, then normal reception
    rx = 1'b0; repeat (3 * CPB) @(posedge clk);
    rst = 1; repeat (2) @(posedge clk); rst = 0;
    idle(12 * CPB);
    send_byte(8'h84, 1'b1); idle(3 * CPB);
    `CHECK(n_valid == 9 && got[8] == 8'h84, "good byte after reset")
    `CHECK(n_error == 1, "reset mid-byte must not create errors")

    `TB_FINISH("tb_uart_rx")
  end
endmodule
