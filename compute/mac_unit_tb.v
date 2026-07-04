// mac_unit_tb.v — Testbench: compute dot product [2,3,4] · [1,2,3] = 2+6+12 = 20
`timescale 1ns/1ps

module mac_unit_tb;
  reg        clk = 0, rst_n = 0, clear = 0, valid_in = 0;
  reg  signed [7:0] a, b;
  wire signed [31:0] accum;
  wire valid_out;

  mac_unit uut(.clk(clk),.rst_n(rst_n),.clear(clear),
               .valid_in(valid_in),.a(a),.b(b),
               .accum(accum),.valid_out(valid_out));

  always #5 clk = ~clk; // 100MHz clock

  initial begin
    rst_n = 0; #20; rst_n = 1;

    // Dot product: a=[2,3,4], b=[1,2,3] → expected = 20
    @(posedge clk); clear=1; valid_in=1; a=2; b=1; // 2*1=2
    @(posedge clk); clear=0; valid_in=1; a=3; b=2; // 3*2=6
    @(posedge clk); valid_in=1; a=4; b=3;           // 4*3=12
    @(posedge clk); valid_in=0;

    #50;
    $display("Dot product result: %0d (expected 20)", accum);
    if (accum == 20) $display("PASS ✓");
    else             $display("FAIL ✗");
    $finish;
  end
endmodule