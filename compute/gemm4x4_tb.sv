// gemm_4x4_tb.v — Verify: Identity × Data = Data
`timescale 1ns/1ps
module gemm_4x4_tb;
  reg clk=0, rst_n=0, start=0, valid_in=0;
  reg signed [7:0] a_row[0:3], b_col[0:3];
  wire signed [31:0] c[0:3][0:3];
  wire done;

  gemm_4x4 #(.K(4)) uut(.*);
  always #5 clk=~clk;

  integer i;
  initial begin
    rst_n=0; #20; rst_n=1; #10;
    // A = Identity 4×4, B = [[1,2,3,4],[5,6,7,8],...]
    // Expected: C = B (identity × B = B)
    start=1; @(posedge clk); start=0;
    for (i=0; i<4; i++) begin
      a_row[0]=i==0?1:0; a_row[1]=i==1?1:0;
      a_row[2]=i==2?1:0; a_row[3]=i==3?1:0;
      b_col[0]=i*4+1; b_col[1]=i*4+2;
      b_col[2]=i*4+3; b_col[3]=i*4+4;
      valid_in=1; @(posedge clk);
    end
    valid_in=0;
    wait(done); #10;
    $display("C[0][0]=%0d (exp 1)", c[0][0]);
    $display("C[1][1]=%0d (exp 6)", c[1][1]);
    $display("C[3][3]=%0d (exp 16)", c[3][3]);
    $finish;
  end
endmodule