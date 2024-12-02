`timescale 1ns / 1ps

module fifo_tb;

    // Parameters
    localparam ADDR_WIDTH = 3;
    localparam DEPTH = 1 << ADDR_WIDTH;

    // Signals
    logic rst_n;
    logic rclk;
    logic wclk;
    logic empty;
    logic full;
    logic [31:0] rdata;
    logic rdata_en;
    logic [31:0] wdata;
    logic wdata_vld;

    // FIFO Instance
    fifo u_fifo (
        .rst_n(rst_n),
        .rclk(rclk),
        .wclk(wclk),
        .empty(empty),
        .full(full),
        .rdata(rdata),
        .rdata_en(rdata_en),
        .wdata(wdata),
        .wdata_vld(wdata_vld)
    );

    // Clock Generation
    always #5 rclk = ~rclk; // 模拟读时钟，周期10ns
    always #3 wclk = ~wclk; // 模拟写时钟，周期6ns

    // Test Sequence
    initial begin
        // Initialize
        rst_n <= 0;
        rclk <= 0;
        wclk <= 0;
        rdata_en <= 0;
        wdata_vld <= 0;
        wdata <= 0;

        // Reset the FIFO
        #15;
        rst_n <= 1;

        // Write some data
        #6;
        wdata <= 32'hA5A5A5A5;
        wdata_vld <= 1;
        #12;
        wdata_vld <= 0;

        // Read data
        #22;
        rdata_en <= 1;
        #20;
        rdata_en <= 0;

        #100;

        // full 8*6ns = 48ns
        wdata <= 32'hA5A5A5A5;
        wdata_vld <= 1;
        #48;
        wdata_vld <= 0;
        rdata_en <= 1;
        #20;
        rdata_en <= 0;

        $finish;
    end

endmodule