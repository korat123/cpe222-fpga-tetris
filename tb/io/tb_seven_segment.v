`timescale 1ns/1ps
`default_nettype none
`include "tb_utils.vh"

module tb_seven_segment;
  reg clk = 1'b0;
  reg rst = 1'b1;
  reg [23:0] score_bcd = 24'h987654;
  wire [7:0] an;
  wire [6:0] seg;
  integer errors = 0;
  integer i;
  reg [6:0] expected_seg [0:9];
  reg [3:0] expected_digit [0:7];

  seven_segment dut (
    .clk(clk), .rst(rst), .score_bcd(score_bcd), .an(an), .seg(seg)
  );

  always #5 clk = ~clk;

  initial begin
    if ($test$plusargs("dump")) begin
      $dumpfile("build/sim/tb_seven_segment.vcd");
      $dumpvars(0, tb_seven_segment);
    end
    expected_seg[0] = 7'b1000000;
    expected_seg[1] = 7'b1111001;
    expected_seg[2] = 7'b0100100;
    expected_seg[3] = 7'b0110000;
    expected_seg[4] = 7'b0011001;
    expected_seg[5] = 7'b0010010;
    expected_seg[6] = 7'b0000010;
    expected_seg[7] = 7'b1111000;
    expected_seg[8] = 7'b0000000;
    expected_seg[9] = 7'b0010000;
    expected_digit[0] = 4; expected_digit[1] = 5;
    expected_digit[2] = 6; expected_digit[3] = 7;
    expected_digit[4] = 8; expected_digit[5] = 9;
    expected_digit[6] = 0; expected_digit[7] = 0;

    @(posedge clk); #1;
    rst = 1'b0;
    #1;
    for (i = 0; i < 8; i = i + 1) begin
      if (i >= 6) begin
        `CHECK(an == 8'hFF, "unused digit is disabled")
      end else begin
        `CHECK(an == (8'hFF ^ (8'b1 << i)), "one active-low digit selected")
        `CHECK(seg == expected_seg[expected_digit[i]], "BCD digit segment pattern")
      end
      dut.scan_count_q = 14'd12499;
      @(posedge clk); #1;
    end
    `CHECK(dut.digit_q == 3'd0, "scanner wraps after eight digits")

    // Explicitly check every decimal decoder value, including the segment ordering.
    for (i = 0; i < 10; i = i + 1) begin
      score_bcd = {20'd0, i[3:0]};
      dut.digit_q = 3'd0;
      #1;
      `CHECK(seg == expected_seg[i], "decoder supports decimal digits 0 through 9")
    end
    `TB_FINISH("tb_seven_segment")
  end
endmodule

`default_nettype wire
