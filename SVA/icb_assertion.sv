//=====================================================================
// Description:
// This file realize assertion of icb ports
// Designer : wangziyao1@sjtu.edu.cn
// Revision History
// V0 date:2024/11/12 Initial version, wangziyao1@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

module icb_assertion (
    icb_bus.monitor   icb
);
    
    bit     cmd;

    always_ff @(icb.clk) begin
        if (icb.icb_cmd_valid && icb.icb_cmd_ready)
            cmd <= icb.icb_cmd_read;
        else
            cmd <= cmd;
    end

// Signal X Assertion
    property icb_cmd_valid_no_x_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        not ($isunknown(icb.icb_cmd_valid));
    endproperty

    property icb_cmd_ready_no_x_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        not ($isunknown(icb.icb_cmd_ready));
    endproperty

    property icb_cmd_addr_no_x_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        icb.icb_cmd_valid |-> (not ($isunknown(icb.icb_cmd_addr)));
    endproperty

    property icb_cmd_read_no_x_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        icb.icb_cmd_valid |-> (not ($isunknown(icb.icb_cmd_read)));
    endproperty

    property icb_cmd_wdata_no_x_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (icb.icb_cmd_valid && !icb.icb_cmd_read) |-> (not ($isunknown(icb.icb_cmd_wdata)));
    endproperty

    property icb_cmd_wmask_no_x_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (icb.icb_cmd_valid && !icb.icb_cmd_read) |-> (not ($isunknown(icb.icb_cmd_wmask)));
    endproperty

    property icb_rsp_valid_no_x_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        not ($isunknown(icb.icb_rsp_valid));
    endproperty

    property icb_rsp_ready_no_x_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        not ($isunknown(icb.icb_rsp_ready));
    endproperty

    property icb_rsp_rdata_no_x_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (icb.icb_rsp_valid && cmd) |-> (not ($isunknown(icb.icb_rsp_rdata)));
    endproperty

    property icb_rsp_err_no_x_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        icb.icb_rsp_valid |-> (not ($isunknown(icb.icb_rsp_err)));
    endproperty

    check_icb_cmd_valid_no_x: assert property (icb_cmd_valid_no_x_check) else $error($stime, "\t\t FATAL: icb_cmd_valid exists X!\n");
    check_icb_cmd_ready_no_x: assert property (icb_cmd_ready_no_x_check) else $error($stime, "\t\t FATAL: icb_cmd_ready exists X!\n");
    check_icb_cmd_addr_no_x: assert property (icb_cmd_addr_no_x_check) else $error($stime, "\t\t FATAL: icb_cmd_addr exists X!\n");
	check_icb_cmd_read_no_x: assert property (icb_cmd_read_no_x_check) else $error($stime, "\t\t FATAL: icb_cmd_read exists X!\n");
    check_icb_cmd_wdata_no_x: assert property (icb_cmd_wdata_no_x_check) else $error($stime, "\t\t FATAL: icb_cmd_wdata exists X!\n");
	check_icb_cmd_wmask_no_x: assert property (icb_cmd_wmask_no_x_check) else $error($stime, "\t\t FATAL: icb_cmd_wmask exists X!\n");
	check_icb_rsp_valid_no_x: assert property (icb_rsp_valid_no_x_check) else $error($stime, "\t\t FATAL: icb_rsp_valid exists X!\n");
	check_icb_rsp_ready_no_x: assert property (icb_rsp_ready_no_x_check) else $error($stime, "\t\t FATAL: icb_rsp_ready exists X!\n");
    check_icb_rsp_rdata_no_x: assert property (icb_rsp_rdata_no_x_check) else $error($stime, "\t\t FATAL: icb_rsp_rdata exists X!\n");
    check_icb_rsp_err_no_x: assert property (icb_rsp_err_no_x_check) else $error($stime, "\t\t FATAL: icb_rsp_err exists X!\n");

    
// Signals keep while valid and no handshake
    property icb_cmd_addr_keep_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (icb.icb_cmd_valid && !icb.icb_cmd_ready) |=>  $stable(icb.icb_cmd_addr);
    endproperty

	property icb_cmd_read_keep_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (icb.icb_cmd_valid && !icb.icb_cmd_ready) |=>  $stable(icb.icb_cmd_read);
    endproperty

	property icb_cmd_wmask_keep_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        ($past(icb.icb_cmd_valid && !icb.icb_cmd_ready) and !icb.icb_cmd_read) |->  $stable(icb.icb_cmd_wmask);
    endproperty
    
    property icb_cmd_wdata_keep_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        ($past(icb.icb_cmd_valid && !icb.icb_cmd_ready) and !icb.icb_cmd_read) |->  $stable(icb.icb_cmd_wdata);
    endproperty

    property icb_rsp_err_keep_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (icb.icb_rsp_valid && !icb.icb_rsp_ready) |=>  $stable(icb.icb_rsp_err);
    endproperty

	property icb_rsp_rdata_keep_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (icb.icb_rsp_valid && !icb.icb_rsp_ready && cmd) |=>  $stable(icb.icb_rsp_rdata);
        //(icb.icb_cmd_valid && icb.icb_cmd_ready && icb.icb_cmd_read) |-> ##[0:$] ($stable(icb.icb_rsp_rdata) throughout ($past(icb.icb_rsp_valid))[*0:$]);
    endproperty

    check_icb_cmd_addr_keep: assert property (icb_cmd_addr_keep_check) else $error($stime, "\t\t FATAL: icb_cmd_addr does not keep!\n");
    check_icb_cmd_read_keep: assert property (icb_cmd_read_keep_check) else $error($stime, "\t\t FATAL: icb_cmd_read does not keep!\n");
    check_icb_cmd_wmask_keep: assert property (icb_cmd_wmask_keep_check) else $error($stime, "\t\t FATAL: icb_cmd_wmask does not keep!\n");
    check_icb_cmd_wdata_keep: assert property (icb_cmd_wdata_keep_check) else $error($stime, "\t\t FATAL: icb_cmd_wdata does not keep!\n");
    check_icb_rsp_err_keep: assert property (icb_rsp_err_keep_check) else $error($stime, "\t\t FATAL: icb_rsp_err does not keep!\n");
    check_icb_rsp_rdata_keep: assert property (icb_rsp_rdata_keep_check) else $error($stime, "\t\t FATAL: icb_rsp_rdata does not keep!\n");

// Valid must keep before handshaking
    property icb_cmd_valid_keep_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (icb.icb_cmd_valid && !icb.icb_cmd_ready) |=> icb.icb_cmd_valid;
    endproperty 

    property icb_rsp_valid_keep_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (icb.icb_rsp_valid && !icb.icb_rsp_ready) |=> icb.icb_rsp_valid;
    endproperty
    
    check_icb_cmd_valid_keep: assert property (icb_cmd_valid_keep_check) else $error($stime, "\t\t FATAL: icb_cmd_valid does not keep!\n");
    check_icb_rsp_valid_keep: assert property (icb_rsp_valid_keep_check) else $error($stime, "\t\t FATAL: icb_rsp_valid does not keep!\n");

// Handshake
    property icb_cmd_handshake_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (($rose(icb.icb_cmd_valid)) or ($past(icb.icb_cmd_valid && icb.icb_cmd_ready) && icb.icb_cmd_valid)) |-> ##[0:$] icb.icb_cmd_valid && icb.icb_cmd_ready;
    endproperty

    property icb_rsp_handshake_check;
        @(posedge icb.clk) disable iff(!icb.rst_n)
        (($rose(icb.icb_rsp_valid)) or ($past(icb.icb_rsp_valid && icb.icb_rsp_ready) && icb.icb_rsp_valid)) |-> ##[0:$] icb.icb_rsp_valid && icb.icb_rsp_ready;
    endproperty

    check_icb_cmd_handshake: assert property (icb_cmd_handshake_check) else $error($stime, "\t\t FATAL: ICB CMD Channel does not handshake!\n");
    check_icb_rsp_handshake: assert property (icb_rsp_handshake_check) else $error($stime, "\t\t FATAL: ICB RSP Channel does not handshake!\n");
    
endmodule