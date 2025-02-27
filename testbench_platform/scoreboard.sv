//=====================================================================
// Description:
// compare apb_trans & icb_trans data package
// verify the consistency of ICB & APB behavior
// Designer : wangziyao1@sjtu.edu.cn
// Revision History
// V0 date:2024/11/11 Initial version, wangziyao1@sjtu.edu.cn
//=====================================================================
`include "../define.sv"
`timescale 1ns/1ps

package scoreboard_pkg;
    import objects_pkg::*;
    import encrypt_verify_pkg::*;

    class scoreboard;

        mailbox #(icb_trans)    monitor_icb;
        mailbox #(apb_trans)    monitor_apb0;
        mailbox #(apb_trans)    monitor_apb1;
        mailbox #(apb_trans)    monitor_apb2;
        mailbox #(apb_trans)    monitor_apb3;

        bit             behavior_pass;
        bit             data_pass; 

        int             pass_cnt;
        int             total_cnt;

        bit             icb_data_valid;
        bit             apb_dri_valid;

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
            icb_data = new();

            while(1) begin
                // get monitor data
                if( this.monitor_icb.num() != 0 ) begin
                    this.monitor_icb.get(icb_data);
                    this.icb_data_valid = 1;
                end

                // start to verify
                if(this.icb_data_valid == 1 && icb_data.addr == 32'h2000_0010 && icb_data.read == 0) begin
                    this.golden_model(icb_data);
                end

                // Avoid Infinite Loops
                #1;
            end
        endtask      

        task automatic golden_model(
            icb_trans icb_data
        );

        // Golden Model model: 
        // step 1. icb packet -> des result
        // step 2. verify des result & apb behavior

        logic [0:63]            ctrl_packet_icb = icb_data.wdata;
        logic [0:63]            data_packet_icb;
        logic [0:63]            ctrl_packet_decrypt;
        logic [0:63]            data_packet_decrypt;
        logic [31:0]            ctrl_packet_decrypt_32;
        logic [31:0]            data_packet_decrypt_32;

        apb_trans              apb_dri;
        apb_dri = new();

        // STEP 1
            // decrypt ctrl packet
            `ifdef DES
                ctrl_packet_decrypt = des_decrypt(ctrl_packet_icb,64'h1234_5678_9abc_def0);
            `else
                ctrl_packet_decrypt = ctrl_packet_icb;
            `endif
            ctrl_packet_decrypt_32 = ctrl_packet_decrypt[32:63];
            //$display("ctrl_packet_icb = %h  ctrl_packet_decrypt = %h", ctrl_packet_icb, ctrl_packet_decrypt);

            // ctrl_packet_decrypt[1] -> apb write -> get data packet
            if(ctrl_packet_decrypt_32[1] == 1) begin      //apb write need wait for data packet
                while(this.monitor_icb.num() == 0) begin
                    #1;
                end;
                this.monitor_icb.get(icb_data);
                data_packet_icb = icb_data.wdata;
            end

            // decrypt data packet
            `ifdef DES
                data_packet_decrypt = des_decrypt(data_packet_icb,64'h1234_5678_9abc_def0);
            `else
                data_packet_decrypt = data_packet_icb;
            `endif
            data_packet_decrypt_32 = data_packet_decrypt[32:63];
            //$display("ctrl_packet_decrypt_32 = %h  data_packet_decrypt_32 = %h", ctrl_packet_decrypt_32, data_packet_decrypt_32);

        // STEP 2
            // apb behavior
            case(ctrl_packet_decrypt_32[7:2])
                6'b000001: begin
                    while(this.monitor_apb0.num() == 0) begin
                        #1;
                    end;
                    this.monitor_apb0.get(apb_dri);
                end
                6'b000010: begin
                    while(this.monitor_apb1.num() == 0) begin
                        #1;
                    end;
                    this.monitor_apb1.get(apb_dri);
                end
                6'b000100: begin
                    while(this.monitor_apb2.num() == 0) begin
                        #1;
                    end;
                    this.monitor_apb2.get(apb_dri);
                end
                6'b001000: begin
                    while(this.monitor_apb3.num() == 0) begin
                        #1;
                    end;
                    this.monitor_apb3.get(apb_dri);
                end
                default: begin
                    $display("Invalid Channel ID , SCOREBOARD ERROR");
                end
            endcase

            // verify

            this.behavior_verify(apb_dri,ctrl_packet_decrypt_32,data_packet_decrypt_32);
            this.data_verify(apb_dri,ctrl_packet_decrypt_32);
            this.score();

            //reset
            this.icb_data_valid = 0;
            this.behavior_pass = 0;
            this.data_pass = 0;

        endtask

        task automatic behavior_verify(
            apb_trans apb_dri,
            logic [31:0] ctrl_packet,
            logic [31:0] data_packet
        );

            // $display("ctrl_packet = %h  data_packet = %h", ctrl_packet, data_packet);
            // $display("apb_dri.rdata = %h ", apb_dri.rdata);
            if( ctrl_packet[1] == 1 ) begin
                if( apb_dri.addr == {8'b0,ctrl_packet[31:8]} && apb_dri.wdata == {1'b0,data_packet[31:1]} ) begin
                    $display("[Golden Model] Behavior Verify : APB Write Success !");
                    this.behavior_pass = 1;
                end else begin
                    $display("[Golden Model] Behavior Verify : APB Write Failed !");
                    this.behavior_pass = 0;
                end
            end else begin
                if( apb_dri.addr == {8'b0,ctrl_packet[31:8]} ) begin
                    $display("[Golden Model] Behavior Verify : APB Read Success !");
                    this.behavior_pass = 1;
                end else begin
                    $display("[Golden Model] Behavior Verify : APB Read Failed !");
                    this.behavior_pass = 0;
                end
            end
        
        endtask

        task automatic data_verify(
            apb_trans apb_dri,
            logic [31:0] ctrl_packet
        );

        logic [31:0] apb_rdata = apb_dri.rdata;
        icb_trans              icb_rdata;
        icb_rdata = new();

        if (ctrl_packet[1] == 1) begin
            this.data_pass = 1;
            return;
        end

        while(this.monitor_icb.num() == 0) begin
            #1;
        end;
        this.monitor_icb.get(icb_rdata);

        // start to verify
        if(icb_rdata.addr == 32'h2000_0018 && icb_rdata.read == 1 && icb_rdata.rdata == des_encrypt({32'b0,apb_rdata},64'h1234_5678_9abc_def0)) begin
            $display("[Golden Model] Data Verify : Read Data Right !");
            this.data_pass = 1;
        end else begin
            $display("[Golden Model] Data Verify : Read Data Wrong !");
            this.data_pass = 0;
        end

        endtask

        task automatic score();
            this.total_cnt++;

            if(this.behavior_pass == 1 && this.data_pass == 1) begin
                this.pass_cnt++;
            end
            $display("--------------------- [SCOREBOARD] --------------------");
            $display("|     Pass / Total : %d / %d        |" , this.pass_cnt,this.total_cnt);
            $display("|     Pass Rate : %f%%                         |", this.pass_cnt/this.total_cnt * 100);
            $display("------------------------------------------------------");
        endtask

    endclass //scoreboard

endpackage
