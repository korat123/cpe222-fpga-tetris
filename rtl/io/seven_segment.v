// seven_segment.v — 8-digit active-low score display
`default_nettype none

module seven_segment (
  input  wire          clk,
  input  wire          rst,
  input  wire [23:0]   score_bcd,
  output reg  [7:0]    an,
  output reg  [6:0]    seg
);

  // 100 MHz / 12,500 clocks = 8,000 digit selections/s (1,000 full scans/s).
  localparam [13:0] SCAN_DIVIDER = 14'd12499;
  reg [13:0] scan_count_q;
  reg [2:0] digit_q;
  reg [3:0] digit_value;

  always @(posedge clk) begin
    if (rst) begin
      scan_count_q <= 14'd0;
      digit_q <= 3'd0;
    end else if (scan_count_q == SCAN_DIVIDER) begin
      scan_count_q <= 14'd0;
      digit_q <= digit_q + 3'd1;
    end else begin
      scan_count_q <= scan_count_q + 14'd1;
    end
  end

  always @* begin
    an = 8'hFF;
    an[digit_q] = 1'b0;
    digit_value = 4'd0;
    case (digit_q)
      3'd0: digit_value = score_bcd[3:0];
      3'd1: digit_value = score_bcd[7:4];
      3'd2: digit_value = score_bcd[11:8];
      3'd3: digit_value = score_bcd[15:12];
      3'd4: digit_value = score_bcd[19:16];
      3'd5: digit_value = score_bcd[23:20];
      default: an = 8'hFF;
    endcase

    case (digit_value)
      4'd0: seg = 7'b1000000;
      4'd1: seg = 7'b1111001;
      4'd2: seg = 7'b0100100;
      4'd3: seg = 7'b0110000;
      4'd4: seg = 7'b0011001;
      4'd5: seg = 7'b0010010;
      4'd6: seg = 7'b0000010;
      4'd7: seg = 7'b1111000;
      4'd8: seg = 7'b0000000;
      4'd9: seg = 7'b0010000;
      default: seg = 7'b1111111;
    endcase
  end

endmodule

`default_nettype wire
