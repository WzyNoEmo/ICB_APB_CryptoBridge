//=====================================================================
// Description:
// This file build the environment for the whole test environment
// Designer : lynnxie@sjtu.edu.cn
// Revision History
// V0 date:2024/11/11 Initial version, lynnxie@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

// ATTENTION: mailbox only records handler, therefore, scoreboard and read/write should be parallel, 
//            or some address/data will be miss, especially for continuous read.

package env;
    
    import icb_agent_pkg::*;
    import apb_agent_pkg::*;
    import objects_pkg::*;
    import scoreboard_pkg::*;

    class env_ctrl;

        // FUNC : grab data
        //=============================================================
        // the new function is to build the class object's subordinates

        // first declare subordinates
        mailbox #(icb_trans)    monitor_icb;
        mailbox #(apb_trans)    monitor_apb0;
        mailbox #(apb_trans)    monitor_apb1;
        mailbox #(apb_trans)    monitor_apb2;
        mailbox #(apb_trans)    monitor_apb3;

        icb_agent       icb_agent;
        apb_agent       apb_agent0;
        apb_agent       apb_agent1;
        apb_agent       apb_agent2;
        apb_agent       apb_agent3;
        scoreboard      scoreboard;

        // new them
        function new();
            this.monitor_icb = new(1);
            this.monitor_apb0 = new(1);
            this.monitor_apb1 = new(1);
            this.monitor_apb2 = new(1);
            this.monitor_apb3 = new(1);

            this.icb_agent = new(this.monitor_icb);
            this.apb_agent0 = new("channel_0", this.monitor_apb0);
            this.apb_agent1 = new("channel_1", this.monitor_apb1);
            this.apb_agent2 = new("channel_2", this.monitor_apb2);
            this.apb_agent3 = new("channel_3", this.monitor_apb3);
            
            this.scoreboard = new(this.monitor_icb, this.monitor_apb0, this.monitor_apb1, this.monitor_apb2, this.monitor_apb3);
        endfunction //new()

        // CONNECT
        //=============================================================
        // the set_interface function is to connect the interface to itself
        // and then also connect to its subordinates
        // (only if used)
        function void set_intf(
            virtual icb_bus     icb,
            virtual apb_bus     apb0,
            virtual apb_bus     apb1,
            virtual apb_bus     apb2,
            virtual apb_bus     apb3
        );
            // connect to agent
            this.icb_agent.set_intf(icb);
            this.apb_agent0.set_intf(apb0);
            this.apb_agent1.set_intf(apb1);
            this.apb_agent2.set_intf(apb2);
            this.apb_agent3.set_intf(apb3);
        endfunction

        // RUN
        //=============================================================
        // manage your work here : 
        // (1) receive the command from the testbench
        // (2) call its subordinates to work
        task run(string state);
            localparam  CTRL_ADDR = 32'h2000_0000;
            localparam  STAT_ADDR = 32'h2000_0008;
            localparam  WDATA_ADDR = 32'h2000_0010;
            localparam  RDATA_ADDR = 32'h2000_0018;
            localparam  KEY_ADDR = 32'h2000_0020;

            fork
                case (state)
                    "ICB Write Test": begin
                        $display("=============================================================");
                        $display("[TB- ENV ] Start work : ICB Write !");

                        $display("[TB- ENV ] Write CTRL register.");
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0001, CTRL_ADDR);
                        
                        $display("[TB- ENV ] Write WDATA register for fifo depth.");
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0001, WDATA_ADDR);
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0002, WDATA_ADDR);
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0003, WDATA_ADDR);
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0004, WDATA_ADDR);
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0005, WDATA_ADDR);
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0006, WDATA_ADDR);
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0007, WDATA_ADDR);
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0008, WDATA_ADDR);

                        $display("[TB- ENV ] Write KEY register.");
                        this.icb_agent.single_tran(1'b0, 8'hcc, 64'h1234_5678_9abc_def0, KEY_ADDR);     // mask = 8'b1100_1100

                        //TODO: rand
                        $display("[TB- ENV ] Write random address.");
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0001, 32'h0000_0000);
                    end

                    "ICB RAW Test": begin
                        $display("=============================================================");
                        $display("[TB- ENV ] Start work : ICB Read !");

                        $display("[TB- ENV ] Write CTRL register.");
                        this.icb_agent.single_tran(1'b0, 8'h00, 64'h0000_0000_0000_0001, CTRL_ADDR);
                        $display("[TB- ENV ] Read CTRL register.");
                        this.icb_agent.single_tran(1'b1, 8'h00, 64'h0000_0000_0000_0000, CTRL_ADDR);

                        $display("[TB- ENV ] Write KEY register.");
                        this.icb_agent.single_tran(1'b0, 8'hcc, 64'h1234_5678_9abc_def0, KEY_ADDR);     // mask = 8'b1100_1100
                        $display("[TB- ENV ] Read KEY register.");
                        this.icb_agent.single_tran(1'b1, 8'h00, 64'h0000_0000_0000_0000, KEY_ADDR);
                    end

                    "APB Write":begin
                        $display("=============================================================");
                        $display("[TB- ENV ] Start work : APB Write !");
                        this.icb_agent.single_tran(1'b0, 8'h00, {32'b0, 24'h000004, 8'b00000110}, WDATA_ADDR);      // bus0 write addr 0000004
                        this.icb_agent.single_tran(1'b0, 8'h00, {32'b0, 31'h8, 1'b1}, WDATA_ADDR);                  // data 8 
                        //this.apb_agent0.single_tran(32'haabb_ccdd);   // apb write : no need for rdata
                    end

                    "APB Read":begin
                        $display("=============================================================");
                        $display("[TB- ENV ] Start work : APB Read !");
                        this.icb_agent.single_tran(1'b0, 8'h00, {24'h000004, 8'b00000100}, WDATA_ADDR);      // bus0 read addr 0000004              // data 8 
                        //this.apb_agent0.single_tran(32'haabb_ccdd);   // apb write : no need for rdata
                    end


                    "LOOPBACK Test":begin
                        $display("=============================================================");
                        this.icb_agent.single_tran(1'b0, 8'h00, {32'b0, 24'h000004, 6'b000001,1'b1,1'b0}, WDATA_ADDR);      // bus0 write addr 0000004
                        this.icb_agent.single_tran(1'b0, 8'h00, {32'b0, 31'h8, 1'b1}, WDATA_ADDR);                  // data 8 
                        //this.apb_agent0.single_tran(32'haabb_ccdd);   // apb write : no need for rdata
                        #200; 
                        this.icb_agent.single_tran(1'b0, 8'h00, {24'h000004, 8'b00000100}, WDATA_ADDR);      // bus0 read addr 0000004              // data 8 
                        //this.apb_agent0.single_tran(32'haabb_ccdd);
                        #200;   // 由于异步时钟设计打了两拍，数据写入后 empty 信号等两周期才会拉低 
                        this.icb_agent.single_tran(1'b1, 8'h00, 64'h0000_0000_0000_0000, RDATA_ADDR);      // bus0 write addr 0000004
                    end

                    "Time_Run": begin
                        $display("[TB- ENV ] start work : Time_Run !");
                        #100000;
                        $display("[TB- ENV ] =========================================================================================");
                        $display("[TB- ENV ]  _|_|_|_|_|   _|_|_|   _|      _|   _|_|_|_|         _|_|     _|    _|   _|_|_|_|_|  ");
                        $display("[TB- ENV ]      _|         _|     _|_|  _|_|   _|             _|    _|   _|    _|       _|      ");
                        $display("[TB- ENV ]      _|         _|     _|  _|  _|   _|_|_|         _|    _|   _|    _|       _|      ");
                        $display("[TB- ENV ]      _|         _|     _|      _|   _|             _|    _|   _|    _|       _|      ");
                        $display("[TB- ENV ]      _|       _|_|_|   _|      _|   _|_|_|_|         _|_|       _|_|         _|      ");
                        $display("[TB- ENV ] =========================================================================================");
                    end
                    default: begin
                    end
                endcase

                this.scoreboard.verify_top();       // 一直运行 !

                this.apb_agent0.single_channel_agent(32'haabb_ccdd);   // apb write : no need for rdata
                this.apb_agent1.single_channel_agent(32'haabb_ccdd);
                this.apb_agent2.single_channel_agent(32'haabb_ccdd);
                this.apb_agent3.single_channel_agent(32'haabb_ccdd);
            join
        endtask
    endclass //env_ctrl
endpackage