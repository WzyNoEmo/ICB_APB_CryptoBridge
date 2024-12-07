module des_tb;
    logic clk;
    logic [63:0] data ;
    logic data_vld;
    logic [63:0] key;
    logic [63:0] result; // 将logic数组转换为打包数组
    logic result_vld;

    //clk
    always begin
        #5 clk = ~clk;
    end

    initial begin
        clk = 1'b0;
        data_vld <= 1'b0;
        #100;
        data <= 64'b0110001101101111011011010111000001110101011101000110010101110010;
        data_vld <= 1'b1;
        key <=  64'b0001001100110100010101110111100110011011101111001101111111110001;
        #10;
        data_vld <= 1'b0;
    end


    encrypt uut (
        .clk(clk),
        .data(data),
        .data_vld(data_vld),
        .key(key),
        .result(result),
        .result_vld(result_vld)
    );

endmodule