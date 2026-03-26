module weight_reg(
    input [3:0] weight,
    input [3:0] weight_address,
    input [3:0] pc,
    output [3:0] weight_mem;
)
    wire [3:0] weight_reg [31:0];

    // store the data at the address input to the memory
    assign weight_reg[weight_address] = weight;
    assign weight_mem = weight_reg[pc];

endmodule