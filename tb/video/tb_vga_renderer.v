// tb_vga_renderer.v — self-checking testbench for vga_renderer
// Contract: print exactly one `TB_PASS tb_vga_renderer` at the end, or `TB_FAIL tb_vga_renderer: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_vga_renderer;
  reg           clk = 0;
  reg           rst = 0;
  reg  [9:0]    pixel_x = 0;
  reg  [9:0]    pixel_y = 0;
  reg           video_on = 0;
  reg  [599:0]  board = 0;
  reg  [2:0]    piece_type = 0;
  reg  [2:0]    next_type = 0;
  reg  [1:0]    piece_rot = 0;
  reg  [3:0]    piece_x = 0;
  reg  [4:0]    piece_y = 0;
  reg  [23:0]   score_bcd = 0;
  reg  [3:0]    level = 0;
  reg  [2:0]    game_state = 0;
  wire [3:0]    vga_r;
  wire [3:0]    vga_g;
  wire [3:0]    vga_b;
  integer errors = 0;

  vga_renderer dut (
    .clk(clk),
    .rst(rst),
    .pixel_x(pixel_x),
    .pixel_y(pixel_y),
    .video_on(video_on),
    .board(board),
    .piece_type(piece_type),
    .next_type(next_type),
    .piece_rot(piece_rot),
    .piece_x(piece_x),
    .piece_y(piece_y),
    .score_bcd(score_bcd),
    .level(level),
    .game_state(game_state),
    .vga_r(vga_r),
    .vga_g(vga_g),
    .vga_b(vga_b)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_vga_renderer.vcd"); $dumpvars(0, tb_vga_renderer); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_vga_renderer: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_vga_renderer")
  end
endmodule
