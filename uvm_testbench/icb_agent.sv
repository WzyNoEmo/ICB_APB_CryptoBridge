//=====================================================================
// Description:
// This file realize the ICB AGENT, includes data generator, driver and
// monitor.
// Designer : lynnxie@sjtu.edu.cn
// Revision History
// V0 date:2024/11/07 Initial version, lynnxie@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

package icb_agent_pkg;
    import objects_pkg::*;
    
    // Generator: Generate data for driver to transfer
    class icb_generator;

        // BUILD
        //=============================================================
        mailbox #(icb_trans)    gen2drv; // generator need a mailbox to transfer data to driver

        function new(
            mailbox #(icb_trans) gen2drv
        );
            this.gen2drv = gen2drv; // the mailbox will be create in agent
        endfunction //new()

        // FUNC : generate a data for transaction
        // TODO: The random data generation can be realized here
        //=============================================================
        task automatic data_gen(
            input           read = 1'b1,
            input [7:0]     mask = 8'h00,
            input [63:0]    data = 64'h0000_0000_0000_0000,
            input [31:0]    addr = 32'h2000_0000
        );
            icb_trans   tran_data;
            tran_data = new();
            
            // set tran data according to input
            tran_data.read = read;
            tran_data.mask = mask;
            tran_data.wdata = data;
            tran_data.addr = addr;

            // send the generated data to driver
            this.gen2drv.put(tran_data);
        endtask
    endclass //icb_generator

    // Driver: Converts the received packets to the format of the ICB protocol
    class icb_driver;

        // BUILD
        //=============================================================
        mailbox #(icb_trans)    gen2drv; // receive the data from generator

        function new(
            mailbox #(icb_trans)    gen2drv
        );
            this.gen2drv = gen2drv;
        endfunction //new()
        
        // CONNECT
        //=============================================================
        local virtual icb_bus.master active_channel;

        function void set_intf(
            virtual icb_bus.master icb
        );
            this.active_channel = icb;

            // port initialization to avoid 'x' state in dut
            this.active_channel.mst_cb.icb_cmd_valid <= 1'b0;
            this.active_channel.mst_cb.icb_cmd_read <= 1'b0;
            this.active_channel.mst_cb.icb_cmd_addr <= 32'h0000_0000;
            this.active_channel.mst_cb.icb_cmd_wdata <= 64'h0000_0000_0000_0000;
            this.active_channel.mst_cb.icb_cmd_wmask <= 8'h00;

            this.active_channel.mst_cb.icb_rsp_ready <= 1'b1;
        endfunction

        // FUNC : data transfer
        //=============================================================
        task automatic data_trans();
            icb_trans   get_trans;

            // get the input data and address from mailbox
            this.gen2drv.get(get_trans);

            // setup the transaction
            @(this.active_channel.mst_cb)
            this.active_channel.mst_cb.icb_cmd_valid <= 1'b1;
            this.active_channel.mst_cb.icb_cmd_read <= get_trans.read;
            this.active_channel.mst_cb.icb_cmd_wmask <= get_trans.mask;
            this.active_channel.mst_cb.icb_cmd_wdata <= get_trans.wdata;
            this.active_channel.mst_cb.icb_cmd_addr <= get_trans.addr;
            this.active_channel.mst_cb.icb_rsp_ready <= 1'b1;

            // wait until the handshake finished
            while(!this.active_channel.icb_cmd_ready) begin
                @(this.active_channel.mst_cb);
            end

            // end the transaction
            //@(this.active_channel.mst_cb)
            this.active_channel.mst_cb.icb_cmd_valid <= 1'b0;
        endtask //automatic
    endclass //icb_driver

    // **Optional** 
    // Monitor: Collect ICB data and convert it to data package for
    //          scoreboard to compare result.
    class icb_monitor;

        // BUILD
        //=============================================================
        icb_trans monitor_trans;
        mailbox #(icb_trans)    icb_monitor_data;

        function new(
            mailbox #(icb_trans)    icb_monitor_data 
        );
            this.icb_monitor_data = icb_monitor_data;
            this.monitor_trans = new();
        endfunction //new()
        // CONNECT
        //=============================================================
        local virtual icb_bus.monitor monitor_channel;

        function void set_intf(
            virtual icb_bus.monitor icb
        );
            this.monitor_channel = icb;
        endfunction

        // FUNC
        //=============================================================
        task automatic mst_monitor(ref bit is_read);

            @(this.monitor_channel.mnt_cb)
            while(!this.monitor_channel.icb_cmd_ready) begin
                @(this.monitor_channel.mnt_cb);
            end
            this.monitor_trans.read = this.monitor_channel.icb_cmd_read;
            this.monitor_trans.mask = this.monitor_channel.icb_cmd_wmask;
            this.monitor_trans.wdata = this.monitor_channel.icb_cmd_wdata;
            this.monitor_trans.addr = this.monitor_channel.icb_cmd_addr;
            
            is_read = this.monitor_trans.read;

            if(is_read) begin
                $display("ICB Master Read : Addr=%h", this.monitor_trans.addr);
            end else begin
                $display("ICB Master Write : Addr=%h, WData=%h", this.monitor_trans.addr, this.monitor_trans.wdata);
            end
        endtask

        task automatic slv_monitor(ref bit is_read);

            //@(this.monitor_channel.mnt_cb)
            while(!this.monitor_channel.icb_rsp_valid) begin
                @(this.monitor_channel.mnt_cb);
            end

            this.monitor_trans.rdata = this.monitor_channel.icb_rsp_rdata;

            if(is_read) begin
                $display("ICB Master Response : RData=%h ",this.monitor_trans.rdata);
            end
        endtask

        task automatic monitor2scoreboard();
            this.icb_monitor_data.put(this.monitor_trans);
        endtask

    endclass //icb_monitor

    // Agent: The top class that connects generator, driver and monitor
    class icb_agent;
        
        // BUILD
        //=============================================================
        mailbox #(icb_trans)    gen2drv;
        mailbox #(icb_trans)    icb_monitor_data;

        icb_generator           icb_generator;
        icb_driver              icb_driver;
        icb_monitor             icb_monitor;

        bit                     is_read = 0;        // record the transaction is read or write

        function new(
            mailbox #(icb_trans)    monitor_icb
        );
            this.gen2drv = new(1);
            this.icb_monitor_data = monitor_icb;
            this.icb_generator = new(this.gen2drv);
            this.icb_driver = new(this.gen2drv);
            this.icb_monitor = new(this.icb_monitor_data);
        endfunction //new()

        // CONNECT
        //=============================================================
        function void set_intf(
            virtual icb_bus icb
        );   
            // connect to icb_driver
            this.icb_driver.set_intf(icb);
            this.icb_monitor.set_intf(icb);
        endfunction //automatic

        // FUN : single data tran
        //=============================================================
        task automatic single_tran(
            input           read = 1'b1,
            input [7:0]     mask = 8'h00,
            input [63:0]    data = 64'h0000_0000_0000_0000,
            input [31:0]    addr = 32'h2000_0000
        );
            // generate data
            this.icb_generator.data_gen(read, mask, data, addr);

            fork
                // drive data
                this.icb_driver.data_trans();
                // monitor data
                this.icb_monitor.mst_monitor( this.is_read );
            join_any

            this.icb_monitor.slv_monitor( this.is_read );

            this.icb_monitor.monitor2scoreboard();
        
        endtask //automatic
    endclass //icb_agent
endpackage


