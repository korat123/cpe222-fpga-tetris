// uart_rx.v — owner: Korat
// UART receiver, 8 data bits, no parity, 1 stop bit (8N1), LSB first. Spec: docs/input-controller.md.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   parameter CLKS_PER_BIT = 868  100 MHz / 115200 baud
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input           rx           UART line from the USB-UART bridge (idle 1), asynchronous
//   output [7:0]    rx_data      received byte, valid when rx_valid = 1 (held until the next byte)
//   output          rx_valid     1-cycle pulse per byte with a good stop bit
//   output          rx_error     1-cycle pulse: bad stop bit, byte dropped
//
// How it works: rx is synchronized with 2 flip-flops. A falling edge starts a byte; half a bit
// later the line must still be 0 (otherwise it was a glitch). Then every CLKS_PER_BIT clocks the
// middle of the next bit is sampled: 8 data bits, then the stop bit. After a bad stop bit the
// receiver waits until the line is idle (1) again before looking for the next start bit.
`default_nettype none

module uart_rx #(
  parameter CLKS_PER_BIT = 868
) (
  input  wire          clk,
  input  wire          rst,
  input  wire          rx,
  output wire [7:0]    rx_data,
  output wire          rx_valid,
  output wire          rx_error
);

  // width of the bit-time counter (Verilog-2001 constant function instead of $clog2)
  function integer clog2(input integer value);
    integer v;
    begin
      clog2 = 0;
      for (v = value - 1; v > 0; v = v >> 1) clog2 = clog2 + 1;
    end
  endfunction

  localparam CW = (clog2(CLKS_PER_BIT) < 1) ? 1 : clog2(CLKS_PER_BIT);
  localparam [CW-1:0] FULL = CLKS_PER_BIT - 1;
  localparam [CW-1:0] HALF = CLKS_PER_BIT / 2 - 1;

  localparam [2:0] S_IDLE  = 3'd0,
                   S_START = 3'd1,
                   S_DATA  = 3'd2,
                   S_STOP  = 3'd3,
                   S_WAIT  = 3'd4;  // after a bad stop bit: wait for idle line

  reg [1:0]    rx_sync_q;
  reg [2:0]    state_q;
  reg [CW-1:0] count_q;
  reg [2:0]    bit_q;
  reg [7:0]    shift_q;
  reg [7:0]    data_q;
  reg          valid_q;
  reg          error_q;

  wire rx_s = rx_sync_q[1];

  always @(posedge clk) begin
    if (rst) begin
      rx_sync_q <= 2'b11;
      state_q   <= S_IDLE;
      count_q   <= {CW{1'b0}};
      bit_q     <= 3'd0;
      shift_q   <= 8'd0;
      data_q    <= 8'd0;
      valid_q   <= 1'b0;
      error_q   <= 1'b0;
    end else begin
      rx_sync_q <= {rx_sync_q[0], rx};
      valid_q   <= 1'b0;
      error_q   <= 1'b0;
      case (state_q)
        S_IDLE: begin
          count_q <= {CW{1'b0}};
          if (!rx_s) state_q <= S_START;
        end
        S_START: begin  // middle of the start bit
          if (count_q == HALF) begin
            count_q <= {CW{1'b0}};
            bit_q   <= 3'd0;
            state_q <= rx_s ? S_IDLE : S_DATA;  // back to 1 = glitch, not a start bit
          end else begin
            count_q <= count_q + 1'b1;
          end
        end
        S_DATA: begin   // middle of each data bit, LSB first
          if (count_q == FULL) begin
            count_q <= {CW{1'b0}};
            shift_q <= {rx_s, shift_q[7:1]};
            bit_q   <= bit_q + 1'b1;
            if (bit_q == 3'd7) state_q <= S_STOP;
          end else begin
            count_q <= count_q + 1'b1;
          end
        end
        S_STOP: begin   // middle of the stop bit
          if (count_q == FULL) begin
            count_q <= {CW{1'b0}};
            if (rx_s) begin
              data_q  <= shift_q;
              valid_q <= 1'b1;
              state_q <= S_IDLE;
            end else begin
              error_q <= 1'b1;
              state_q <= S_WAIT;
            end
          end else begin
            count_q <= count_q + 1'b1;
          end
        end
        S_WAIT: begin
          if (rx_s) state_q <= S_IDLE;
        end
        default: state_q <= S_IDLE;
      endcase
    end
  end

  assign rx_data  = data_q;
  assign rx_valid = valid_q;
  assign rx_error = error_q;

endmodule

`default_nettype wire
