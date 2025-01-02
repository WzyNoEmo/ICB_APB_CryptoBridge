// `define DES

module encrypt #(
    parameter DES_TYPE = 1'b1
)
(

    input  logic clk,

// input signal

    input logic [0:63] data,
    input logic data_vld,
    input logic [0:63] key,

// output signal

    output logic [0:63] result,
    output logic result_vld
);

`ifdef DES

    logic [0:63] data_ip;
    logic [0:55] key_pc1;
    logic [0:27] key_c, key_d;
    logic [0:55] key_cd;
    logic [0:47] subkey;

    logic [0:3] round;
    logic data_vld_reg;

// cnt round
    always_ff @( posedge clk ) begin
        if(data_vld == 1'b1) begin
            data_vld_reg <= 1'b1;
        end else if(round == 4'b1111) begin
            data_vld_reg <= 1'b0;
        end
    end

    always_ff @( posedge clk ) begin
        if ( data_vld == 1'b1 ) begin
            round <= 4'b0;
        end else if ( data_vld_reg == 1'b1 ) begin
            round <= round + 4'b1;
        end
    end

// sbox
    logic [0:3] sbox1 [0:3][0:15] = '{
    {4'd14, 4'd4, 4'd13, 4'd1, 4'd2, 4'd15, 4'd11, 4'd8, 4'd3, 4'd10, 4'd6, 4'd12, 4'd5, 4'd9, 4'd0, 4'd7},
    {4'd0, 4'd15, 4'd7, 4'd4, 4'd14, 4'd2, 4'd13, 4'd1, 4'd10, 4'd6, 4'd12, 4'd11, 4'd9, 4'd5, 4'd3, 4'd8},
    {4'd4, 4'd1, 4'd14, 4'd8, 4'd13, 4'd6, 4'd2, 4'd11, 4'd15, 4'd12, 4'd9, 4'd7, 4'd3, 4'd10, 4'd5, 4'd0},
    {4'd15, 4'd12, 4'd8, 4'd2, 4'd4, 4'd9, 4'd1, 4'd7, 4'd5, 4'd11, 4'd3, 4'd14, 4'd10, 4'd0, 4'd6, 4'd13}
    };

    logic [0:3] sbox2 [0:3][0:15] = '{
    {4'd15, 4'd1, 4'd8, 4'd14, 4'd6, 4'd11, 4'd3, 4'd4, 4'd9, 4'd7, 4'd2, 4'd13, 4'd12, 4'd0, 4'd5, 4'd10},
    {4'd3, 4'd13, 4'd4, 4'd7, 4'd15, 4'd2, 4'd8, 4'd14, 4'd12, 4'd0, 4'd1, 4'd10, 4'd6, 4'd9, 4'd11, 4'd5},
    {4'd0, 4'd14, 4'd7, 4'd11, 4'd10, 4'd4, 4'd13, 4'd1, 4'd5, 4'd8, 4'd12, 4'd6, 4'd9, 4'd3, 4'd2, 4'd15},
    {4'd13, 4'd8, 4'd10, 4'd1, 4'd3, 4'd15, 4'd4, 4'd2, 4'd11, 4'd6, 4'd7, 4'd12, 4'd0, 4'd5, 4'd14, 4'd9}
    };

    logic [0:3] sbox3 [0:3][0:15] = '{
    {4'd10, 4'd0, 4'd9, 4'd14, 4'd6, 4'd3, 4'd15, 4'd5, 4'd1, 4'd13, 4'd12, 4'd7, 4'd11, 4'd4, 4'd2, 4'd8},
    {4'd13, 4'd7, 4'd0, 4'd9, 4'd3, 4'd4, 4'd6, 4'd10, 4'd2, 4'd8, 4'd5, 4'd14, 4'd12, 4'd11, 4'd15, 4'd1},
    {4'd13, 4'd6, 4'd4, 4'd9, 4'd8, 4'd15, 4'd3, 4'd0, 4'd11, 4'd1, 4'd2, 4'd12, 4'd5, 4'd10, 4'd14, 4'd7},
    {4'd1, 4'd10, 4'd13, 4'd0, 4'd6, 4'd9, 4'd8, 4'd7, 4'd4, 4'd15, 4'd14, 4'd3, 4'd11, 4'd5, 4'd2, 4'd12}
    };

    logic [0:3] sbox4 [0:3][0:15] = '{
    {4'd7, 4'd13, 4'd14, 4'd3, 4'd0, 4'd6, 4'd9, 4'd10, 4'd1, 4'd2, 4'd8, 4'd5, 4'd11, 4'd12, 4'd4, 4'd15},
    {4'd13, 4'd8, 4'd11, 4'd5, 4'd6, 4'd15, 4'd0, 4'd3, 4'd4, 4'd7, 4'd2, 4'd12, 4'd1, 4'd10, 4'd14, 4'd9},
    {4'd10, 4'd6, 4'd9, 4'd0, 4'd12, 4'd11, 4'd7, 4'd13, 4'd15, 4'd1, 4'd3, 4'd14, 4'd5, 4'd2, 4'd8, 4'd4},
    {4'd3, 4'd15, 4'd0, 4'd6, 4'd10, 4'd1, 4'd13, 4'd8, 4'd9, 4'd4, 4'd5, 4'd11, 4'd12, 4'd7, 4'd2, 4'd14}
    };

    logic [0:3] sbox5 [0:3][0:15] = '{
    {4'd2, 4'd12, 4'd4, 4'd1, 4'd7, 4'd10, 4'd11, 4'd6, 4'd8, 4'd5, 4'd3, 4'd15, 4'd13, 4'd0, 4'd14, 4'd9},
    {4'd14, 4'd11, 4'd2, 4'd12, 4'd4, 4'd7, 4'd13, 4'd1, 4'd5, 4'd0, 4'd15, 4'd10, 4'd3, 4'd9, 4'd8, 4'd6},
    {4'd4, 4'd2, 4'd1, 4'd11, 4'd10, 4'd13, 4'd7, 4'd8, 4'd15, 4'd9, 4'd12, 4'd5, 4'd6, 4'd3, 4'd0, 4'd14},
    {4'd11, 4'd8, 4'd12, 4'd7, 4'd1, 4'd14, 4'd2, 4'd13, 4'd6, 4'd15, 4'd0, 4'd9, 4'd10, 4'd4, 4'd5, 4'd3}
    };

    logic [0:3] sbox6 [0:3][0:15] = '{
    {4'd12, 4'd1, 4'd10, 4'd15, 4'd9, 4'd2, 4'd6, 4'd8, 4'd0, 4'd13, 4'd3, 4'd4, 4'd14, 4'd7, 4'd5, 4'd11},
    {4'd10, 4'd15, 4'd4, 4'd2, 4'd7, 4'd12, 4'd9, 4'd5, 4'd6, 4'd1, 4'd13, 4'd14, 4'd0, 4'd11, 4'd3, 4'd8},
    {4'd9, 4'd14, 4'd15, 4'd5, 4'd2, 4'd8, 4'd12, 4'd3, 4'd7, 4'd0, 4'd4, 4'd10, 4'd1, 4'd13, 4'd11, 4'd6},
    {4'd4, 4'd3, 4'd2, 4'd12, 4'd9, 4'd5, 4'd15, 4'd10, 4'd11, 4'd14, 4'd1, 4'd7, 4'd6, 4'd0, 4'd8, 4'd13}
    };

    logic [0:3] sbox7 [0:3][0:15] = '{
    {4'd4, 4'd11, 4'd2, 4'd14, 4'd15, 4'd0, 4'd8, 4'd13, 4'd3, 4'd12, 4'd9, 4'd7, 4'd5, 4'd10, 4'd6, 4'd1},
    {4'd13, 4'd0, 4'd11, 4'd7, 4'd4, 4'd9, 4'd1, 4'd10, 4'd14, 4'd3, 4'd5, 4'd12, 4'd2, 4'd15, 4'd8, 4'd6},
    {4'd1, 4'd4, 4'd11, 4'd13, 4'd12, 4'd3, 4'd7, 4'd14, 4'd10, 4'd15, 4'd6, 4'd8, 4'd0, 4'd5, 4'd9, 4'd2},
    {4'd6, 4'd11, 4'd13, 4'd8, 4'd1, 4'd4, 4'd10, 4'd7, 4'd9, 4'd5, 4'd0, 4'd15, 4'd14, 4'd2, 4'd3, 4'd12}
    };

    logic [0:3] sbox8 [0:3][0:15] = '{
    {4'd13, 4'd2, 4'd8, 4'd4, 4'd6, 4'd15, 4'd11, 4'd1, 4'd10, 4'd9, 4'd3, 4'd14, 4'd5, 4'd0, 4'd12, 4'd7},
    {4'd1, 4'd15, 4'd13, 4'd8, 4'd10, 4'd3, 4'd7, 4'd4, 4'd12, 4'd5, 4'd6, 4'd11, 4'd0, 4'd14, 4'd9, 4'd2},
    {4'd7, 4'd11, 4'd4, 4'd1, 4'd9, 4'd12, 4'd14, 4'd2, 4'd0, 4'd6, 4'd10, 4'd13, 4'd15, 4'd3, 4'd5, 4'd8},
    {4'd2, 4'd1, 4'd14, 4'd7, 4'd4, 4'd10, 4'd8, 4'd13, 4'd15, 4'd12, 4'd9, 4'd0, 4'd3, 4'd5, 4'd6, 4'd11}
    };

// f_encryption
function logic [0:63] f_encryption( logic [0:63] data_ip, logic [0:47] subkey);

    logic [0:47] data_ep, data_km;
    logic [0:31] data_s, data_p;
    logic [0:31] data_r;

    assign data_r = data_ip[32:63];

    // step 1 : expansion permutation
    assign data_ep = {
    data_r[31], data_r[0],  data_r[1],  data_r[2],  data_r[3],  data_r[4],
    data_r[3],  data_r[4],  data_r[5],  data_r[6],  data_r[7],  data_r[8],
    data_r[7],  data_r[8],  data_r[9],  data_r[10], data_r[11], data_r[12],
    data_r[11], data_r[12], data_r[13], data_r[14], data_r[15], data_r[16],
    data_r[15], data_r[16], data_r[17], data_r[18], data_r[19], data_r[20],
    data_r[19], data_r[20], data_r[21], data_r[22], data_r[23], data_r[24],
    data_r[23], data_r[24], data_r[25], data_r[26], data_r[27], data_r[28],
    data_r[27], data_r[28], data_r[29], data_r[30], data_r[31], data_r[0]
    };

    // step 2 : key mixing
    assign data_km = data_ep ^ subkey;

    // step 3 : substitution

    assign data_s = {
    sbox1[{data_km[0], data_km[5]}][{data_km[1:4]}], sbox2[{data_km[6], data_km[11]}][{data_km[7:10]}], sbox3[{data_km[12], data_km[17]}][{data_km[13:16]}], sbox4[{data_km[18], data_km[23]}][{data_km[19:22]}],
    sbox5[{data_km[24], data_km[29]}][{data_km[25:28]}], sbox6[{data_km[30], data_km[35]}][{data_km[31:34]}], sbox7[{data_km[36], data_km[41]}][{data_km[37:40]}], sbox8[{data_km[42], data_km[47]}][{data_km[43:46]}]
    };

    // step 4 : permutation
    assign data_p = {
    data_s[15], data_s[6],  data_s[19], data_s[20], data_s[28], data_s[11], data_s[27], data_s[16],
    data_s[0],  data_s[14], data_s[22], data_s[25], data_s[4],  data_s[17], data_s[30], data_s[9],
    data_s[1],  data_s[7],  data_s[23], data_s[13], data_s[31], data_s[26], data_s[2],  data_s[8],
    data_s[18], data_s[12], data_s[29], data_s[5],  data_s[21], data_s[10], data_s[3],  data_s[24]
    };

    // step 5 : xor
    return {  data_ip[32:63], data_ip[0:31] ^ data_p  };

endfunction

// 16 rounds of encryption
    assign key_pc1 = {
    key[56], key[48], key[40], key[32], key[24], key[16], key[8],
    key[0],  key[57], key[49], key[41], key[33], key[25], key[17],
    key[9],  key[1],  key[58], key[50], key[42], key[34], key[26],
    key[18], key[10], key[2],  key[59], key[51], key[43], key[35],
    key[62], key[54], key[46], key[38], key[30], key[22], key[14],
    key[6],  key[61], key[53], key[45], key[37], key[29], key[21],
    key[13], key[5],  key[60], key[52], key[44], key[36], key[28],
    key[20], key[12], key[4],  key[27], key[19], key[11], key[3]
    };

    assign key_cd = {key_c, key_d};

    assign subkey = {
    key_cd[13], key_cd[16], key_cd[10], key_cd[23], key_cd[0],  key_cd[4],  key_cd[2],  key_cd[27],
    key_cd[14], key_cd[5],  key_cd[20], key_cd[9],  key_cd[22], key_cd[18], key_cd[11], key_cd[3],
    key_cd[25], key_cd[7],  key_cd[15], key_cd[6],  key_cd[26], key_cd[19], key_cd[12], key_cd[1],
    key_cd[40], key_cd[51], key_cd[30], key_cd[36], key_cd[46], key_cd[54], key_cd[29], key_cd[39],
    key_cd[50], key_cd[44], key_cd[32], key_cd[47], key_cd[43], key_cd[48], key_cd[38], key_cd[55],
    key_cd[33], key_cd[52], key_cd[45], key_cd[41], key_cd[49], key_cd[35], key_cd[28], key_cd[31]
    };

    always_ff @( posedge clk ) begin
        if ( data_vld == 1'b1 ) begin
            data_ip <=  {
                        data[57], data[49], data[41], data[33], data[25], data[17], data[9],  data[1],
                        data[59], data[51], data[43], data[35], data[27], data[19], data[11], data[3],
                        data[61], data[53], data[45], data[37], data[29], data[21], data[13], data[5],
                        data[63], data[55], data[47], data[39], data[31], data[23], data[15], data[7],
                        data[56], data[48], data[40], data[32], data[24], data[16], data[8],  data[0],
                        data[58], data[50], data[42], data[34], data[26], data[18], data[10], data[2],
                        data[60], data[52], data[44], data[36], data[28], data[20], data[12], data[4],
                        data[62], data[54], data[46], data[38], data[30], data[22], data[14], data[6]
                        };
        end else if ( data_vld_reg == 1'b1 ) begin
            data_ip <= f_encryption(data_ip, subkey);
        end
    end

    // DES_TYPE = 0 : 加密  DES_TYPE = 1 : 解密

    // 解密 -> 子密钥逆序：
    // 加密左移位数(round):   1  1  2  2  2  2  2  2  1  2  2  2  2  2  2  1
    // 加密左移位数(total):   1  2  4  6  8  10 12 14 15 17 19 21 23 25 27 28
    // 解密左移位数(total)：  28 27 25 23 21 19 17 15 14 12 10  8  6  4  2  1
    // round:                0  1  2  3  4  5  6  7  8  9  10 11 12 13 14 15

    always_ff @( posedge clk ) begin
        if ( data_vld == 1'b1 ) begin
            if(DES_TYPE == 1'b0) begin
                key_c <= {key_pc1[1:27], key_pc1[0]};
                key_d <= {key_pc1[29:55],key_pc1[28]};
            end else begin
                key_c <= {key_pc1[0:27]};
                key_d <= {key_pc1[28:55]};
            end
        end else if ( data_vld_reg == 1'b1 ) begin
            if ( round == 4'd0 || round == 4'd7 || round == 4'd14 ) begin
                if(DES_TYPE == 1'b0) begin 
                    key_c <= { key_c[1:27], key_c[0]};
                    key_d <= { key_d[1:27], key_d[0]};
                end else begin
                    key_c <= { key_c[27], key_c[0:26] };
                    key_d <= { key_d[27], key_d[0:26]};
                end
            end else begin
                if(DES_TYPE == 1'b0) begin 
                    key_c <= { key_c[2:27], key_c[0:1] };
                    key_d <= { key_d[2:27], key_d[0:1] };
                end else begin
                    key_c <= { key_c[26:27], key_c[0:25] };
                    key_d <= { key_d[26:27], key_d[0:25] };
                end
            end
        end
    end

// final permutation
    logic [0:63] data_f_rlt;
    assign data_f_rlt = { data_ip[32:63] , data_ip[0:31] };
    
    assign result = {
    data_f_rlt[39], data_f_rlt[7],  data_f_rlt[47], data_f_rlt[15], data_f_rlt[55], data_f_rlt[23], data_f_rlt[63], data_f_rlt[31],
    data_f_rlt[38], data_f_rlt[6],  data_f_rlt[46], data_f_rlt[14], data_f_rlt[54], data_f_rlt[22], data_f_rlt[62], data_f_rlt[30],
    data_f_rlt[37], data_f_rlt[5],  data_f_rlt[45], data_f_rlt[13], data_f_rlt[53], data_f_rlt[21], data_f_rlt[61], data_f_rlt[29],
    data_f_rlt[36], data_f_rlt[4],  data_f_rlt[44], data_f_rlt[12], data_f_rlt[52], data_f_rlt[20], data_f_rlt[60], data_f_rlt[28],
    data_f_rlt[35], data_f_rlt[3],  data_f_rlt[43], data_f_rlt[11], data_f_rlt[51], data_f_rlt[19], data_f_rlt[59], data_f_rlt[27],
    data_f_rlt[34], data_f_rlt[2],  data_f_rlt[42], data_f_rlt[10], data_f_rlt[50], data_f_rlt[18], data_f_rlt[58], data_f_rlt[26],
    data_f_rlt[33], data_f_rlt[1],  data_f_rlt[41], data_f_rlt[9],  data_f_rlt[49], data_f_rlt[17], data_f_rlt[57], data_f_rlt[25],
    data_f_rlt[32], data_f_rlt[0],  data_f_rlt[40], data_f_rlt[8],  data_f_rlt[48], data_f_rlt[16], data_f_rlt[56], data_f_rlt[24]
    };

    always_ff @( posedge clk ) begin
        if ( round == 4'b1111 ) begin
            result_vld <= 1'b1;
        end
        else begin
            result_vld <= 1'b0;
        end
    end

`else

    assign result = data;
    assign result_vld = data_vld;

`endif

endmodule