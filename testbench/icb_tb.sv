`timescale 1ns/1ps

module icb_tb;

logic clk;
logic rst_n;

icb_bus icb_bus(clk, rst_n);
logic empty;
logic full;
logic [63:0] key;
logic [63:0] rdata;
logic rdata_en;
logic [63:0] wdata;
logic wdata_vld;



icb_slave u_icb_slave(
    .icb_bus    (icb_bus    ),
    .empty      (empty      ),
    .full       (full       ),
    .key        (key        ),
    .rdata      (rdata      ),
    .rdata_en   (rdata_en   ),
    .wdata      (wdata      ),
    .wdata_vld  (wdata_vld  )
);

initial begin
    rst_n <= 0;
    clk <= 1;
    icb_bus.icb_cmd_valid <= 0;
    icb_bus.icb_cmd_addr <= 0;
    icb_bus.icb_cmd_read <= 1;
    icb_bus.icb_cmd_wdata <= 0;
    icb_bus.icb_cmd_wmask <= 0;
    empty <= 0;
    full <= 0;

    #15
    rst_n <= 1;
    
    // write control
    #5
    icb_bus.icb_cmd_valid <= 1;
    icb_bus.icb_cmd_addr <= 64'h20000000;
    icb_bus.icb_cmd_read <= 0;
    icb_bus.icb_cmd_wdata <= 64'hf;

    // read control
    #10
    icb_bus.icb_cmd_valid <= 1;
    icb_bus.icb_cmd_addr <= 64'h20000000;
    icb_bus.icb_cmd_read <= 1;

    // write key
    #10
    icb_bus.icb_cmd_valid <= 1;
    icb_bus.icb_cmd_addr <= 64'h20000020;
    icb_bus.icb_cmd_read <= 0;
    icb_bus.icb_cmd_wdata <= 64'h0123456789abcdef;
    icb_bus.icb_cmd_wmask <= 8'b01010101;


    // read key
    #10
    icb_bus.icb_cmd_valid <= 1;
    icb_bus.icb_cmd_addr <= 64'h20000020;
    icb_bus.icb_cmd_read <= 1;
    
    // test read rdata
    #10
    icb_bus.icb_cmd_valid <= 1;
    icb_bus.icb_cmd_addr <= 64'h20000018;
    icb_bus.icb_cmd_read <= 1;

    // test write wdata
    #10
    icb_bus.icb_cmd_valid <= 0;
    icb_bus.icb_cmd_addr <= 64'h20000000;
    icb_bus.icb_cmd_read <= 0;
    full <= 1;

    #10
    icb_bus.icb_cmd_valid <= 1;
    icb_bus.icb_cmd_addr <= 64'h20000010;
    icb_bus.icb_cmd_read <= 0;
    icb_bus.icb_cmd_wdata <= 64'hfedcba9876543210;
    icb_bus.icb_cmd_wmask <= 8'b11111111;

    #10
    full <= 0;

    // reset
    #10
    icb_bus.icb_cmd_valid <= 0;
    icb_bus.icb_cmd_addr <= 64'h0;
    icb_bus.icb_cmd_read <= 1;
    icb_bus.icb_cmd_wdata <= 64'h0;


    #50
    $finish;

end

always #5 clk = ~clk;

assign icb_bus.icb_rsp_ready = icb_bus.icb_rsp_valid; 

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        rdata <= 0;
    end else if (rdata_en) begin
        rdata <= 64'hA5A5A5A5;
    end else begin
        rdata <= 0;
    end
end

endmodule