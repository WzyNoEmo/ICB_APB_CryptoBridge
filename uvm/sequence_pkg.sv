//=====================================================================
// Description:
// This file includes objects needed for the whole test environment
// Designer : wangziyao1@sjtu.edu.cn
// Revision History
// V0 date:2024/11/07 Initial version, wangziyao1@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

package sequence_pkg;

    import uvm_pkg::*;
    import encrypt_verify_pkg::*;
    `include "uvm_macros.svh"
    `include "../define.sv"

    parameter  CTRL_ADDR = 32'h2000_0000;
    parameter  STAT_ADDR = 32'h2000_0008;
    parameter  WDATA_ADDR = 32'h2000_0010;
    parameter  RDATA_ADDR = 32'h2000_0018;
    parameter  KEY_ADDR = 32'h2000_0020;

    class icb_trans extends uvm_sequence_item;

        `uvm_object_utils(icb_trans)
        rand logic          read; // 0: write; 1: read
        rand logic [7:0]    mask;
        rand logic [63:0]   wdata;
        rand logic [63:0]   rdata;
        rand logic [31:0]   addr;

    endclass // icb_trans

    class apb_trans extends uvm_sequence_item;
        `uvm_object_utils(apb_trans)
        rand logic          write; // 0: read; 1: write
        rand logic [31:0]   addr;
        rand logic [31:0]   wdata;
        rand logic [31:0]   rdata;
    endclass // apb_trans

    class random_stimulus extends uvm_sequence_item;
        `uvm_object_utils(random_stimulus)
        rand logic [23:0]   addr;
        rand logic [30:0]   wdata;
        rand logic          write;
        rand logic [5:0]    channel_sel;
        constraint constrs {
            channel_sel inside {6'b000001, 6'b000010, 6'b000100, 6'b001000};
        }
    endclass

    class apb_read_write_sequence extends uvm_sequence #(icb_trans);

        `uvm_object_utils(apb_read_write_sequence)
        

        function new(string name = "apb_read_write_sequence");
            super.new(name);
        endfunction

        virtual task body();

            bit request_type;
            logic [63:0] ctrl_packet_raw;
            logic [63:0] data_packet_raw;
            logic [63:0] ctrl_packet_true; 
            logic [63:0] data_packet_true;

            random_stimulus input_stimulus;
            icb_trans tx;

            tx = new();
            input_stimulus = new();

            #500;

            start_item(tx);
                tx.read = 1'b0;
                tx.mask = 8'h00;
                tx.wdata = 64'h1234_5678_9abc_def0;
                tx.addr = KEY_ADDR;
            finish_item(tx);

            repeat (100) begin // Repeat the random test for 10 times

                #($urandom_range(20, 100) * 10); // Random delay between 200ns to 1000ns        

                // Randomize the test data
                void'(input_stimulus.randomize());
                request_type = input_stimulus.write;

                ctrl_packet_raw = {32'b0, input_stimulus.addr, input_stimulus.channel_sel, input_stimulus.write, 1'b0};
                data_packet_raw = {32'b0, input_stimulus.wdata, 1'b1};

                `ifdef DES
                    ctrl_packet_true = des_encrypt(ctrl_packet_raw,64'h1234_5678_9abc_def0);
                    data_packet_true = des_encrypt(data_packet_raw,64'h1234_5678_9abc_def0);
                `else
                    ctrl_packet_true = ctrl_packet_raw;
                    data_packet_true = data_packet_raw;
                `endif

                // Drive ICB master with randomized data
                if (request_type) begin
                    $display("=============================== Random Write ==============================");
                    start_item(tx);
                        tx.read = 1'b0;
                        tx.mask = 8'h00;
                        tx.wdata = ctrl_packet_true;
                        tx.addr = WDATA_ADDR;
                    finish_item(tx);
                    #500;   // Attention : decrypt need 16 cycle !!!!!! SO U CANT SENT DATA BAG IMMEDIATELY
                    start_item(tx);
                        tx.read = 1'b0;
                        tx.mask = 8'h00;
                        tx.wdata = data_packet_true;
                        tx.addr = WDATA_ADDR;
                    finish_item(tx);
                    #500;
                end else begin
                    $display("=============================== Random Read ===============================");
                    start_item(tx);
                        tx.read = 1'b0;
                        tx.mask = 8'h00;
                        tx.wdata = ctrl_packet_true;
                        tx.addr = WDATA_ADDR;
                    finish_item(tx);
                    #500;
                    start_item(tx);
                        tx.read = 1'b1;
                        tx.mask = 8'h00;
                        tx.wdata = 64'h0000_0000_0000_0000;
                        tx.addr = RDATA_ADDR;
                    finish_item(tx);
                    #500;
                end
            end

            #500;       // Wait for the last transaction to complete

        endtask
    endclass

    class icb_raw_sequence extends uvm_sequence #(apb_trans);
        
        `uvm_object_utils(icb_raw_sequence)
        

        function new(string name = "icb_raw_sequence");
            super.new(name);
        endfunction

        virtual task body();
            icb_trans tx;

            tx = new();

            #500;

            // all reg raw
            start_item(tx);
                tx.read = 1'b0;
                tx.mask = 8'h00;
                tx.wdata = 64'h0000_0000_0000_0001;
                tx.addr = CTRL_ADDR;
            finish_item(tx);

            start_item(tx);
                tx.read = 1'b1;
                tx.mask = 8'h00;
                tx.wdata = 64'h0000_0000_0000_0000;
                tx.addr = CTRL_ADDR;
            finish_item(tx);

            start_item(tx);
                tx.read = 1'b0;
                tx.mask = 8'hcc;
                tx.wdata = 64'h1234_5678_9abc_def0;
                tx.addr = KEY_ADDR;
            finish_item(tx);

            start_item(tx);
                tx.read = 1'b1;
                tx.mask = 8'h00;
                tx.wdata = 64'h0000_0000_0000_0000;
                tx.addr = KEY_ADDR;
            finish_item(tx);

            start_item(tx);
                tx.read = 1'b0;
                tx.mask = 8'h00;
                tx.wdata = 64'h2510_bda9_1976_44b4;
                tx.addr = WDATA_ADDR;
            finish_item(tx);

            start_item(tx);
                tx.read = 1'b1;
                tx.mask = 8'h00;
                tx.wdata = 64'h0000_0000_0000_0000;
                tx.addr = WDATA_ADDR;
            finish_item(tx);

            start_item(tx);
                tx.read = 1'b0;
                tx.mask = 8'hcc;
                tx.wdata = 64'h1234_5678_9abc_def0;
                tx.addr = RDATA_ADDR;
            finish_item(tx);

            start_item(tx);
                tx.read = 1'b1;
                tx.mask = 8'h00;
                tx.wdata = 64'h0000_0000_0000_0000;
                tx.addr = RDATA_ADDR;
            finish_item(tx);

            start_item(tx);
                tx.read = 1'b0;
                tx.mask = 8'hcc;
                tx.wdata = 64'h1234_5678_9abc_def0;
                tx.addr = STAT_ADDR;
            finish_item(tx);

            start_item(tx);
                tx.read = 1'b1;
                tx.mask = 8'h00;
                tx.wdata = 64'h0000_0000_0000_0000;
                tx.addr = STAT_ADDR;
            finish_item(tx);

            // invalid raw
            start_item(tx);
                tx.read = 1'b0;
                tx.mask = 8'h00;
                tx.wdata = 64'h0000_0000_0000_0001;
                tx.addr = 32'hFFFF_FFFF;
            finish_item(tx);

            start_item(tx);
                tx.read = 1'b1;
                tx.mask = 8'h00;
                tx.wdata = 64'h0000_0000_0000_0000;
                tx.addr = 32'hFFFF_FFFF;
            finish_item(tx);

            // shutdown
            start_item(tx);
                tx.read = 1'b0;
                tx.mask = 8'h00;
                tx.wdata = 64'h0000_0000_0000_0000;
                tx.addr = CTRL_ADDR;
            finish_item(tx);
            
        endtask
    endclass

    class apb_read_sequence extends uvm_sequence #(apb_trans);
        apb_trans tx;
        `uvm_object_utils(apb_read_sequence)
        
        function new(string name= "apb_read_sequence");
            super.new(name);
        endfunction

        virtual task body();
            while(1) begin
                `uvm_do(tx)
            end
        endtask
    endclass
endpackage