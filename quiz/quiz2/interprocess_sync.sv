
module interprocess_sync;

bit b_event_use = 0;
bit b_mailbox_use = 0;
bit b_mailbox_user_define = 1;

// TODO-1.1 event does not new()
// TODO-1.2 learn event copy (direct assignment between two events)
// TODO-1.3 compare @ operator and triggered() method
initial begin: event_use
  event e1, e2, e3a, e3b;
  wait(b_event_use == 1); $display("b_event_use process block started");
  e3b = e3a; // event copy, e3b and e3a are the same event

  ->e1; // trigger e1 before @e1;
  ->e2; // trigger e2 before e2.triggered();

  fork
    begin @e1;  $display("@%0t, @e1 finished" , $time); end
    begin wait(e2.triggered());  $display("@%0t, wait(e2.triggered()) finished" , $time); end
    begin @e3a; $display("@%0t, @e3a finished", $time); end
    begin @e3b; $display("@%0t, @e3b finished", $time); end
  join_none

  #10ns;
  -> e3a;
  
  #10ns;
  -> e1; // trigger e1 again
end

class box;
  int id;
  function new(int id);
    this.id = id;
  endfunction
endclass

// TODO-2 learn the parameterized mailbox and general storage method
initial begin: mailbox_use
  mailbox #(int) mb_id;
  mailbox #(box) mb_handle;
  box bx[5];
  wait(b_mailbox_use == 1); $display("b_mailbox_use process block started");
  // mailbox need new(N) for instantiation
  mb_id = new();
  mb_handle = new();
  // mailbox storage
  foreach(bx[i]) begin
    bx[i] = new(i);
    mb_id.put(i);
    mb_handle.put(bx[i]);
  end
  $display("box handles array bx content is %p", bx);
  // mailbox extraction
  $display("extracting ID and HANDLE from the TWO mailboxes");
  repeat(mb_id.num()) begin
    int id;
    box handle;
    mb_id.get(id);
    mb_handle.get(handle);
    $display("ID:%0d, HANDLE:%p", id, handle);
  end
  // check mailbox size
  $display("ID mailbox size is %0d", mb_id.num());
  $display("HANDLE mailbox size is %0d", mb_handle.num());
end

// TODO-3 learn how to maximal utilize the mailbox storage with user defined
// type, we modify the 'mailbox_use' block and give a new block
// 'mailbox_user_define'
typedef struct{
  int id;
  box handle;
} mb_pair_element_t;

initial begin: mailbox_user_define
  mailbox #(mb_pair_element_t) mb_pair;
  box bx[5];
  wait(b_mailbox_user_define == 1); $display("b_mailbox_user_define process block started");
  // mailbox need new(N) for instantiation
  mb_pair = new();
  // mailbox storage
  foreach(bx[i]) begin
    bx[i] = new(i);
    mb_pair.put('{i, bx[i]});
  end
  $display("box handles array bx content is %p", bx);
  // mailbox extraction
  $display("extracting ID and HANDLE from the ONE mailbox");
  repeat(mb_pair.num()) begin
    mb_pair_element_t pair;
    mb_pair.get(pair);
    $display("ID:%0d, HANDLE:%p", pair.id, pair.handle);
  end
  // check mailbox size
  $display("PAIR mailbox size is %0d", mb_pair.num);
end


endmodule
