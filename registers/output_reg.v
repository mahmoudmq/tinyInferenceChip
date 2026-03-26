module output_reg(
    input [7:0] mac_out,
    input clk,
    input rst_n,
    output reg [7:0] result
);
    always @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            result <= 0;
        end else begin
            result <= mac_out;
        end
    end
endmodule