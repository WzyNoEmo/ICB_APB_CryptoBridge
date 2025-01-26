//=====================================================================
// Description:
// This file wraps the dut_top
// Designer : wangziyao1@sjtu.edu.cn
// Revision History
// V0 date:2024/11/13 Initial version, wangziyao1@sjtu.edu.cn
//=====================================================================
`include "../define.sv"
`timescale 1ns/1ps

module dut (
    icb_bus     icb,
    apb_bus     apb0,
    apb_bus     apb1,
    apb_bus     apb2,
    apb_bus     apb3
);
// dut top
    dut_top i_dut(
        // input bus
        .icb_bus(       icb.slave       ),

        // output bus
        .apb_bus_0(     apb0.master     ),
        .apb_bus_1(     apb1.master     ),
        .apb_bus_2(     apb2.master     ),
        .apb_bus_3(     apb3.master     )
    );
    
endmodule