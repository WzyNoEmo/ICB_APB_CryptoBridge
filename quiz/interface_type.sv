
// TODO-1 understand how the interface is defined and instantied
// TODO-2 check how to define methods inside interface and call them internally or externally
// TODO-3 understand how to prepare transactions, drive them and monitor them
module interface_type;
  typedef struct {
    bit[7:0] addr;
    bit[31:0] data;
    bit write;
    int id;
  } trans_t;

  // struct print utility function
  function void trans_print(trans_t t, string name = "trans");
    string s;
    s  = $sformatf("%s struct content is as below \n", name);
    s  = $sformatf("%s\taddr  = 'h%2x \n", s, t.addr);
    s  = $sformatf("%s\tdata  = 'h%8x \n", s, t.data);
    s  = $sformatf("%s\twrite = 'b%0b \n", s, t.write);
    s  = $sformatf("%s\tid    = 'h%8x \n", s, t.id);
    $display("%s", s);
  endfunction

  interface intf1;
    logic [7:0] addr;
    logic [31:0] data;
    logic write;
    int id;

    // transaction drive task
    task drive_trans(trans_t t);
      addr  <= t.addr ;
      data  <= t.data ;
      write <= t.write;
      id    <= t.id   ;
    endtask

    // transaction monitor task
    task mon_trans(output trans_t t);
      t.addr  = addr ;
      t.data  = data ;
      t.write = write;
      t.id    = id   ;
    endtask
  endinterface

  // interface instantiation
  intf1 if1();

  initial begin
    trans_t trans_in[3], trans_mon[3];
    // stimulus preparation
    trans_in = '{'{'h10, 'h1122_3344, 'b1, 'h1000}
                ,'{'h14, 'h5566_7788, 'b0, 'h1001}
                ,'{'h18, 'h99AA_BBCC, 'b1, 'h1002}
                };                                      //////////// 草！！！！双重聚合赋值！！！！！！！！帅！！！！！！！！
    foreach(trans_in[i]) begin
      #10;
      // stimulus drive
      if1.drive_trans(trans_in[i]);
      trans_print(trans_in[i], $sformatf("trans_in[%0d]",i));
      #10;
      // stimulus monitor
      if1.mon_trans(trans_mon[i]);
      trans_print(trans_mon[i], $sformatf("trans_mon[%0d]",i));

      // transaction comparison
      if(trans_in[i] === trans_mon[i])
        $display("trans_in[%0d] === trans_mon[%0d]", i, i);
      else
        $error("trans_in[%0d] !== trans_mon[%0d]", i, i);
    end
  end

endmodule
