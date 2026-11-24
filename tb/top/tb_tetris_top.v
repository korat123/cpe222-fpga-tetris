// tb_tetris_top.v — self-checking testbench for tetris_top
// Contract: print exactly one `TB_PASS tb_tetris_top` at the end, or `TB_FAIL tb_tetris_top: <reason>`.
// STATUS: STUB — compiles and runs, but has NO real checks yet (prints STUB). Owner adds cases.
`timescale 1ns/1ps
`include "tb_utils.vh"

module tb_tetris_top;
  reg           CLK100MHZ = 0;
  reg           CPU_RESETN = 1;
  reg           BTNC = 0;
  reg           BTNU = 0;
  reg           BTNL = 0;
  reg           BTNR = 0;
  reg           BTND = 0;
  reg  [15:0]   SW = 0;
  reg           UART_TXD_IN = 1;  // UART idle
  wire [15:0]   LED;
  wire          CA;
  wire          CB;
  wire          CC;
  wire          CD;
  wire          CE;
  wire          CF;
  wire          CG;
  wire          DP;
  wire [7:0]    AN;
  wire [3:0]    VGA_R;
  wire [3:0]    VGA_G;
  wire [3:0]    VGA_B;
  wire          VGA_HS;
  wire          VGA_VS;
  integer errors = 0;

  tetris_top dut (
    .CLK100MHZ(CLK100MHZ),
    .CPU_RESETN(CPU_RESETN),
    .BTNC(BTNC),
    .BTNU(BTNU),
    .BTNL(BTNL),
    .BTNR(BTNR),
    .BTND(BTND),
    .SW(SW),
    .UART_TXD_IN(UART_TXD_IN),
    .LED(LED),
    .CA(CA),
    .CB(CB),
    .CC(CC),
    .CD(CD),
    .CE(CE),
    .CF(CF),
    .CG(CG),
    .DP(DP),
    .AN(AN),
    .VGA_R(VGA_R),
    .VGA_G(VGA_G),
    .VGA_B(VGA_B),
    .VGA_HS(VGA_HS),
    .VGA_VS(VGA_VS)
  );

  always #5 CLK100MHZ = ~CLK100MHZ;  // 100 MHz

  initial begin
    if ($test$plusargs("dump")) begin $dumpfile("build/sim/tb_tetris_top.vcd"); $dumpvars(0, tb_tetris_top); end
    repeat (20) @(posedge CLK100MHZ);
    // TODO: add real test cases with `CHECK(condition, "message")
    $display("NOTE tb_tetris_top: STUB testbench - no functional checks yet");
    `TB_FINISH("tb_tetris_top")
  end
endmodule
