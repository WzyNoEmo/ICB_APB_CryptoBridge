`timescale 1ns/1ps

import icb_agent_pkg::*;
import apb_agent_pkg::*;
import sequence_pkg::*;
import env_pkg::*;
import uvm_pkg::*;
`include "uvm_macros.svh"

module testbench_top();

//=====================================================================
// Parameters
//=====================================================================

    parameter CLK_PERIOD = 10;

//=====================================================================
// Signals Declaration
//=====================================================================

    // uninterface signals 
    logic clk  ;
    logic rst_n;

    // interface signals
    icb_bus     icb(.*);
    apb_bus     apb0(.*);
    apb_bus     apb1(.*);
    apb_bus     apb2(.*);
    apb_bus     apb3(.*);

//=====================================================================
// Signals' Function
//=====================================================================
    
	initial begin 
		clk    = 0 ;
		forever #(CLK_PERIOD /2) clk = ~clk;
	end

	initial begin
		rst_n   = 0;
		repeat(10) @(posedge clk) ;
		rst_n   = 1;
	end

    dut i_dut(
        // input bus
        .icb(           icb             ),

        // output bus
        .apb0(          apb0            ),
        .apb1(          apb1            ),
        .apb2(          apb2            ),
        .apb3(          apb3            )
    );

    initial begin
        uvm_config_db#(virtual icb_bus)::set(null, "uvm_test_top.env.icb_agt.icb_drv", "active_channel", icb);
        uvm_config_db#(virtual icb_bus)::set(null, "uvm_test_top.env.icb_agt.icb_mnt", "monitor_channel", icb);
        uvm_config_db#(virtual apb_bus)::set(null, "uvm_test_top.env.apb_agt_0.apb_drv", "active_channel", apb0);
        uvm_config_db#(virtual apb_bus)::set(null, "uvm_test_top.env.apb_agt_0.apb_mnt", "monitor_channel", apb0);
        uvm_config_db#(virtual apb_bus)::set(null, "uvm_test_top.env.apb_agt_1.apb_drv", "active_channel", apb1);
        uvm_config_db#(virtual apb_bus)::set(null, "uvm_test_top.env.apb_agt_1.apb_mnt", "monitor_channel", apb1);
        uvm_config_db#(virtual apb_bus)::set(null, "uvm_test_top.env.apb_agt_2.apb_drv", "active_channel", apb2);
        uvm_config_db#(virtual apb_bus)::set(null, "uvm_test_top.env.apb_agt_2.apb_mnt", "monitor_channel", apb2);
        uvm_config_db#(virtual apb_bus)::set(null, "uvm_test_top.env.apb_agt_3.apb_drv", "active_channel", apb3);
        uvm_config_db#(virtual apb_bus)::set(null, "uvm_test_top.env.apb_agt_3.apb_mnt", "monitor_channel", apb3);
    end

    initial begin
        run_test("my_test");
    end

endmodule