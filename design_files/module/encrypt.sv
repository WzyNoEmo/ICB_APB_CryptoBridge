module encrypt(

    input  logic clk,

// input signal

    input logic [63:0] data,
    input logic data_vld,
    input logic [63:0] key,

// output signal

    output logic [63:0] result,
    output logic result_vld
);

// algorithm : no encrypt
assign result = data;
assign result_vld = data_vld;

// algorithm : xor
//assign result = data ^ key;
//assign result_vld = data_vld;

endmodule