// tetris_top.v — owner: Pholawath
// STATUS: STUB (ports only). Replace the assigns below with the real design.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           CLK100MHZ    board clock
//   input           CPU_RESETN   board reset, active-low
//   input           BTNC         
//   input           BTNU         
//   input           BTNL         
//   input           BTNR         
//   input           BTND         
//   input  [15:0]   SW           SW0 reset, SW1 power-up select, SW2 demo timer, SW15 pause
//   input           UART_TXD_IN  UART from the USB-UART bridge (laptop -> FPGA), idle 1
//   output [15:0]   LED          
//   output          CA           
//   output          CB           
//   output          CC           
//   output          CD           
//   output          CE           
//   output          CF           
//   output          CG           
//   output          DP           
//   output [7:0]    AN           
//   output [3:0]    VGA_R        
//   output [3:0]    VGA_G        
//   output [3:0]    VGA_B        
//   output          VGA_HS       
//   output          VGA_VS       
`default_nettype none

module tetris_top (
  input  wire          CLK100MHZ,
  input  wire          CPU_RESETN,
  input  wire          BTNC,
  input  wire          BTNU,
  input  wire          BTNL,
  input  wire          BTNR,
  input  wire          BTND,
  input  wire [15:0]   SW,
  input  wire          UART_TXD_IN,
  output wire [15:0]   LED,
  output wire          CA,
  output wire          CB,
  output wire          CC,
  output wire          CD,
  output wire          CE,
  output wire          CF,
  output wire          CG,
  output wire          DP,
  output wire [7:0]    AN,
  output wire [3:0]    VGA_R,
  output wire [3:0]    VGA_G,
  output wire [3:0]    VGA_B,
  output wire          VGA_HS,
  output wire          VGA_VS
);

  // TODO(Pholawath): implement. Stub outputs are tied to safe idle values.
  assign LED = 16'd0;
  assign CA = 1'b1;
  assign CB = 1'b1;
  assign CC = 1'b1;
  assign CD = 1'b1;
  assign CE = 1'b1;
  assign CF = 1'b1;
  assign CG = 1'b1;
  assign DP = 1'b1;
  assign AN = 8'hFF;
  assign VGA_R = 4'd0;
  assign VGA_G = 4'd0;
  assign VGA_B = 4'd0;
  assign VGA_HS = 1'b1;
  assign VGA_VS = 1'b1;

endmodule

`default_nettype wire
