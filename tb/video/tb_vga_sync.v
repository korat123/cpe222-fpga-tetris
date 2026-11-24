// tb_vga_sync.v — self-checking testbench for vga_sync
// Contract: print exactly one `TB_PASS tb_vga_sync` at the end, or `TB_FAIL tb_vga_sync: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_vga_sync;
  reg           clk = 0;
  reg           rst = 0;
  reg           tick_pixel = 0;
  wire          hsync;
  wire          vsync;
  wire          video_on;
  wire [9:0]    pixel_x;
  wire [9:0]    pixel_y;
  integer errors = 0;

  vga_sync dut (
    .clk(clk),
    .rst(rst),
    .tick_pixel(tick_pixel),
    .hsync(hsync),
    .vsync(vsync),
    .video_on(video_on),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_vga_sync.vcd"); $dumpvars(0, tb_vga_sync); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_vga_sync: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_vga_sync")
  end
endmodule
