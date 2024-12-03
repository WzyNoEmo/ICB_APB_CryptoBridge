//=====================================================================
// Description:
// This file is the top testbench file. In the testbench_top module, build
// the instance of the module of dut and program of testbench, even the
// interface and some global signals. 'testbench' file control the total 
// sim process, here add your command to ENV object.
// Designer : lynnxie@sjtu.edu.cn
// Revision History
// V0 date:2024/11/07 Initial version, lynnxie@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

module testbench_top ();

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

//=====================================================================
// Connections between DUT And Testbench
//=====================================================================

    testbench i_testbench(
        .clk   (        clk             ),
        .rst_n (        rst_n           ),

        // source channel connections
        .icb(           icb             ),

        .apb0(          apb0            ),
        .apb1(          apb1            ),
        .apb2(          apb2            ),
        .apb3(          apb3            )
        // ...
    ); 

    dut i_dut(
        // input bus
        .icb(           icb             ),

        // output bus
        .apb0(          apb0            ),
        .apb1(          apb1            ),
        .apb2(          apb2            ),
        .apb3(          apb3            )
    );
endmodule

program testbench(
    input  logic            clk,
    input  logic            rst_n,

    icb_bus.master          icb,

    apb_bus.slave           apb0,
    apb_bus.slave           apb1,
    apb_bus.slave           apb2,
    apb_bus.slave           apb3
    // ...
);
    import env::*;   // import your ENV object
    env_ctrl envctrl; // first declare it

    initial begin
        
        $display("[TB- SYS ] welcome to sv testbench plateform !");

        // BUILD
        //=============================================================      
        // the first step in testbench is build your env object 
        // as your command manager, after that you can call it
        // also with its subordinates
        $display("[TB- SYS ] building");
        envctrl = new();

        // CONNECT
        //=============================================================
        // let your manager connected to your dut by interface
        $display("[TB- SYS ] connecting");
        envctrl.set_intf(
            icb,
            apb0,
            apb1,
            apb2,
            apb3
        );

        // RUN
        //=============================================================
        // give command to your env object
        $display("[TB- SYS ] running");

        // (1) waiting for rst done in dut
        repeat(11) @(posedge clk);
        
        // (2) add your command here 
        // example :
        //envctrl.run("ICB Write");
    
        fork
            begin
                #1;
                //envctrl.run("ICB Write Test");                    // pass
                //envctrl.run("ICB RAW Test");                      // pass  
                //envctrl.run("APB Write");                         // pass
                //envctrl.run("APB Read");                          // pass
                //envctrl.run("LOOPBACK Test");                       // pass  
                envctrl.run("RANDOM Test");                         // pass
            end                // The testcase you want to run
            //envctrl.run("Time_Run");                       
        join_any
        disable fork;        

        // END
        //=============================================================  
        $display("[TB- SYS ] testbench system has done all the work, exit !");

    end
endprogram