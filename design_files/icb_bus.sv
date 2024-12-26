//===================================================================== 
/// Description: 
// the interface of icb
// Designer : wangziyao1@sjtu.edu.cn
// ==================================================================== 

/*
This is only the basic interface, you may change it by your own.
But don't change this signal discription.
*/
`timescale 1ns/1ps

interface icb_bus(input logic clk,input logic rst_n);
    //command channel
    logic icb_cmd_valid;
    logic icb_cmd_ready;
    logic [63:0] icb_cmd_addr;
    logic icb_cmd_read;
    logic [63:0] icb_cmd_wdata;
    logic [7:0] icb_cmd_wmask;

    //response channel
    logic icb_rsp_valid;
    logic icb_rsp_ready;
    logic [63:0] icb_rsp_rdata;
    logic icb_rsp_err;


    modport slave(input icb_cmd_valid, icb_cmd_addr, icb_cmd_read, icb_cmd_wdata, icb_cmd_wmask, icb_rsp_ready, clk, rst_n,
    output icb_cmd_ready, icb_rsp_valid, icb_rsp_rdata, icb_rsp_err);
    modport master(output icb_cmd_valid, icb_cmd_addr, icb_cmd_read, icb_cmd_wdata, icb_cmd_wmask, icb_rsp_ready,
    input icb_cmd_ready, icb_rsp_valid, icb_rsp_rdata, icb_rsp_err,  clk, rst_n , mst_cb);
    modport monitor(input icb_cmd_valid, icb_cmd_addr, icb_cmd_read, icb_cmd_wdata, icb_cmd_wmask, icb_rsp_ready,
    icb_cmd_ready, icb_rsp_valid, icb_rsp_rdata, icb_rsp_err,  clk, rst_n , mnt_cb);

    // Clocking block for master
    clocking mst_cb @(posedge clk);
        default input #1 output #1; // default timing for input and output
        output icb_cmd_valid, icb_cmd_read, icb_cmd_addr, icb_cmd_wdata, icb_cmd_wmask, icb_rsp_ready;
        input icb_cmd_ready, icb_rsp_valid, icb_rsp_rdata, icb_rsp_err;
    endclocking

    clocking mnt_cb @(posedge clk);
        default input #1 output #1; // default timing for input and output
        input icb_cmd_valid, icb_cmd_read, icb_cmd_addr, icb_cmd_wdata, icb_cmd_wmask, icb_rsp_ready,
        icb_cmd_ready, icb_rsp_valid, icb_rsp_rdata, icb_rsp_err;
    endclocking

endinterface:icb_bus //icb    