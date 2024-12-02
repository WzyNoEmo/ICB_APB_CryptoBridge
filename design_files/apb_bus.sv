//===================================================================== 
/// Description: 
// the interface of apb
// Designer : sjl_519021910940@sjtu.edu.cn
// ==================================================================== 

/*
This is only the basic interface, you may change it by your own.
But don't change this signal discription.
*/
`timescale 1ns/1ps

interface apb_bus(input logic clk,input logic rst_n);
    logic pwrite;
    logic psel;
    logic [31:0] paddr;
    logic [31:0] pwdata;
    logic penable;

    logic [31:0] prdata;
    logic pready;

    modport slave(input pwrite,psel,paddr,pwdata,penable,clk,rst_n,
    output prdata,pready,slv_cb);
    modport master(output pwrite,psel,paddr,pwdata,penable,
    input prdata,pready,clk,rst_n);
    modport monitor(input pwrite,psel,paddr,pwdata,penable,
    prdata,pready,clk,rst_n,mnt_cb);

    // Clocking block for master
    clocking slv_cb @(posedge clk);
        default input #1 output #1; // default timing for input and output
        output prdata, pready;
        input pwrite, psel, paddr, pwdata, penable;
    endclocking

    clocking mnt_cb @(posedge clk);
        default input #1 output #1; // default timing for input and output
        input pwrite, psel, paddr, pwdata, penable, prdata, pready;
    endclocking

endinterface:apb_bus //apb    