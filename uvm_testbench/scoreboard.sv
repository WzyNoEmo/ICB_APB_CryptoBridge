//=====================================================================
// Description:
// compare apb_trans & icb_trans data package
// verify the consistency of ICB & APB behavior
// Designer : wangziyao1@sjtu.edu.cn
// Revision History
// V0 date:2024/11/11 Initial version, wangziyao1@sjtu.edu.cn
//=====================================================================

// "compare" : receive monitor data & verify the behavior
// "golden_model" : verify the data & algorithm
// "scoreboard" : top module

`timescale 1ns/1ps

package scoreboard_pkg;
    import objects_pkg::*;

    class compare;
        
    endclass //compare

    class golden_model;

    endclass //golden_model

    class scoreboard;

    endclass //scoreboard

endpackage
