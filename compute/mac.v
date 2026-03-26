module mac(
    input [3:0] data,
    input [3:0] weight,
    input clk,
    input rst_n,
    output [7:0] accum_out
);
    wire [7:0] mult_out;
    reg [7:0] accum_reg;
    // Multiply data and weight
    assign mult_out = data * weight;
    // Accumulate the multiplication result
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            accum_reg <= 0;
        end else begin
            accum_reg <= accum_reg + mult_out;
        end
    end
    assign accum_out = accum_reg;
endmodule