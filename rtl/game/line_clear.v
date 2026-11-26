// line_clear.v — owner: Korat
// Finds full rows after a piece locks and asks game_fsm to remove them, one at a time.
// It never writes the board itself (AGENTS §4): game_fsm forwards shift_req/shift_row to
// board_memory as board_shift_en/shift_row.
// Port contract: docs/INTERFACES.md — change ports only together with that file.
//   input           clk          100 MHz system clock
//   input           rst          sync, active-high
//   input           start        1-cycle pulse from game_fsm (ignored while busy)
//   input  [599:0]  board        from board_memory, cell (x, y) = board[(y*10+x)*3 +: 3]
//   output          busy         level: 1 from the cycle after start until done
//   output          done         1-cycle pulse: finished (clear_done), busy is 0 in the same cycle
//   output          shift_req    1-cycle pulse: ask game_fsm to remove shift_row
//   output [4:0]    shift_row    row to remove, valid with shift_req
//   output [2:0]    lines_cleared 0-4 in normal play (saturates at 7), valid from done until next start
//
// How it works: check one row per clock from the bottom (19) to the top (0).
//   full row  -> shift_req for that row, wait SHIFT_WAIT_CLKS clocks for board_memory to drop
//                the rows above, then check the SAME row again (a full row may have dropped into it)
//   not full  -> go one row up; after row 0 -> done
// SHIFT_WAIT_CLKS = 2 covers a game_fsm that forwards shift_req directly or through one register:
// the board must show the shift within SHIFT_WAIT_CLKS + 1 clocks after shift_req is high.
`default_nettype none
`include "tetris_defs.vh"

module line_clear #(
  parameter SHIFT_WAIT_CLKS = 2
) (
  input  wire          clk,
  input  wire          rst,
  input  wire          start,
  input  wire [599:0]  board,
  output wire          busy,
  output reg           done,
  output reg           shift_req,
  output wire [4:0]    shift_row,
  output wire [2:0]    lines_cleared
);

  localparam S_IDLE  = 2'd0;
  localparam S_CHECK = 2'd1;
  localparam S_WAIT  = 2'd2;

  reg [1:0] state_q;
  reg [4:0] row_q;
  reg [2:0] count_q;
  reg [3:0] wait_q;

  assign busy          = (state_q != S_IDLE);
  assign shift_row     = row_q;
  assign lines_cleared = count_q;

  // is row row_q full? (all 10 cells non-zero)
  integer x;
  reg [8:0] cell_idx;   // row_q * 10 + x, 0..199
  reg       row_is_full;
  always @* begin
    cell_idx    = 9'd0;
    row_is_full = 1'b1;
    for (x = 0; x < `BOARD_W; x = x + 1) begin
      cell_idx = row_q * 4'd10 + x[8:0];
      if (board[cell_idx*3 +: 3] == 3'd0)
        row_is_full = 1'b0;
    end
  end

  always @(posedge clk) begin
    if (rst) begin
      state_q   <= S_IDLE;
      row_q     <= 5'd0;
      count_q   <= 3'd0;
      wait_q    <= 4'd0;
      done      <= 1'b0;
      shift_req <= 1'b0;
    end else begin
      done      <= 1'b0;
      shift_req <= 1'b0;
      case (state_q)
        S_IDLE: begin
          if (start) begin
            row_q   <= `BOARD_H - 1;
            count_q <= 3'd0;
            state_q <= S_CHECK;
          end
        end
        S_CHECK: begin
          if (row_is_full) begin
            shift_req <= 1'b1;
            if (count_q != 3'd7) count_q <= count_q + 3'd1;
            wait_q    <= SHIFT_WAIT_CLKS - 1;
            state_q   <= S_WAIT;
          end else if (row_q == 5'd0) begin
            done    <= 1'b1;
            state_q <= S_IDLE;
          end else begin
            row_q <= row_q - 5'd1;
          end
        end
        S_WAIT: begin
          if (wait_q == 4'd0) state_q <= S_CHECK;   // check the same row again
          else                wait_q  <= wait_q - 4'd1;
        end
        default: state_q <= S_IDLE;
      endcase
    end
  end

endmodule

`default_nettype wire
