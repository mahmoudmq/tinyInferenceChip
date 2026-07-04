// gemm_4x4.v — 4×4 Output-Stationary GEMM Engine (INT8)
// Computes C[4][4] += A[4][K] × B[K][4]
// 16 parallel MAC units, one per output element

module gemm_4x4 #(
  parameter K     = 64,   // inner dimension (tile size)
  parameter DW    = 8,    // data width (INT8)
  parameter AW    = 32    // accumulator width
)(
  input  wire        clk, rst_n,
  input  wire        start,           // begin computation
  input  wire signed [DW-1:0] a_row [0:3], // A row broadcast (4 elements)
  input  wire signed [DW-1:0] b_col [0:3], // B col broadcast (4 elements)
  input  wire        valid_in,        // data valid
  output reg  signed [AW-1:0] c [0:3][0:3], // 4×4 output tile
  output reg         done             // computation complete
);

  // Inner product counters
  reg [$clog2(K):0] k_cnt;
  reg computing;

  integer i, j;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      for (i = 0; i < 4; i++) for (j = 0; j < 4; j++) c[i][j] <= 0;
      k_cnt     <= 0;
      computing <= 0;
      done      <= 0;
    end else begin
      done <= 0;
      if (start) begin
        // Clear accumulators, begin
        for (i = 0; i < 4; i++) for (j = 0; j < 4; j++) c[i][j] <= 0;
        k_cnt     <= 0;
        computing <= 1;
      end else if (computing && valid_in) begin
        // Accumulate: 16 MACs in parallel
        for (i = 0; i < 4; i++)
          for (j = 0; j < 4; j++)
            c[i][j] <= c[i][j] + ({{(AW-DW){a_row[i][DW-1]}}, a_row[i]}
                                 * {{(AW-DW){b_col[j][DW-1]}}, b_col[j]});
        k_cnt <= k_cnt + 1;
        if (k_cnt == K - 1) begin
          computing <= 0;
          done      <= 1;  // tile complete
        end
      end
    end
  end

endmodule