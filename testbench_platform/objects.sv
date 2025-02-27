//=====================================================================
// Description:
// This file includes objects needed for the whole test environment
// Designer : wangziyao1@sjtu.edu.cn
// Revision History
// V0 date:2024/11/07 Initial version, wangziyao1@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

package objects_pkg;
    class icb_trans;
        rand logic          read; // 0: write; 1: read
        rand logic [7:0]    mask;
        rand logic [63:0]   wdata;
        rand logic [63:0]   rdata;
        rand logic [31:0]   addr;
    endclass // icb_trans

    class apb_trans;
        rand logic          write; // 0: read; 1: write
        rand logic [31:0]   addr;
        rand logic [31:0]   wdata;
        rand logic [31:0]   rdata;
    endclass // apb_trans

    class random_stimulus;
        rand logic [23:0]   addr;
        rand logic [30:0]   wdata;
        rand logic          write;
        rand logic [5:0]    channel_sel;
        constraint constrs {
            channel_sel inside {6'b000001, 6'b000010, 6'b000100, 6'b001000};
        }
    endclass
endpackage