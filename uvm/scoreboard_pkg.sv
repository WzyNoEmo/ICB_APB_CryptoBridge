`include "../define.sv"
`timescale 1ns/1ps

package scoreboard_pkg;
    import sequence_pkg::*;
    import encrypt_verify_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "../define.sv"

    class my_model extends uvm_component;
        `uvm_component_utils(my_model)
        uvm_blocking_get_port #(icb_trans) icb_bgp;
        uvm_blocking_get_port #(apb_trans) apb_0_bgp;
        uvm_blocking_get_port #(apb_trans) apb_1_bgp;
        uvm_blocking_get_port #(apb_trans) apb_2_bgp;
        uvm_blocking_get_port #(apb_trans) apb_3_bgp;

        function new(string name = "my_model", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            icb_bgp = new("icb_bgp", this);
            apb_0_bgp = new("apb_0_bgp", this);
            apb_1_bgp = new("apb_1_bgp", this);
            apb_2_bgp = new("apb_2_bgp", this);
            apb_3_bgp = new("apb_3_bgp", this);
        endfunction //build_phase

        task run_phase(uvm_phase phase);
            icb_trans icb_tr;
            apb_trans apb_tr;

            logic [0:63]            ctrl_packet_decrypt;
            logic [0:63]            data_packet_decrypt;
            logic [31:0]            ctrl_packet_decrypt_32;
            logic [31:0]            data_packet_decrypt_32;
            logic [0:63]            resp_packet_encrypt;

            bit host2dev_pass = 0;
            bit dev2host_pass = 0;

            int pass_cnt = 0;
            int total_cnt = 0;

            super.run_phase(phase);
            
            while(1) begin
                icb_tr = new();
                apb_tr = new();

                // icb ctrl packet
                icb_bgp.get(icb_tr);
                   
                if(icb_tr.addr != 32'h2000_0010 || icb_tr.read == 1) continue;

                `ifdef DES
                    ctrl_packet_decrypt = des_decrypt(icb_tr.wdata,64'h1234_5678_9abc_def0);
                `else
                    ctrl_packet_decrypt = icb_tr.wdata;
                `endif
                ctrl_packet_decrypt_32 = ctrl_packet_decrypt[32:63];

                // icb data packet
                if(ctrl_packet_decrypt_32[1] == 1) begin      //apb write need wait for data packet
                    icb_bgp.get(icb_tr);
                    `ifdef DES
                        data_packet_decrypt = des_decrypt(icb_tr.wdata,64'h1234_5678_9abc_def0);
                    `else
                        data_packet_decrypt = icb_tr.wdata;
                    `endif
                    data_packet_decrypt_32 = data_packet_decrypt[32:63];
                end

                //apb packet
                case(ctrl_packet_decrypt_32[7:2])
                    6'b000001: begin
                        apb_0_bgp.get(apb_tr);
                    end
                    6'b000010: begin
                        apb_1_bgp.get(apb_tr);
                    end
                    6'b000100: begin
                        apb_2_bgp.get(apb_tr);
                    end
                    6'b001000: begin
                        apb_3_bgp.get(apb_tr);
                    end
                    default: begin
                        `uvm_info("my_model", "Invalid Channel ID , MODEL ERROR", UVM_LOW);
                    end
                endcase

                // golden model

                    // H2D VERIFY
                    if( ctrl_packet_decrypt_32[1] == 1 ) begin
                        if( apb_tr.addr == {8'b0,ctrl_packet_decrypt_32[31:8]} && apb_tr.wdata == {1'b0,data_packet_decrypt_32[31:1]} ) begin
                            $display("[Golden Model] Behavior Verify : APB Write Success !");
                            host2dev_pass = 1;
                        end else begin
                            $display("[Golden Model] Behavior Verify : APB Write Failed !");
                            host2dev_pass = 0;
                        end
                    end else begin
                        if( apb_tr.addr == {8'b0,ctrl_packet_decrypt_32[31:8]} ) begin
                            $display("[Golden Model] Behavior Verify : APB Read Success !");
                            host2dev_pass = 1;
                        end else begin
                            $display("[Golden Model] Behavior Verify : APB Read Failed !");
                            host2dev_pass = 0;
                        end
                    end

                    // D2H VERIFY
                    if(ctrl_packet_decrypt_32[1] == 1) begin
                        dev2host_pass = 1;
                    end else begin
                        // apb packet encrypt
                        `ifdef DES
                            resp_packet_encrypt = des_encrypt(apb_tr.rdata,64'h1234_5678_9abc_def0);
                        `else
                            resp_packet_encrypt = {32'b0,apb_tr.rdata};
                        `endif

                        icb_bgp.get(icb_tr);

                        if(icb_tr.addr == 32'h2000_0018 && icb_tr.read == 1 && icb_tr.rdata == resp_packet_encrypt) begin
                            $display("[Golden Model] Data Verify : Read Data Right !");
                            dev2host_pass = 1;
                        end else begin
                            $display("[Golden Model] Data Verify : Read Data Wrong !");
                            dev2host_pass = 0;
                        end
                    end

                // print scoreboard
                    total_cnt++;

                    if( host2dev_pass && dev2host_pass) begin
                        pass_cnt++;
                    end

                    $display("--------------------- [SCOREBOARD] --------------------");
                    $display("|     Pass / Total : %d / %d        |" , pass_cnt,total_cnt);
                    $display("|     Pass Rate : %f%%                         |", pass_cnt/total_cnt * 100);
                    $display("------------------------------------------------------");

                // reset
                    host2dev_pass = 0;
                    dev2host_pass = 0;
            end

        endtask //run_phase
    
    endclass //my_model

endpackage