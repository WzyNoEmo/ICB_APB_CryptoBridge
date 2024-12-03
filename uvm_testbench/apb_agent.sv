//=====================================================================
// Description:
// This file realize the APB AGENT, includes data generator, driver and
// monitor.
// Designer : lynnxie@sjtu.edu.cn
// Revision History
// V0 date:2024/11/11 Initial version, lynnxie@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

package apb_agent_pkg;
    import objects_pkg::*;
    //产生读的数据
    // Generator: Generate data for driver to transfer
    class apb_generator;

        // BUILD
        //=============================================================
        mailbox #(apb_trans)    gen2drv;

        function new(
            mailbox #(apb_trans) gen2drv
        );
            this.gen2drv = gen2drv;
        endfunction //new()

        // FUNC : generate a data for transaction
        // TODO: The random data generation can be realized here
        //=============================================================
        task automatic data_gen(
            input  [31:0]  rdata = 32'h0000_0000
        );
            apb_trans   tran_data;
            tran_data = new();
            
            // set tran data according to input
            tran_data.rdata = rdata;

            // send the generated data to driver
            this.gen2drv.put(tran_data);
        endtask
    endclass //apb_generator

    // 对请求进行响应，驱动rsp通道
    // Driver: Converts the received packets to the format of the APB protocol
    class apb_driver;

        // BUILD
        //=============================================================
        mailbox #(apb_trans)    gen2drv; // receive the data from generator

        function new(
            mailbox #(apb_trans)    gen2drv
        );
            this.gen2drv = gen2drv;
        endfunction //new()
        
        // CONNECT
        //=============================================================
        local virtual apb_bus.slave active_channel;

        function void set_intf(
            virtual apb_bus.slave apb
        );
            this.active_channel = apb;

            // port initialization to avoid 'x' state in dut
            this.active_channel.slv_cb.prdata <= 32'b0;
            this.active_channel.slv_cb.pready <= 1'b0;
        endfunction

        // FUNC
        //=============================================================
        task automatic data_trans();
            apb_trans   get_trans;

            // get the input data and address from mailbox
            this.gen2drv.get(get_trans);

            // wait until apb access
            while(!(this.active_channel.psel && this.active_channel.penable)) begin
                @(this.active_channel.slv_cb);
            end

            this.active_channel.slv_cb.pready <= 1'b1;
            this.active_channel.slv_cb.prdata <= this.active_channel.pwrite? 32'b0 : get_trans.rdata;
            
            // end the transaction
            @(this.active_channel.slv_cb)
            this.active_channel.slv_cb.pready <= 1'b0;
        endtask //automatic
    endclass //apb_driver

    // **Optional** 
    // Monitor: Collect APB data and convert it to data package for
    //          scoreboard to compare result.
    class apb_monitor;

        // BUILD
        //=============================================================
        apb_trans monitor_trans;
        mailbox #(apb_trans)    apb_monitor_data;

        function new(
            mailbox #(apb_trans)    apb_monitor_data
        );
            this.apb_monitor_data = apb_monitor_data;
            this.monitor_trans = new();
        endfunction //new()

        // CONNECT
        //=============================================================
        local virtual apb_bus.monitor monitor_channel;

        function void set_intf(
            virtual apb_bus.monitor apb
        );
            this.monitor_channel = apb;
        endfunction

        // FUNC
        //=============================================================
        task automatic mst_monitor(string channel_id = "unknown", ref bit is_read);

            while(!(this.monitor_channel.psel && this.monitor_channel.penable)) begin
                @(this.monitor_channel.mnt_cb);
            end

            this.monitor_trans.write = this.monitor_channel.pwrite;
            this.monitor_trans.addr = this.monitor_channel.paddr;
            this.monitor_trans.wdata = this.monitor_channel.pwdata;

            is_read = ~this.monitor_trans.write;

            
            if(is_read) begin
                $display("APB Deocode : APB Master %s Read: Addr=%h",channel_id, this.monitor_trans.addr);
            end else begin
                $display("APB Deocode : APB Master %s Write: Addr=%h, WData=%h",channel_id, this.monitor_trans.addr, this.monitor_trans.wdata);
            end

            @(this.monitor_channel.mnt_cb);

        endtask

        task automatic slv_monitor(string channel_id = "unknown", ref bit is_read);

            while(!this.monitor_channel.pready) begin
                @(this.monitor_channel.mnt_cb);
            end

            this.monitor_trans.rdata = this.monitor_channel.prdata;

            if(is_read) begin
                $display("APB Slave %s Response : RData=%h",channel_id,this.monitor_trans.rdata);
            end 

            @(this.monitor_channel.mnt_cb);

        endtask

        task automatic monitor2scoreboard();
            this.apb_monitor_data.put(this.monitor_trans);
        endtask

    endclass //apb_monitor

    // Agent: The top class that connects generator, driver and monitor
    class apb_agent;
        
        // BUILD
        //=============================================================
        string                  channel_id;

        mailbox #(apb_trans)    gen2drv;
        mailbox #(apb_trans)    apb_monitor_data;

        apb_generator           apb_generator;
        apb_driver              apb_driver;
        apb_monitor             apb_monitor;

        bit                   is_read = 0;          // 记录一次 transaction 是读还是写，用于 monitor 打印

        function new(
            string channel_id = "unknown",
            mailbox #(apb_trans) monitor_apb
        );
            this.gen2drv = new(1);
            this.apb_monitor_data = monitor_apb;
            this.apb_generator = new(this.gen2drv);
            this.apb_driver = new(this.gen2drv);
            this.apb_monitor = new(this.apb_monitor_data);
            this.channel_id = channel_id;
        endfunction //new()

        // CONNECT
        //=============================================================
        function void set_intf(
            virtual apb_bus apb
        );   
            // connect to apb_driver
            this.apb_driver.set_intf(apb);
            this.apb_monitor.set_intf(apb);
        endfunction //automatic

        // FUN : single data tran
        //=============================================================
        task automatic single_channel_agent(
            input [31:0] rdata = 32'h0000_0000
        );

        while(1) begin

            fork
                begin
                    this.apb_generator.data_gen(rdata);
                    this.apb_driver.data_trans();
                    this.apb_monitor.monitor2scoreboard();
                end
                this.apb_monitor.mst_monitor(this.channel_id, this.is_read);     // 先监控 DUT 的 apb 主机行为
                this.apb_monitor.slv_monitor(this.channel_id, this.is_read);
            join

            // Avoid Infinite Loops
            #1;
        end

        endtask //automatic
    endclass //apb_agent
endpackage


