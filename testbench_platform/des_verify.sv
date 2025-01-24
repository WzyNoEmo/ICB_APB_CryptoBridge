package encrypt_verify_pkg;
    //-------------------------------------------des------------------------------------------------
    function logic [0:3] sbox (input [0:5] data, input [0:2] sbox_num);
        logic [0:1] row;
        logic [0:3] col;
        logic [0:3] sbox_output [0:7][0:3][0:15];

        row = {data[0], data[5]};
        col = data[1:4];

        sbox_output[0] ='{
                            {4'd14, 4'd4, 4'd13, 4'd1, 4'd2, 4'd15, 4'd11, 4'd8, 4'd3, 4'd10, 4'd6, 4'd12, 4'd5, 4'd9, 4'd0, 4'd7},
                            {4'd0, 4'd15, 4'd7, 4'd4, 4'd14, 4'd2, 4'd13, 4'd1, 4'd10, 4'd6, 4'd12, 4'd11, 4'd9, 4'd5, 4'd3, 4'd8},
                            {4'd4, 4'd1, 4'd14, 4'd8, 4'd13, 4'd6, 4'd2, 4'd11, 4'd15, 4'd12, 4'd9, 4'd7, 4'd3, 4'd10, 4'd5, 4'd0},
                            {4'd15, 4'd12, 4'd8, 4'd2, 4'd4, 4'd9, 4'd1, 4'd7, 4'd5, 4'd11, 4'd3, 4'd14, 4'd10, 4'd0, 4'd6, 4'd13}
                        };

        sbox_output[1] ='{
                            {4'd15, 4'd1, 4'd8, 4'd14, 4'd6, 4'd11, 4'd3, 4'd4, 4'd9, 4'd7, 4'd2, 4'd13, 4'd12, 4'd0, 4'd5, 4'd10},
                            {4'd3, 4'd13, 4'd4, 4'd7, 4'd15, 4'd2, 4'd8, 4'd14, 4'd12, 4'd0, 4'd1, 4'd10, 4'd6, 4'd9, 4'd11, 4'd5},
                            {4'd0, 4'd14, 4'd7, 4'd11, 4'd10, 4'd4, 4'd13, 4'd1, 4'd5, 4'd8, 4'd12, 4'd6, 4'd9, 4'd3, 4'd2, 4'd15},
                            {4'd13, 4'd8, 4'd10, 4'd1, 4'd3, 4'd15, 4'd4, 4'd2, 4'd11, 4'd6, 4'd7, 4'd12, 4'd0, 4'd5, 4'd14, 4'd9}
                        };

        sbox_output[2] ='{
                            {4'd10, 4'd0, 4'd9, 4'd14, 4'd6, 4'd3, 4'd15, 4'd5, 4'd1, 4'd13, 4'd12, 4'd7, 4'd11, 4'd4, 4'd2, 4'd8},
                            {4'd13, 4'd7, 4'd0, 4'd9, 4'd3, 4'd4, 4'd6, 4'd10, 4'd2, 4'd8, 4'd5, 4'd14, 4'd12, 4'd11, 4'd15, 4'd1},
                            {4'd13, 4'd6, 4'd4, 4'd9, 4'd8, 4'd15, 4'd3, 4'd0, 4'd11, 4'd1, 4'd2, 4'd12, 4'd5, 4'd10, 4'd14, 4'd7},
                            {4'd1, 4'd10, 4'd13, 4'd0, 4'd6, 4'd9, 4'd8, 4'd7, 4'd4, 4'd15, 4'd14, 4'd3, 4'd11, 4'd5, 4'd2, 4'd12}
                        };
        
        sbox_output[3] ='{
                            {4'd7, 4'd13, 4'd14, 4'd3, 4'd0, 4'd6, 4'd9, 4'd10, 4'd1, 4'd2, 4'd8, 4'd5, 4'd11, 4'd12, 4'd4, 4'd15},
                            {4'd13, 4'd8, 4'd11, 4'd5, 4'd6, 4'd15, 4'd0, 4'd3, 4'd4, 4'd7, 4'd2, 4'd12, 4'd1, 4'd10, 4'd14, 4'd9},
                            {4'd10, 4'd6, 4'd9, 4'd0, 4'd12, 4'd11, 4'd7, 4'd13, 4'd15, 4'd1, 4'd3, 4'd14, 4'd5, 4'd2, 4'd8, 4'd4},
                            {4'd3, 4'd15, 4'd0, 4'd6, 4'd10, 4'd1, 4'd13, 4'd8, 4'd9, 4'd4, 4'd5, 4'd11, 4'd12, 4'd7, 4'd2, 4'd14}
                        };

        sbox_output[4] ='{
                            {4'd2, 4'd12, 4'd4, 4'd1, 4'd7, 4'd10, 4'd11, 4'd6, 4'd8, 4'd5, 4'd3, 4'd15, 4'd13, 4'd0, 4'd14, 4'd9},
                            {4'd14, 4'd11, 4'd2, 4'd12, 4'd4, 4'd7, 4'd13, 4'd1, 4'd5, 4'd0, 4'd15, 4'd10, 4'd3, 4'd9, 4'd8, 4'd6},
                            {4'd4, 4'd2, 4'd1, 4'd11, 4'd10, 4'd13, 4'd7, 4'd8, 4'd15, 4'd9, 4'd12, 4'd5, 4'd6, 4'd3, 4'd0, 4'd14},
                            {4'd11, 4'd8, 4'd12, 4'd7, 4'd1, 4'd14, 4'd2, 4'd13, 4'd6, 4'd15, 4'd0, 4'd9, 4'd10, 4'd4, 4'd5, 4'd3}
                        };

        sbox_output[5] ='{
                            {4'd12, 4'd1, 4'd10, 4'd15, 4'd9, 4'd2, 4'd6, 4'd8, 4'd0, 4'd13, 4'd3, 4'd4, 4'd14, 4'd7, 4'd5, 4'd11},
                            {4'd10, 4'd15, 4'd4, 4'd2, 4'd7, 4'd12, 4'd9, 4'd5, 4'd6, 4'd1, 4'd13, 4'd14, 4'd0, 4'd11, 4'd3, 4'd8},
                            {4'd9, 4'd14, 4'd15, 4'd5, 4'd2, 4'd8, 4'd12, 4'd3, 4'd7, 4'd0, 4'd4, 4'd10, 4'd1, 4'd13, 4'd11, 4'd6},
                            {4'd4, 4'd3, 4'd2, 4'd12, 4'd9, 4'd5, 4'd15, 4'd10, 4'd11, 4'd14, 4'd1, 4'd7, 4'd6, 4'd0, 4'd8, 4'd13}
                        };
        
        sbox_output[6] ='{
                            {4'd4, 4'd11, 4'd2, 4'd14, 4'd15, 4'd0, 4'd8, 4'd13, 4'd3, 4'd12, 4'd9, 4'd7, 4'd5, 4'd10, 4'd6, 4'd1},
                            {4'd13, 4'd0, 4'd11, 4'd7, 4'd4, 4'd9, 4'd1, 4'd10, 4'd14, 4'd3, 4'd5, 4'd12, 4'd2, 4'd15, 4'd8, 4'd6},
                            {4'd1, 4'd4, 4'd11, 4'd13, 4'd12, 4'd3, 4'd7, 4'd14, 4'd10, 4'd15, 4'd6, 4'd8, 4'd0, 4'd5, 4'd9, 4'd2},
                            {4'd6, 4'd11, 4'd13, 4'd8, 4'd1, 4'd4, 4'd10, 4'd7, 4'd9, 4'd5, 4'd0, 4'd15, 4'd14, 4'd2, 4'd3, 4'd12}
                        };
        
        sbox_output[7] ='{
                            {4'd13, 4'd2, 4'd8, 4'd4, 4'd6, 4'd15, 4'd11, 4'd1, 4'd10, 4'd9, 4'd3, 4'd14, 4'd5, 4'd0, 4'd12, 4'd7},
                            {4'd1, 4'd15, 4'd13, 4'd8, 4'd10, 4'd3, 4'd7, 4'd4, 4'd12, 4'd5, 4'd6, 4'd11, 4'd0, 4'd14, 4'd9, 4'd2},
                            {4'd7, 4'd11, 4'd4, 4'd1, 4'd9, 4'd12, 4'd14, 4'd2, 4'd0, 4'd6, 4'd10, 4'd13, 4'd15, 4'd3, 4'd5, 4'd8},
                            {4'd2, 4'd1, 4'd14, 4'd7, 4'd4, 4'd10, 4'd8, 4'd13, 4'd15, 4'd12, 4'd9, 4'd0, 4'd3, 4'd5, 4'd6, 4'd11}
                        };

        return sbox_output[sbox_num][row][col];
    endfunction

    function logic [0:63] initial_permutation (input [0:63] data);
        return  {
                data[57], data[49], data[41], data[33], data[25], data[17], data[9],  data[1],
                data[59], data[51], data[43], data[35], data[27], data[19], data[11], data[3],
                data[61], data[53], data[45], data[37], data[29], data[21], data[13], data[5],
                data[63], data[55], data[47], data[39], data[31], data[23], data[15], data[7],
                data[56], data[48], data[40], data[32], data[24], data[16], data[8],  data[0],
                data[58], data[50], data[42], data[34], data[26], data[18], data[10], data[2],
                data[60], data[52], data[44], data[36], data[28], data[20], data[12], data[4],
                data[62], data[54], data[46], data[38], data[30], data[22], data[14], data[6]
                };
    endfunction

    function logic [0:55] permuted_choice_1(input [0:63] key);
        return {
                key[56], key[48], key[40], key[32], key[24], key[16], key[8],
                key[0], key[57], key[49], key[41], key[33], key[25], key[17],
                key[9], key[1], key[58], key[50], key[42], key[34], key[26],
                key[18], key[10], key[2], key[59], key[51], key[43], key[35],
                key[62], key[54], key[46], key[38], key[30], key[22], key[14],
                key[6], key[61], key[53], key[45], key[37], key[29], key[21],
                key[13], key[5], key[60], key[52], key[44], key[36], key[28],
                key[20], key[12], key[4], key[27], key[19], key[11], key[3]
                };
    endfunction

    function logic [0:47] permuted_choice_2(input [0:55] CD);
        return {
                CD[13], CD[16], CD[10], CD[23], CD[0], CD[4],
                CD[2], CD[27], CD[14], CD[5], CD[20], CD[9],
                CD[22], CD[18], CD[11], CD[3], CD[25], CD[7],
                CD[15], CD[6], CD[26], CD[19], CD[12], CD[1],
                CD[40], CD[51], CD[30], CD[36], CD[46], CD[54],
                CD[29], CD[39], CD[50], CD[44], CD[32], CD[47],
                CD[43], CD[48], CD[38], CD[55], CD[33], CD[52],
                CD[45], CD[41], CD[49], CD[35], CD[28], CD[31]
                };
    endfunction

    function logic [0:63] final_permutation(input [0:63] data);
        return {
                data[39], data[7], data[47], data[15], data[55], data[23], data[63], data[31],
                data[38], data[6], data[46], data[14], data[54], data[22], data[62], data[30],
                data[37], data[5], data[45], data[13], data[53], data[21], data[61], data[29],
                data[36], data[4], data[44], data[12], data[52], data[20], data[60], data[28],
                data[35], data[3], data[43], data[11], data[51], data[19], data[59], data[27],
                data[34], data[2], data[42], data[10], data[50], data[18], data[58], data[26],
                data[33], data[1], data[41], data[9], data[49], data[17], data[57], data[25],
                data[32], data[0], data[40], data[8], data[48], data[16], data[56], data[24]
                };
    endfunction

    function logic [0:31] permutation(input [0:31] data);
        return {
                data[15], data[6], data[19], data[20], data[28], data[11], data[27], data[16],
                data[0], data[14], data[22], data[25], data[4], data[17], data[30], data[9],
                data[1], data[7], data[23], data[13], data[31], data[26], data[2], data[8],
                data[18], data[12], data[29], data[5], data[21], data[10], data[3], data[24]
                };
    endfunction

    function logic [0:31] f(input [0:31] R, input [0:47] subkey);
        logic [0:47] expanded_R;
        logic [0:31] sbox_output;

        expanded_R = {
                R[31], R[0], R[1], R[2], R[3], R[4],
                R[3], R[4], R[5], R[6], R[7], R[8],
                R[7], R[8], R[9], R[10], R[11], R[12],
                R[11], R[12], R[13], R[14], R[15], R[16],
                R[15], R[16], R[17], R[18], R[19], R[20],
                R[19], R[20], R[21], R[22], R[23], R[24],
                R[23], R[24], R[25], R[26], R[27], R[28],
                R[27], R[28], R[29], R[30], R[31], R[0]
                };

        expanded_R = expanded_R ^ subkey;
        
        sbox_output = {
                sbox(expanded_R[0:5], 0), sbox(expanded_R[6:11], 1), sbox(expanded_R[12:17], 2), sbox(expanded_R[18:23], 3),
                sbox(expanded_R[24:29], 4), sbox(expanded_R[30:35], 5), sbox(expanded_R[36:41], 6), sbox(expanded_R[42:47], 7)
                };

        return permutation(sbox_output);
    endfunction

    function logic [0:63] des_encrypt(input [0:63] data, input [0:63] key);
        logic [0:47] subkey[16];
        logic [0:31] L, R, temp;
        logic [0:27] C, D;
        logic [0:55] CD;
        static int shifts[16] = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};

        CD = permuted_choice_1(key);
        C = CD[0:27];
        D = CD[28:55];
        
        data = initial_permutation(data);
        

        for (int i = 0; i < 16; i++) begin
            C = (C << shifts[i]) | (C >> (28 - shifts[i]));
            D = (D << shifts[i]) | (D >> (28 - shifts[i]));
            subkey[i] = permuted_choice_2({C, D});

        end

        L = data[0:31];
        R = data[32:63];

        for (int i = 0; i < 16; i++) begin
            temp = R;
            R = L ^ f(R, subkey[i]);
            L = temp;
        end

        data = {R, L};
        return final_permutation(data);
    endfunction

    function logic [0:63] des_decrypt(input [0:63] data, input [0:63] key);
        logic [0:47] subkey[16];
        logic [0:31] L, R, temp;
        logic [0:27] C, D;
        logic [0:55] CD;
        static int shifts[16] = {1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 1};

        CD = permuted_choice_1(key);
        C = CD[0:27];
        D = CD[28:55];
        
        data = initial_permutation(data);
        

        for (int i = 0; i < 16; i++) begin
            C = (C << shifts[i]) | (C >> (28 - shifts[i]));
            D = (D << shifts[i]) | (D >> (28 - shifts[i]));
            subkey[i] = permuted_choice_2({C, D});

        end

        L = data[0:31];
        R = data[32:63];

        for (int i = 0; i < 16; i++) begin
            temp = R;
            R = L ^ f(R, subkey[15 - i]);
            L = temp;
        end

        data = {R, L};
        return final_permutation(data);
    endfunction

endpackage
