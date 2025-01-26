package env_pkg;

    import icb_agent_pkg::*;
    import apb_agent_pkg::*;
    import scoreboard_pkg::*;
    import sequence_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter  CTRL_ADDR = 32'h2000_0000;
    parameter  STAT_ADDR = 32'h2000_0008;
    parameter  WDATA_ADDR = 32'h2000_0010;
    parameter  RDATA_ADDR = 32'h2000_0018;
    parameter  KEY_ADDR = 32'h2000_0020;


    class my_env extends uvm_env;

        `uvm_component_utils(my_env)

        icb_agent icb_agt;
        apb_agent apb_agt_0;
        apb_agent apb_agt_1;
        apb_agent apb_agt_2;
        apb_agent apb_agt_3;
        my_model mdl;

        uvm_tlm_analysis_fifo #(icb_trans) icb_agt_mdl_fifo;
        uvm_tlm_analysis_fifo #(apb_trans) apb_0_agt_mdl_fifo;
        uvm_tlm_analysis_fifo #(apb_trans) apb_1_agt_mdl_fifo;
        uvm_tlm_analysis_fifo #(apb_trans) apb_2_agt_mdl_fifo;
        uvm_tlm_analysis_fifo #(apb_trans) apb_3_agt_mdl_fifo;

        function new(string name = "my_env", uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            icb_agt = icb_agent::type_id::create("icb_agt", this);
            apb_agt_0 = apb_agent::type_id::create("apb_agt_0", this);
            apb_agt_1 = apb_agent::type_id::create("apb_agt_1", this);
            apb_agt_2 = apb_agent::type_id::create("apb_agt_2", this);
            apb_agt_3 = apb_agent::type_id::create("apb_agt_3", this);
            mdl = my_model::type_id::create("mdl", this);

            icb_agt_mdl_fifo = new("icb_agt_mdl_fifo", this);
            apb_0_agt_mdl_fifo = new("apb_0_agt_mdl_fifo", this);
            apb_1_agt_mdl_fifo = new("apb_1_agt_mdl_fifo", this);
            apb_2_agt_mdl_fifo = new("apb_2_agt_mdl_fifo", this);
            apb_3_agt_mdl_fifo = new("apb_3_agt_mdl_fifo", this);
        endfunction

        virtual function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            icb_agt.icb_ap.connect(icb_agt_mdl_fifo.analysis_export);
            mdl.icb_bgp.connect(icb_agt_mdl_fifo.blocking_get_export);
            apb_agt_0.apb_ap.connect(apb_0_agt_mdl_fifo.analysis_export);
            mdl.apb_0_bgp.connect(apb_0_agt_mdl_fifo.blocking_get_export);
            apb_agt_1.apb_ap.connect(apb_1_agt_mdl_fifo.analysis_export);
            mdl.apb_1_bgp.connect(apb_1_agt_mdl_fifo.blocking_get_export);
            apb_agt_2.apb_ap.connect(apb_2_agt_mdl_fifo.analysis_export);
            mdl.apb_2_bgp.connect(apb_2_agt_mdl_fifo.blocking_get_export);
            apb_agt_3.apb_ap.connect(apb_3_agt_mdl_fifo.analysis_export);
            mdl.apb_3_bgp.connect(apb_3_agt_mdl_fifo.blocking_get_export);
        endfunction
    
    endclass

    class my_test extends uvm_test;

        `uvm_component_utils(my_test)

        my_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        virtual function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = my_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);

            apb_read_write_sequence test_seq;

            test_seq = apb_read_write_sequence::type_id::create("test_seq", this);

            phase.phase_done.set_drain_time(this, 1000);

            phase.raise_objection(this);

            test_seq.start(env.icb_agt.icb_sqr);  

            phase.drop_objection(this);

        endtask

    endclass

endpackage