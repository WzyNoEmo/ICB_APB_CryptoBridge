//=====================================================================
// Description:
// This file realize assertion of icb ports
// Designer : wangziyao1@sjtu.edu.cn
// Revision History
// V0 date:2024/12/26 Initial version, wangziyao1@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

module fifo_assertion #(
    parameter fifo_type = 0
)
(
    input logic rclk,
    input logic wclk,
    input logic rst_n,
    input logic empty,
    input logic full,
    input logic [3:0] wptr,
    input logic [3:0] rptr,
    input logic [3:0] wptr_gray,
    input logic [3:0] rptr_gray,
    input logic [3:0] wptr_gray_sync1,
    input logic [3:0] wptr_gray_sync2,
    input logic [3:0] rptr_gray_sync1,
    input logic [3:0] rptr_gray_sync2,
    input logic rdata_en,
    input logic wdata_vld
);

    function logic [3:0] bin2gray(input logic [3:0] bin);
        return (bin >> 1) ^ bin;
    endfunction

// empty and full assertion

    // 弱比较条件：fifo为空时,empty信号一定拉高；但empty信号拉高时，fifo不一定为空，可能有异步的delay

    property fifo_empty_check;
        @(posedge rclk) disable iff(!rst_n)
        rptr == wptr |-> empty;
    endproperty

    property fifo_full_check;
        @(posedge wclk) disable iff(!rst_n)
        ((wptr[2:0] == rptr[2:0]) && (wptr[3]!=rptr[3])) |-> full;
    endproperty

    check_fifo_empty: assert property (fifo_empty_check) else begin
        if(!fifo_type) $error("FATAL : RFIFO empty check failed");
        else $error("FATAL : WFIFO empty check failed");
    end
    check_fifo_full: assert property (fifo_full_check) else begin
        if(!fifo_type) $error("FATAL : RFIFO full check failed");
        else $error("FATAL : WFIFO full check failed");
    end

// wr and rd function assertion

    property fifo_rd_function_check;
        @(posedge rclk) disable iff(!rst_n)
        rdata_en |=> rptr == ($past(rptr)+1);
    endproperty

    property fifo_wr_function_check;
        @(posedge wclk) disable iff(!rst_n)
        wdata_vld |=> wptr == ($past(wptr)+1);
    endproperty
    
    check_fifo_wr_function: assert property (fifo_rd_function_check) else begin
        if(!fifo_type) $error("FATAL : RFIFO read data error");
        else $error("FATAL : WFIFO read data error");
    end
    check_fifo_rd_function: assert property (fifo_wr_function_check) else begin
        if(!fifo_type) $error("FATAL : RFIFO write data error");
        else $error("FATAL : WFIFO write data error");
    end

// gray code assertion

    property fifo_rptr_gray_code_check;
        @(posedge rclk) disable iff(!rst_n)
        (rptr!=($past(rptr))) |-> (rptr_gray == bin2gray(rptr));
    endproperty

    property fifo_rptr_gray_code_sync1_check;
        @(posedge rclk) disable iff(!rst_n)
        (rptr_gray!=($past(rptr_gray))) |=> (rptr_gray_sync1 == ($past(rptr_gray)));
    endproperty

    property fifo_rptr_gray_code_sync2_check;
        @(posedge rclk) disable iff(!rst_n)
        (rptr_gray_sync1!=($past(rptr_gray_sync1))) |=> (rptr_gray_sync2 == ($past(rptr_gray_sync1)));
    endproperty

    property fifo_wptr_gray_code_check;
        @(posedge wclk) disable iff(!rst_n)
        (wptr!=($past(wptr))) |-> (wptr_gray == bin2gray(wptr));
    endproperty

    property fifo_wptr_gray_code_sync1_check;
        @(posedge wclk) disable iff(!rst_n)
        (wptr_gray!=($past(wptr_gray))) |=> (wptr_gray_sync1 == ($past(wptr_gray)));
    endproperty

    property fifo_wptr_gray_code_sync2_check;
        @(posedge wclk) disable iff(!rst_n)
        (wptr_gray_sync1!=($past(wptr_gray_sync1))) |=> (wptr_gray_sync2 == ($past(wptr_gray_sync1)));
    endproperty

    check_fifo_rptr_gray_code: assert property (fifo_rptr_gray_code_check) else begin
        if(!fifo_type) $error("FATAL : RFIFO rptr gray code error");
        else $error("FATAL : WFIFO rptr gray code error");
    end

    check_fifo_rptr_gray_code_sync1: assert property (fifo_rptr_gray_code_sync1_check) else begin
        if(!fifo_type) $error("FATAL : RFIFO rptr gray code sync1 error");
        else $error("FATAL : WFIFO rptr gray code sync1 error");
    end

    check_fifo_rptr_gray_code_sync2: assert property (fifo_rptr_gray_code_sync2_check) else begin
        if(!fifo_type) $error("FATAL : RFIFO rptr gray code sync2 error");
        else $error("FATAL : WFIFO rptr gray code sync2 error");
    end

    check_fifo_wptr_gray_code: assert property (fifo_wptr_gray_code_check) else begin
        if(!fifo_type) $error("FATAL : RFIFO wptr gray code error");
        else $error("FATAL : WFIFO wptr gray code error");
    end

    check_fifo_wptr_gray_code_sync1: assert property (fifo_wptr_gray_code_sync1_check) else begin
        if(!fifo_type) $error("FATAL : RFIFO wptr gray code sync1 error");
        else $error("FATAL : WFIFO wptr gray code sync1 error");
    end

    check_fifo_wptr_gray_code_sync2: assert property (fifo_wptr_gray_code_sync2_check) else begin
        if(!fifo_type) $error("FATAL : RFIFO wptr gray code sync2 error");
        else $error("FATAL : WFIFO wptr gray code sync2 error");
    end


endmodule