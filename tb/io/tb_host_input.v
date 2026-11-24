// tb_host_input.v — self-checking testbench for host_input
// Contract: print exactly one `TB_PASS tb_host_input` at the end, or `TB_FAIL tb_host_input: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_host_input;
  reg           clk = 0;
  reg           rst = 0;
  reg  [7:0]    rx_data = 0;
  reg           rx_valid = 0;
  wire [5:0]    host_keys;
  wire          link_ok;
  integer errors = 0;

  host_input #(.TIMEOUT_CLKS(100)) dut (
    .clk(clk),
    .rst(rst),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .host_keys(host_keys),
    .link_ok(link_ok)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_host_input.vcd"); $dumpvars(0, tb_host_input); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_host_input: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_host_input")
  end
endmodule
