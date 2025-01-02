//=====================================================================
// Description:
// compare apb_trans & icb_trans data package
// verify the consistency of ICB & APB behavior
// Designer : wangziyao1@sjtu.edu.cn
// Revision History
// V0 date:2024/11/11 Initial version, wangziyao1@sjtu.edu.cn
//=====================================================================

// `define DES

`timescale 1ns/1ps

package scoreboard_pkg;
    import objects_pkg::*;

    class scoreboard;

        mailbox #(icb_trans)    monitor_icb;
        mailbox #(apb_trans)    monitor_apb0;
        mailbox #(apb_trans)    monitor_apb1;
        mailbox #(apb_trans)    monitor_apb2;
        mailbox #(apb_trans)    monitor_apb3;

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

        // golden model: 
        // step 1. icb packet -> des result
        // step 2. verify des result & apb behavior

        logic [31:0]            ctrl_packet = icb_data.wdata;
        logic [31:0]            data_packet;
        logic [31:0]            ctrl_packet_encrypt;
        logic [31:0]            data_packet_encrypt;

        apb_trans              apb_dri;
        apb_dri = new();

        // STEP 1
            // encrypt ctrl packet
            ctrl_packet_encrypt = this.encrypt(ctrl_packet);

            // ctrl_packet_encrypt[1] -> apb write -> get data packet
            if(ctrl_packet_encrypt[1] == 1) begin      //apb write need wait for data packet
                while(this.monitor_icb.num() == 0) begin
                    #1;
                end;
                this.monitor_icb.get(icb_data);
                data_packet = icb_data.wdata;
            end

            // encrypt data packet
            data_packet_encrypt = this.encrypt(data_packet);

        // STEP 2
            // apb behavior
            case(ctrl_packet_encrypt[7:2])
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

            this.behavior_verify(apb_dri,ctrl_packet_encrypt,data_packet_encrypt);
            this.icb_data_valid = 0;
        endtask

        task automatic behavior_verify(
            apb_trans apb_dri,
            logic [31:0] ctrl_packet,
            logic [31:0] data_packet
        );
            $display("---------------------golden model---------------------");

            //$display("ctrl_packet = %h  data_packet = %h", ctrl_packet, data_packet);
            //$display("apb_dri.addr = %h  apb_dri.wdata = %h", apb_dri.addr, apb_dri.wdata);
            if( ctrl_packet[1] == 1 ) begin
                if( apb_dri.addr == {8'b0,ctrl_packet[31:8]} && apb_dri.wdata == {1'b0,data_packet[31:1]} ) begin
                    $display("|     APB Write Success !                             |");
                    this.pass_cnt++;
                    this.total_cnt++;
                end else begin
                    $display("|     APB Write Failed !                              |");
                    this.total_cnt++;
                end
            end else begin
                if( apb_dri.addr == {8'b0,ctrl_packet[31:8]} ) begin
                    $display("|     APB Read Success !                              |");
                    this.pass_cnt++;
                    this.total_cnt++;
                end else begin
                    $display("|     APB Read Failed !                               |");
                    this.total_cnt++;
                end
            end

            $display("|     Pass / Total : %d / %d        |" , this.pass_cnt,this.total_cnt);
            $display("|     Pass Rate : %f%%                         |", this.pass_cnt/this.total_cnt * 100);

            $display("------------------------------------------------------");
        
        endtask

        function logic [31:0] encrypt(
            logic [31:0] data
        );

            logic [31:0] result;
            
            // no encrypt
            return data;

            // des encrypt

        endfunction

    endclass //scoreboard

endpackage
