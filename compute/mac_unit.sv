// mac_unit.v — Pipelined INT8 MAC Unit for FPGA Neural Network
// 3-stage pipeline: Stage1=Multiply, Stage2=Accumulate, Stage3=Output
// Uses DSP58E2 inference — Xilinx synthesis will map to DSP blocks

module mac_unit #(
  parameter DATA_W  = 8,   // INT8 input width
  parameter PROD_W  = 16,  // 8x8 = 16-bit product
  parameter ACCUM_W = 32   // 32-bit accumulator (safe for 256 accumulations)
)(
  input  wire                  clk,
  input  wire                  rst_n,
  input  wire                  clear,     // clear accumulator (new dot product)
  input  wire                  valid_in,  // input data is valid
  input  wire signed [DATA_W-1:0] a,      // weight (INT8 signed)
  input  wire signed [DATA_W-1:0] b,      // activation (INT8 signed)
  output reg  signed [ACCUM_W-1:0] accum, // accumulated result
  output reg                   valid_out  // output valid
);

  // Pipeline Stage 1: Multiply
  reg signed [PROD_W-1:0]  product;
  reg                       valid_s1;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      product  <= 0;
      valid_s1 <= 0;
    end else begin
      product  <= a * b;          // 8x8 = 16-bit signed multiply
      valid_s1 <= valid_in;
    end
  end

  // Pipeline Stage 2: Accumulate (sign-extend product to 32-bit)
  reg signed [ACCUM_W-1:0] product_ext;
  reg                       valid_s2;
  reg                       clear_s2;

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      product_ext <= 0;
      valid_s2    <= 0;
      clear_s2    <= 0;
    end else begin
      product_ext <= {{(ACCUM_W-PROD_W){product[PROD_W-1]}}, product}; // sign extend
      valid_s2    <= valid_s1;
      clear_s2    <= clear;
    end
  end

  // Pipeline Stage 3: Accumulate or Clear
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      accum     <= 0;
      valid_out <= 0;
    end else begin
      valid_out <= valid_s2;
      if (clear_s2)
        accum <= product_ext;           // start new accumulation
      else if (valid_s2)
        accum <= accum + product_ext;   // accumulate
    end
  end

endmodule