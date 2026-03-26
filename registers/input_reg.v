module input_reg(
    input [3:0] data,
    input [3:0] data_address,
    input [3:0] pc,
    output [3:0] data_mem;
)
    wire [3:0] data_reg [31:0];

    // store the data at the address input to the memory
    assign data_reg[data_address] = data;
    assign data_mem = data_reg[pc];

endmodule