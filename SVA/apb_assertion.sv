//=====================================================================
// Description:
// This file realize assertion of icb ports
// Designer : wangziyao1@sjtu.edu.cn
// Revision History
// V0 date:2024/12/21 Initial version, wangziyao1@sjtu.edu.cn
//=====================================================================

`timescale 1ns/1ps

module apb_assertion #(
    parameter channel_id = 0
)
(
    apb_bus.monitor   apb
);

    bit     cmd;

    always_ff @(apb.clk) begin
        if (apb.penable)
            cmd <= apb.pwrite;
        else
            cmd <= cmd;
    end

// Signal X Assertion
    property pwrite_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        apb.psel |-> (not ($isunknown(apb.pwrite)));
    endproperty
    
    property psel_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        not ($isunknown(apb.psel));
    endproperty

    property paddr_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        apb.psel |-> (not ($isunknown(apb.paddr)));
    endproperty

    property pwdata_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.psel && apb.pwrite) |-> (not ($isunknown(apb.pwdata)));
    endproperty

    property penable_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        apb.psel |=> (not ($isunknown(apb.penable)));
    endproperty

    property prdata_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.pready && !cmd) |-> (not ($isunknown(apb.prdata)));
    endproperty

    property pready_no_x_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        not ($isunknown(apb.pready));
    endproperty
    
    check_psel_no_x: assert property (psel_no_x_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: psel exists X!\n", channel_id);
    check_pwrite_no_x: assert property (pwrite_no_x_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: pwrite exists X!\n", channel_id);
    check_paddr_no_x: assert property (paddr_no_x_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: paddr exists X!\n", channel_id);
    check_pwdata_no_x: assert property (pwdata_no_x_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: pwdata exists X!\n", channel_id);
    check_penable_no_x: assert property (penable_no_x_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: penable exists X!\n", channel_id);
    check_prdata_no_x: assert property (prdata_no_x_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: prdata exists X!\n", channel_id);
    check_pready_no_x: assert property (pready_no_x_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: pready exists X!\n", channel_id);

// Signals keep while valid and no handshake
    property paddr_keep_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.psel && !apb.pready) |=> $stable(apb.paddr);
    endproperty

    property pwrite_keep_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.psel && !apb.pready) |=> $stable(apb.pwrite);
    endproperty

    property pwdata_keep_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        ($past(apb.psel && !apb.pready) && apb.pwrite) |-> $stable(apb.pwdata);
    endproperty

    check_paddr_keep: assert property (paddr_keep_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: paddrdoes not keep!\n", channel_id);
    check_pwrite_keep: assert property (pwrite_keep_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: pwrite does not keep!\n", channel_id);
    check_pwdata_keep: assert property (pwdata_keep_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: pwdata does not keep!\n", channel_id);

// Handshake
    property apb_handshake_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.psel && apb.penable) |-> ##[0:$] (apb.psel && apb.penable && apb.pready);
    endproperty

    check_apb_handshake: assert property (apb_handshake_check) else $error($stime, "\t\t APB CHANNEL %0d FATAL: apb does not handshake!\n", channel_id);

// penable and pready must pull low after handshake
    property penable_after_handshake_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.penable && apb.pready) |=> (!apb.penable);
    endproperty

    property pready_after_handshake_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        (apb.penable && apb.pready) |=> (!apb.pready);
    endproperty

    check_penable_after_handshake: assert property (penable_after_handshake_check) 
    else $error($stime, "\t\t APB CHANNEL %0d FATAL: penable is not low after handshaking!\n", channel_id);

    check_pready_after_handshake: assert property (pready_after_handshake_check) 
    else $error($stime, "\t\t APB CHANNEL %0d FATAL: pready is not low after handshaking!\n", channel_id);

// psel must be high one cycle before penable is pulled high
    property psel_before_penable_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        $rose(apb.penable) |-> $past(apb.psel);
    endproperty

    check_psel_before_penable: assert property (psel_before_penable_check) 
    else $error($stime, "\t\t APB CHANNEL %0d FATAL: psel is not high one cycle before penable!\n", channel_id);

// penable must be high one cycle after psel is pulled high
    property penable_after_psel_check;
        @(posedge apb.clk) disable iff(!apb.rst_n)
        $rose(apb.psel) |=> apb.penable;
    endproperty

    check_penable_after_psel: assert property (penable_after_psel_check) 
    else $error($stime, "\t\t APB CHANNEL %0d FATAL: penable is not high one cycle after psel!\n", channel_id);

endmodule