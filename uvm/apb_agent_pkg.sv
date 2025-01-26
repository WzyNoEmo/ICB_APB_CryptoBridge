package apb_agent_pkg;

    import uvm_pkg::*;
    import sequence_pkg::*;
    `include "uvm_macros.svh"

    class apb_sequencer extends uvm_sequencer #(apb_trans);          

        `uvm_component_utils(apb_sequencer)            

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        task run_phase(uvm_phase phase);
            apb_read_sequence apb_seq; 
            //phase.raise_objection(this);
            apb_seq = apb_read_sequence::type_id::create("apb_seq");
            apb_seq.start(this);
            //phase.drop_objection(this);
        endtask

    endclass


    class apb_driver extends uvm_driver #(apb_trans);

        `uvm_component_utils(apb_driver);
        local virtual apb_bus.slave active_channel;

        function new(string name = "apb_driver", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual apb_bus)::get(this, "", "active_channel", active_channel)) begin
                `uvm_fatal("NO_VIF", "Virtual interface must be set for: apb_vi")
            end
        endfunction

        task run_phase(uvm_phase phase);

            //phase.raise_objection(this);

            while(1) begin
                seq_item_port.get_next_item(req);
                // wait until apb access
                while(!(this.active_channel.psel && this.active_channel.penable)) begin
                    @(this.active_channel.slv_cb);
                end

                this.active_channel.slv_cb.pready <= 1'b1;

                this.active_channel.slv_cb.prdata <= this.active_channel.pwrite? 32'b0 : req.rdata;
                
                // end the transaction
                @(this.active_channel.slv_cb)
                this.active_channel.slv_cb.pready <= 1'b0;
                seq_item_port.item_done();
            end

            //phase.drop_objection(this);

        endtask //run_phase

    endclass //apb_driver

    class apb_monitor extends uvm_monitor;

        `uvm_component_utils(apb_monitor);
        local virtual apb_bus.monitor monitor_channel;
        uvm_analysis_port #(apb_trans) apb_ap;

        function new(string name = "apb_monitor", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual apb_bus)::get(this, "", "monitor_channel", monitor_channel)) begin
                `uvm_fatal("NO_VIF", "Virtual interface must be set for: apb_vi")
            end
            apb_ap = new("apb_ap", this);
        endfunction

        task run_phase(uvm_phase phase);

            apb_trans  monitor_trans;
            
            while(1) begin
                monitor_trans = new();
                collect_one_pkt(monitor_trans);
                apb_ap.write(monitor_trans);
            end
        endtask //run_phase

        task automatic collect_one_pkt(apb_trans  monitor_trans);

            bit is_read;

            while(!(this.monitor_channel.psel && this.monitor_channel.penable)) begin
                @(this.monitor_channel.mnt_cb);
            end

            monitor_trans.write = this.monitor_channel.pwrite;
            monitor_trans.addr = this.monitor_channel.paddr;
            monitor_trans.wdata = this.monitor_channel.pwdata;

            is_read = ~monitor_trans.write;

            
            if(is_read) begin
                $display("APB Deocode : APB Master Read: Addr=%h", monitor_trans.addr);
            end else begin
                $display("APB Deocode : APB Master Write: Addr=%h, WData=%h", monitor_trans.addr, monitor_trans.wdata);
            end

            @(this.monitor_channel.mnt_cb);

            while(!this.monitor_channel.pready) begin
                @(this.monitor_channel.mnt_cb);
            end

            monitor_trans.rdata = this.monitor_channel.prdata;

            if(is_read) begin
                $display("APB Slave Response : RData=%h",monitor_trans.rdata);
            end 

            @(this.monitor_channel.mnt_cb);
        endtask
    endclass //apb_monitor

    class apb_agent extends uvm_agent;

        `uvm_component_utils(apb_agent);
        uvm_analysis_port #(apb_trans) apb_ap;

        apb_driver  apb_drv;
        apb_monitor apb_mnt;
        apb_sequencer apb_sqr;

        function new(string name = "apb_agent", uvm_component parent = null);
            super.new(name, parent);
        endfunction //new

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            apb_drv = apb_driver::type_id::create("apb_drv", this);
            apb_mnt = apb_monitor::type_id::create("apb_mnt", this);
            apb_sqr = apb_sequencer::type_id::create("apb_sqr", this);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            apb_ap = apb_mnt.apb_ap;
            apb_drv.seq_item_port.connect(apb_sqr.seq_item_export);
        endfunction

    endclass //apb_agent

endpackage