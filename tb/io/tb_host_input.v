// tb_host_input.v — self-checking testbench for host_input
// Contract: print exactly one `TB_PASS tb_host_input` at the end, or `TB_FAIL tb_host_input: <reason>`.
// Uses the real uart_rx in front of host_input so bytes travel the same way as on the board
// (send_byte drives the rx line bit by bit at CLKS_PER_BIT). Covers docs/input-controller.md
// section 8 (tb_host_input) and the host-side cases of section 7: wrong header dropped, steady
// heartbeat never times out, cable pulled while LEFT is held -> keys released + link_ok = 0 after
// TIMEOUT_CLKS, bad bytes do not extend the timeout, after reset keys = 0 and link_ok = 0.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_host_input;
  localparam CPB     = 8;     // small CLKS_PER_BIT
  localparam TIMEOUT = 2000;  // small TIMEOUT_CLKS (one byte takes 10*CPB = 80 clocks)

  reg           clk = 0;
  reg           rst = 0;
  reg           rx = 1;
  wire [7:0]    rx_data;
  wire          rx_valid;
  wire          rx_error;
  wire [5:0]    host_keys;
  wire          link_ok;
  integer errors = 0;

  uart_rx #(.CLKS_PER_BIT(CPB)) u_uart_rx (
    .clk(clk), .rst(rst), .rx(rx),
    .rx_data(rx_data), .rx_valid(rx_valid), .rx_error(rx_error)
  );

  host_input #(.TIMEOUT_CLKS(TIMEOUT)) dut (
    .clk(clk),
    .rst(rst),
    .rx_data(rx_data),
    .rx_valid(rx_valid),
    .host_keys(host_keys),
    .link_ok(link_ok)
  );

  always #5 clk = ~clk;  // 100 MHz

  // ---------- helpers ----------
  integer now = 0, t_good = 0, t_drop, link_drops = 0;
  reg link_d = 0;
  always @(posedge clk) begin
    now <= now + 1;
    if (rx_valid && rx_data[7:6] == 2'b10) t_good <= now;  // last good byte
    link_d <= link_ok;
    if (link_d && !link_ok) begin link_drops <= link_drops + 1; t_drop <= now; end
  end

  task bit_time(input b);
    begin rx = b; repeat (CPB) @(posedge clk); end
  endtask

  task send_byte(input [7:0] data, input stop);
    integer i;
    begin
      bit_time(1'b0);
      for (i = 0; i < 8; i = i + 1) bit_time(data[i]);
      bit_time(stop);
      rx = 1'b1;
      repeat (4) @(posedge clk);  // let uart_rx + host_input register the byte
    end
  endtask

  task gap(input integer n);
    begin rx = 1'b1; repeat (n) @(posedge clk); end
  endtask

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_host_input.vcd"); $dumpvars(0, tb_host_input); end

    // after reset: no keys, no link, until the first good byte
    rst = 1; repeat (4) @(posedge clk); rst = 0;
    gap(TIMEOUT + 100);
    `CHECK(host_keys == 6'd0 && link_ok == 1'b0, "after reset: keys 0, link_ok 0")

    // first good byte: LEFT held
    send_byte(8'h81, 1'b1);
    `CHECK(host_keys == 6'h01 && link_ok, "0x81 -> LEFT, link up")

    // wrong headers are dropped (00, 01, 11) — keys stay LEFT
    send_byte(8'h01, 1'b1); send_byte(8'h41, 1'b1); send_byte(8'hFF, 1'b1);
    `CHECK(host_keys == 6'h01, "wrong header must be ignored")

    // more key combinations from the protocol table
    send_byte(8'h89, 1'b1); `CHECK(host_keys == 6'h09, "0x89 -> LEFT + SOFT_DROP")
    send_byte(8'hBF, 1'b1); `CHECK(host_keys == 6'h3F, "0xBF -> all six keys")
    send_byte(8'h80, 1'b1); `CHECK(host_keys == 6'h00 && link_ok, "0x80 -> no key, link still up")

    // steady heartbeat every 50 ms (scaled: every TIMEOUT/5) for 4 x TIMEOUT: link never drops
    repeat (20) begin send_byte(8'h81, 1'b1); gap(TIMEOUT / 5); end
    `CHECK(link_drops == 0, "heartbeat must keep the link up")
    `CHECK(host_keys == 6'h01 && link_ok, "heartbeat keeps LEFT held")

    // cable pulled while LEFT is held, but junk still arrives (bad header, bad stop bit):
    // keys must be released TIMEOUT clocks after the last GOOD byte
    send_byte(8'h41, 1'b1); gap(TIMEOUT / 4);
    send_byte(8'h81, 1'b0); gap(TIMEOUT / 4);
    send_byte(8'hC1, 1'b1);
    gap(TIMEOUT);
    `CHECK(link_drops == 1, "link must drop once after the timeout")
    `CHECK(host_keys == 6'd0 && link_ok == 1'b0, "timeout: all keys released, link_ok 0")
    `CHECK(t_drop - t_good >= TIMEOUT - 2 && t_drop - t_good <= TIMEOUT + 2,
           "timeout must count from the last good byte only")

    // link comes back with the next good byte
    send_byte(8'h84, 1'b1);
    `CHECK(host_keys == 6'h04 && link_ok, "link back after a good byte")

    // reset while connected
    #1 rst = 1; @(posedge clk); #1 rst = 0;  // #1: change rst away from the clock edge
    `CHECK(host_keys == 6'd0 && link_ok == 1'b0, "reset clears keys and link")

    `TB_FINISH("tb_host_input")
  end
endmodule
