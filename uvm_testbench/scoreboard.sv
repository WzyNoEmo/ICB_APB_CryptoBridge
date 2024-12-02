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

        mailbox #(icb_trans)    monitor_icb;
        mailbox #(apb_trans)    monitor_apb0;
        mailbox #(apb_trans)    monitor_apb1;
        mailbox #(apb_trans)    monitor_apb2;
        mailbox #(apb_trans)    monitor_apb3;

        function new(
            mailbox #(icb_trans)    monitor_icb,
            mailbox #(apb_trans)    monitor_apb0,
            mailbox #(apb_trans)    monitor_apb1,
            mailbox #(apb_trans)    monitor_apb2,
            mailbox #(apb_trans)    monitor_apb3
        );
            this.monitor_icb = monitor_icb;
            this.monitor_apb0 = monitor_apb0;
            this.monitor_apb1 = monitor_apb1;
            this.monitor_apb2 = monitor_apb2;
            this.monitor_apb3 = monitor_apb3;
        endfunction //new()

        task automatic verify_top();

            icb_trans              icb_data;
            apb_trans              apb0_data;
            apb_trans              apb1_data;
            apb_trans              apb2_data;
            apb_trans              apb3_data;

            icb_data = new();
            apb0_data = new();
            apb1_data = new();
            apb2_data = new();
            apb3_data = new();

            // get monitor data
            this.monitor_icb.get(icb_data);
            //this.monitor_apb0.get(this.apb0_data);
            //this.monitor_apb1.get(this.apb1_data);
            //this.monitor_apb2.get(this.apb2_data);
            //this.monitor_apb3.get(this.apb3_data);

            // tmp verify
            //$display("( %h , %h , %h , %h , %h )", icb_data.read, icb_data.mask, icb_data.wdata, icb_data.rdata, icb_data.addr);
            
        endtask
    endclass //scoreboard

endpackage
