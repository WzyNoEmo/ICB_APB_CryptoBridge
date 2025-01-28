package subscriber_pkg;
    import uvm_pkg::*;
    import sequence_pkg::*;
    `include "uvm_macros.svh"

class icb_subscriber extends uvm_subscriber #(icb_trans);

    `uvm_component_utils(icb_subscriber)

    bit read;
    bit [31:0] addr;
    bit [63:0] wdata;
    bit [63:0] rdata;

    covergroup icb_bus;
        option.per_instance = 1;

        cov_icb_mode: coverpoint read {
            bins read = {1'b1};
            bins write = {1'b0};
        }   

        cov_icb_addr: coverpoint addr {
            bins ctrl_read  = {32'h2000_0000} iff (read == 1'b1);
            bins state_read = {32'h2000_0008} iff (read == 1'b1);
            bins wdata_read = {32'h2000_0010} iff (read == 1'b1);
            bins rdata_read = {32'h2000_0018} iff (read == 1'b1);
            bins key_read   = {32'h2000_0020} iff (read == 1'b1);
            bins wrong_read = {[32'h2000_0021:32'hFFFF_FFFF]} iff (read == 1'b1);

            bins ctrl_write  = {32'h2000_0000} iff (read == 1'b0);
            bins state_write = {32'h2000_0008} iff (read == 1'b0);
            bins wdata_write = {32'h2000_0010} iff (read == 1'b0);
            bins rdata_write = {32'h2000_0018} iff (read == 1'b0);
            bins key_write   = {32'h2000_0020} iff (read == 1'b0);
            bins wrong_write = {[32'h2000_0021:32'hFFFF_FFFF]} iff (read == 1'b0);
        }
        
        cov_icb_start_apb: coverpoint wdata[0] {
            bins start = {1'b1} iff ((read == 1'b0) && (addr == 32'h2000_0000));
            bins stop = {1'b0} iff ((read == 1'b0) && (addr == 32'h2000_0000));
        }
    endgroup : icb_bus

    function new(string name, uvm_component parent);
        super.new(name, parent);
        icb_bus = new();
    endfunction : new

    function void write(icb_trans t);
            read = t.read;                  
            addr = t.addr;
            wdata = t.wdata;
            rdata = t.rdata;
            icb_bus.sample();
    endfunction : write

endclass : icb_subscriber

class apb_subscriber extends uvm_subscriber #(apb_trans);

    `uvm_component_utils(apb_subscriber)

    bit apb_write;
    bit [31:0] addr;
    bit [31:0] wdata;
    bit [31:0] rdata;

    covergroup apb_bus;
        option.per_instance = 1;

        cov_apb_mode: coverpoint apb_write {
            bins channel_read = {1'b0};
            bins channel_write = {1'b1};
        }

        cov_apb_resp: coverpoint rdata {
            bins channel_resp = {[32'h0000_0000:32'hFFFF_FFFF]};
        }

    endgroup : apb_bus

    function new(string name, uvm_component parent);
        super.new(name, parent);
        apb_bus = new();
    endfunction : new

    function void write(apb_trans t);
        apb_write = t.write;                  
        addr = t.addr;
        wdata = t.wdata;
        rdata = t.rdata;
        apb_bus.sample();
    endfunction : write

endclass : apb_subscriber

endpackage : subscriber_pkg