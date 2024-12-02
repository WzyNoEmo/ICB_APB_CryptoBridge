module fifo(
//  clk signal
    input  logic rst_n,
    input  logic rclk,
    input  logic wclk,

//  state signal
    output logic empty,
    output logic full,

//  port signal
    output logic [63:0] rdata,
    input  logic rdata_en,
    input  logic [63:0] wdata,
    input  logic wdata_vld          // wdata_en
);

    localparam ADDR_WIDTH = 3;
    localparam DEPTH = 1 << ADDR_WIDTH;

    logic [63:0] mem [0:DEPTH-1];
    logic [ADDR_WIDTH:0] wptr, rptr;
    logic [ADDR_WIDTH:0] wptr_gray, rptr_gray;
    logic [ADDR_WIDTH:0] wptr_gray_sync1, wptr_gray_sync2;
    logic [ADDR_WIDTH:0] rptr_gray_sync1, rptr_gray_sync2;

    //  write
    always_ff @(posedge wclk or negedge rst_n) begin
        if (!rst_n) begin
            wptr <= 0;
        end else if (wdata_vld && !full) begin
            mem[wptr[ADDR_WIDTH-1:0]] <= wdata;
            wptr <= wptr + 1;
        end
    end

    //  read
    always_ff @(posedge rclk or negedge rst_n) begin
        if (!rst_n) begin
            rptr <= 0;
        end else if (rdata_en && !empty) begin
            rdata <= mem[rptr[ADDR_WIDTH-1:0]] ;
            rptr <= rptr + 1;
        end else begin
            rdata <= 0;
        end
    end
    
    //  ptr : bin to gray
    function logic [ADDR_WIDTH:0] bin2gray(input logic [ADDR_WIDTH:0] bin);
        return (bin >> 1) ^ bin;
    endfunction

    assign wptr_gray = bin2gray(wptr);
    assign rptr_gray = bin2gray(rptr);

    //  同步写指针到读时钟域
    always_ff @(posedge rclk or negedge rst_n) begin
        if (!rst_n) begin
            wptr_gray_sync1 <= 0;
            wptr_gray_sync2 <= 0;
        end else begin
            wptr_gray_sync1 <= wptr_gray;
            wptr_gray_sync2 <= wptr_gray_sync1;
        end
    end

    // 同步读指针到写时钟域
    always_ff @(posedge wclk or negedge rst_n) begin
        if (!rst_n) begin
            rptr_gray_sync1 <= 0;
            rptr_gray_sync2 <= 0;
        end else begin
            rptr_gray_sync1 <= rptr_gray;
            rptr_gray_sync2 <= rptr_gray_sync1;
        end
    end

    // full & empty
    assign empty = (rptr_gray == wptr_gray_sync2);
    assign full  = (wptr_gray == {~rptr_gray_sync2[ADDR_WIDTH:ADDR_WIDTH-1], rptr_gray_sync2[ADDR_WIDTH-2:0]});     //格雷码判满：最高位和次高位都不等

endmodule