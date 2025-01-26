
package icb_agent_pkg;

    import uvm_pkg::*;
    import sequence_pkg::*;
    `include "uvm_macros.svh"

    class icb_sequencer extends uvm_sequencer #(icb_trans);          

        `uvm_component_utils(icb_sequencer)            

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

    endclass

    class icb_driver extends uvm_driver #(icb_trans);

        `uvm_component_utils(icb_driver);
        local virtual icb_bus.master active_channel;

        function new(string name = "icb_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual icb_bus)::get(this, "", "active_channel", active_channel)) begin
                `uvm_fatal("NO_VIF", "Virtual interface must be set for: icb_vi")
            end
        endfunction

        task run_phase(uvm_phase phase);

            //phase.raise_objection(this);

            // setup the transaction
            while(1) begin 
                seq_item_port.get_next_item(req);
                @(this.active_channel.mst_cb)
                this.active_channel.mst_cb.icb_cmd_valid <= 1'b1;
                this.active_channel.mst_cb.icb_cmd_read <= req.read;
                this.active_channel.mst_cb.icb_cmd_wmask <= req.mask;
                this.active_channel.mst_cb.icb_cmd_wdata <= req.wdata;
                this.active_channel.mst_cb.icb_cmd_addr <= req.addr;

                // wait until the handshake finished
                while(!this.active_channel.icb_cmd_ready) begin
                    @(this.active_channel.mst_cb);
                end

                // end the transaction
                this.active_channel.mst_cb.icb_cmd_valid <= 1'b0;
                seq_item_port.item_done();
            end

            //phase.drop_objection(this);
        endtask //run_phase

    endclass //icb_driver

    class icb_monitor extends uvm_monitor;

        `uvm_component_utils(icb_monitor);
        local virtual icb_bus.monitor monitor_channel;
        uvm_analysis_port #(icb_trans) icb_ap;

        function new(string name = "icb_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual icb_bus)::get(this, "", "monitor_channel", monitor_channel)) begin
                `uvm_fatal("NO_VIF", "Virtual interface must be set for: icb_vi")
            end
            icb_ap = new("icb_ap", this);
        endfunction

        task run_phase(uvm_phase phase);
            icb_trans  monitor_trans;
            
            while(1) begin
                monitor_trans = new();
                collect_one_pkt(monitor_trans);
                icb_ap.write(monitor_trans);
            end
        endtask //run_phase

        task automatic collect_one_pkt(icb_trans monitor_trans);

            bit is_read;

            @(this.monitor_channel.mnt_cb)
            while(!this.monitor_channel.icb_cmd_ready) begin
                @(this.monitor_channel.mnt_cb);
            end
            monitor_trans.read = this.monitor_channel.icb_cmd_read;
            monitor_trans.mask = this.monitor_channel.icb_cmd_wmask;
            monitor_trans.wdata = this.monitor_channel.icb_cmd_wdata;
            monitor_trans.addr = this.monitor_channel.icb_cmd_addr;
            
            is_read = monitor_trans.read;

            if(is_read) begin
                $display("ICB Master Read : Addr=%h", monitor_trans.addr);
            end else begin
                $display("ICB Master Write : Addr=%h, WData=%h", monitor_trans.addr, monitor_trans.wdata);
            end

            //@(this.monitor_channel.mnt_cb)
            while(!this.monitor_channel.icb_rsp_valid) begin
                @(this.monitor_channel.mnt_cb);
            end

            monitor_trans.rdata = this.monitor_channel.icb_rsp_rdata;

            if(is_read) begin
                $display("ICB Master Response : RData=%h ",monitor_trans.rdata);
            end
        endtask

    endclass //icb_monitor

    class icb_agent extends uvm_agent;

        `uvm_component_utils(icb_agent);
        uvm_analysis_port #(icb_trans) icb_ap;

        icb_driver  icb_drv;
        icb_monitor icb_mnt;
        icb_sequencer icb_sqr;

        function new(string name = "icb_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            icb_drv = icb_driver::type_id::create("icb_drv", this);
            icb_mnt = icb_monitor::type_id::create("icb_mnt", this);
            icb_sqr = icb_sequencer::type_id::create("icb_sqr", this);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            icb_drv.seq_item_port.connect(icb_sqr.seq_item_export);
            icb_ap = icb_mnt.icb_ap;
        endfunction

    endclass


endpackage