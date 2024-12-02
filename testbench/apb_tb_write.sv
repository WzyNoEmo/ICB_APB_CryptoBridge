`timescale 1ns/1ps

module apb_tb_write;


logic clk;
logic rst_n;

apb_bus apb_bus_0(clk, rst_n);
apb_bus apb_bus_1(clk, rst_n);
apb_bus apb_bus_2(clk, rst_n);
apb_bus apb_bus_3(clk, rst_n);

logic [63:0] control;
logic empty;
logic full;
logic [31:0] rdata;

logic rdata_en;
logic wdata_vld;
logic [31:0] wdata;


apb_master u_apb_master(
    .empty (empty ),
    .full  (full  ),
    .rdata (rdata ),
    .rdata_en   (rdata_en   ),
    .wdata_vld   (wdata_vld   ),
    .wdata       (wdata       ),
    .apb_bus_0   (apb_bus_0   ),
    .apb_bus_1   (apb_bus_1   ),
    .apb_bus_2   (apb_bus_2   ),
    .apb_bus_3   (apb_bus_3   )
);

initial begin
    rst_n <= 0;
    clk <= 1;
    apb_bus_0.prdata <= 0;
    apb_bus_0.pready <= 0;
    apb_bus_1.prdata <= 0;
    apb_bus_1.pready <= 0;
    control <= 0;
    empty <= 1;
    full <= 0;
    rdata <= 0;

    #15
    rst_n <= 1;

    #15
    empty <= 0;

    #10	;
    #10
    rdata <= {24'h000004, 8'b00000110};  //bus0 write addr 0000004
    
    #10;
    #10
    rdata <= {31'h8, 1'b1};             // data 8
    empty <= 1;

    #10;

    #10
    apb_bus_0.pready <= 1;

    #10;

    #10;

    #10;
        
end

always #5 clk = ~clk;

endmodule