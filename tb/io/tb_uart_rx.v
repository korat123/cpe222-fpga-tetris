// tb_uart_rx.v — self-checking testbench for uart_rx
// Contract: print exactly one `TB_PASS tb_uart_rx` at the end, or `TB_FAIL tb_uart_rx: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_uart_rx;
  reg           clk = 0;
  reg           rst = 0;
  reg           rx = 1;
  wire [7:0]    rx_data;
  wire          rx_valid;
  wire          rx_error;
  integer errors = 0;

  uart_rx #(.CLKS_PER_BIT(4)) dut (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .rx_error(rx_error)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_uart_rx.vcd"); $dumpvars(0, tb_uart_rx); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_uart_rx: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_uart_rx")
  end
endmodule
