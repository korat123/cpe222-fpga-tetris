// tb_powerup_controller.v — self-checking testbench for powerup_controller
// Contract: print exactly one `TB_PASS tb_powerup_controller` at the end, or `TB_FAIL tb_powerup_controller: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_powerup_controller;
  reg           clk = 0;
  reg           rst = 0;
  reg           tick_second = 0;
  reg           playing = 0;
  reg           pause = 0;
  reg           clear_done = 0;
  reg  [2:0]    lines_cleared = 0;
  reg           use_bomb = 0;
  reg           use_freeze = 0;
  reg           bomb_done = 0;
  wire [3:0]    charges;
  wire          bomb_req;
  wire          freeze_active;
  wire [2:0]    freeze_remaining;
  wire          no_charge;
  integer errors = 0;

  powerup_controller dut (
    .clk(clk),
    .rst(rst),
    .tick_second(tick_second),
    .playing(playing),
    .pause(pause),
    .clear_done(clear_done),
    .lines_cleared(lines_cleared),
    .use_bomb(use_bomb),
    .use_freeze(use_freeze),
    .bomb_done(bomb_done),
    .charges(charges),
    .bomb_req(bomb_req),
    .freeze_active(freeze_active),
    .freeze_remaining(freeze_remaining),
    .no_charge(no_charge)
  );

  always #5 clk = ~clk;  // 100 MHz
  initial begin rst = 1; repeat (4) @(posedge clk); rst = 0; end

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_powerup_controller.vcd"); $dumpvars(0, tb_powerup_controller); end
    repeat (20) @(posedge clk);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_powerup_controller: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_powerup_controller")
  end
endmodule
