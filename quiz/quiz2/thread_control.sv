
module thread_control;

bit b_fork_join = 1;
bit b_fork_join_any = 0;
bit b_fork_join_none = 0;

class box;
  int id;
  function new(int id);
    this.id = id;
  endfunction
endclass

box bx[3];

task automatic thread(int id = 1, int t = 10);
  $display("@%0t, thread id:%0d entered", $time, id);
  bx[id] = new(id); // allocate space
  #(t*1ns);
  bx[id] = null; // deallocate space
  $display("@%0t, thread id:%0d exited", $time, id);
endtask

// TODO-1 learn fork-join thread exited when all sub-thread exit.
initial begin: fork_join
  wait(b_fork_join == 1); $display("b_fork_join process block started");
  bx = '{null, null, null};
  $display("@%0t, fork_join_thread entered", $time);
  fork: fork_join_thread
    thread(0, 10);
    thread(1, 20);
    thread(2, 30);
  join
  $display("@%0t, fork_join_thread exited", $time);
  $display("@%0t, box handles array is %p", $time, bx);

  #10;
  b_fork_join = 0;
  b_fork_join_any = 1;
end

// TODO-2.1 learn fork-join_any thread exited when just one sub-thread exites,
// but all other sub-thread are still running.
// TODO-2.2 learn disable BLOCK/fork statement, and check if the running
// sub-threads haven been disabled.
initial begin: fork_join_any
  wait(b_fork_join_any == 1); $display("b_fork_join_any process block started");
  bx = '{null, null, null};
  $display("@%0t, fork_join_any_thread entered", $time);
  fork: fork_join_any_thread
    thread(0, 10);
    thread(1, 20);
    thread(2, 30);
  join_any 
  $display("@%0t, fork_join_any_thread exited", $time);
  $display("@%0t, box handles array is %p", $time, bx);
  disable fork_join_any_thread;
  $display("@%0t, disabled fork_join_any_thread", $time);
  #100ns;
  $display("@%0t, box handles array is %p", $time, bx);

  #10ns;
  b_fork_join_any = 0;
  b_fork_join_none = 1;
end

// TODO-3.1 learn fork-join_none thread exited directly without calling any
// sub-thread, and continue executing other statements. Then the
// fork-join_none sub-threads would be still running.
// TODO-3.2 learn the wait fork statement, and check the time after it is
// satisified. The time should be the point when all fork sub-thread finished.
initial begin: fork_join_none
  wait(b_fork_join_none == 1); $display("b_fork_join_none process block started");
  bx = '{null, null, null};
  $display("@%0t, fork_join_none_thread entered", $time);
  fork: fork_join_none_thread
    thread(0, 10);
    thread(1, 20);
    thread(2, 30);
  join_none
  $display("@%0t, fork_join_none_thread exited", $time);
  $display("@%0t, box handles array is %p", $time, bx);
  #15ns;
  $display("@%0t, box handles array is %p", $time, bx);
  wait fork;
  $display("@%0t, fork_join_none_thread's all sub-threads finished", $time);
  $display("@%0t, box handles array is %p", $time, bx);
end


endmodule
