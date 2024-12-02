//===================================================================== 
/// Description: 
// this is the top file of our dut, this module should never be changed
// Designer : wangziyao1@sjtu.edu.cn
// ==================================================================== 
/* don't change the signal */
module dut_top(
    //input bus
    icb_bus.slave icb_bus,

    //ouput bus
    apb_bus.master apb_bus_0,
    apb_bus.master apb_bus_1,
    apb_bus.master apb_bus_2,
    apb_bus.master apb_bus_3

);

/* put your code here */

//for example

logic wfifo_empty;
logic wfifo_full;
logic [63:0] wfifo_rdata;
logic wfifo_rdata_en;
logic [63:0] wfifo_wdata;
logic wfifo_wdata_vld;
logic [63:0] wfifo_wdata_raw;       // no decrypt
logic wfifo_wdata_vld_raw;

logic rfifo_empty;
logic rfifo_full;
logic [63:0] rfifo_rdata;
logic rfifo_rdata_en;
logic [63:0] rfifo_wdata;
logic rfifo_wdata_vld;
logic [31:0] rfifo_wdata_raw;       // no encrypt
logic rfifo_wdata_vld_raw;

logic [63:0] key;

//icb module
icb_slave u_icb_slave(
    .icb_bus (icb_bus),
    .empty(rfifo_empty),
    .full(wfifo_full),
    .key(key),
    .rdata(rfifo_rdata),                    // rfifo read data
    .rdata_en(rfifo_rdata_en),              // rfifo read enable
    .wdata(wfifo_wdata_raw),                // to decrypt write data
    .wdata_vld(wfifo_wdata_vld_raw)         // to decrypt write valid
);

//apb module
apb_master u_apb_master(
    .apb_bus_0(apb_bus_0),
    .apb_bus_1(apb_bus_1),
    .apb_bus_2(apb_bus_2),
    .apb_bus_3(apb_bus_3),
    .empty(wfifo_empty),
    .full(rfifo_full),
    .rdata(wfifo_rdata[31:0]),                    // wfifo read data
    .rdata_en(wfifo_rdata_en),              // wfifo read enable
    .wdata(rfifo_wdata_raw),                // to encrypt write data
    .wdata_vld(rfifo_wdata_vld_raw)         // to encrypt write data valid
);

//encrypt module
encrypt u_encrypt(
    .clk(apb_bus_0.clk),
    .data({32'b0,rfifo_wdata_raw}),
    .data_vld(rfifo_wdata_vld_raw),
    .key(key),
    .result(rfifo_wdata),
    .result_vld(rfifo_wdata_vld)
);

//decrypt module
encrypt u_decrypt(
    .clk(icb_bus.clk),
    .data(wfifo_wdata_raw),
    .data_vld(wfifo_wdata_vld_raw),
    .key(key),
    .result(wfifo_wdata),
    .result_vld(wfifo_wdata_vld)
);

//fifo module
fifo u_rfifo(
    .rclk(apb_bus_0.clk),
    .wclk(icb_bus.clk),
    .rst_n(icb_bus.rst_n & apb_bus_0.rst_n),
    .empty(rfifo_empty),
    .full(rfifo_full),
    .rdata(rfifo_rdata),
    .rdata_en(rfifo_rdata_en),
    .wdata(rfifo_wdata),
    .wdata_vld(rfifo_wdata_vld)
);

fifo u_wfifo(
    .rclk(icb_bus.clk),
    .wclk(apb_bus_0.clk),
    .rst_n(icb_bus.rst_n & apb_bus_0.rst_n),
    .empty(wfifo_empty),
    .full(wfifo_full),
    .rdata(wfifo_rdata),
    .rdata_en(wfifo_rdata_en),
    .wdata(wfifo_wdata),
    .wdata_vld(wfifo_wdata_vld)
);

endmodule