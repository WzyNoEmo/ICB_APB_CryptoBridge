
module task_and_function;

bit b_function_define = 0;
bit b_task_define = 0;
bit b_inout_vs_ref = 1;

function int double_f0(int a);
  return 2*a;
endfunction

function void double_f1(input int a, output int b);
  b = 2*a;
endfunction

function void double_f2(inout int a);
  a = 2*a;
endfunction

function automatic void double_f3(ref int a);
  a = 2*a;
endfunction

task double_t1(input int a, output int b);
  b = 2*a;
endtask

task double_t2(inout int a);
  a = 2*a;
endtask

task automatic double_t3(ref int a);
  a = 2*a;
endtask

task double_t2_delay(inout int a);
  a = 2*a;
  #10ns;
endtask

task automatic double_t3_delay(ref int a);
  a = 2*a;
  #10ns;
endtask

// TODO-1 lear the function definition possible ways
initial begin: function_define
  int v1, v2;
  wait(b_function_define == 1); $display("b_function_define process block started");
  v1 = 10;
  v2 = double_f0(v1);
  $display("v1 = %0d, double function result is %0d", v1, v2);

  v1 = 10;
  double_f1(v1, v2);
  $display("v1 = %0d, double function result is %0d", v1, v2);

  v1 = 10;
  $display("v1 is %0d before calling double_f2(v1)", v1);
  double_f2(v1);
  $display("v1 is %0d (result) after calling double_f2(v1)", v1);

  v1 = 10;
  $display("v1 is %0d before calling double_f3(v1)", v1);
  double_f3(v1);
  $display("v1 is %0d (result) after calling double_f3(v1)", v1);
end

// TODO-2 learn the task definition possible ways
initial begin: task_define
  int v1, v2;
  wait(b_task_define == 1); $display("b_task_define process block started");
  v1 = 10;
  double_t1(v1, v2);
  $display("v1 = %0d, double task result is %0d", v1, v2);

  v1 = 10;
  $display("v1 is %0d before calling double_t2(v1)", v1);
  double_t2(v1);
  $display("v1 is %0d (result) after calling double_t2(v1)", v1);

  v1 = 10;
  $display("v1 is %0d before calling double_t3(v1)", v1);
  double_t3(v1);
  $display("v1 is %0d (result) after calling double_t3(v1)", v1);
end

// TODO-3 compare the inout and ref argument between function and task use
initial begin: inout_vs_ref
  int v1, v2;
  wait(b_inout_vs_ref == 1); $display("b_inout_vs_ref process block started");

  v1 = 10;
  $display("v1 is %0d before calling double_t2_delay(v1)", v1);
  fork
    double_t2_delay(v1);
    begin #5ns; $display("@%0t v1 = %0d in task call double_t2_delay(v1)", $time, v1); end
  join
  $display("v1 is %0d (result) after calling double_t2_delay(v1)", v1);

  v1 = 10;
  $display("v1 is %0d before calling double_t3_delay(v1)", v1);
  fork
    double_t3_delay(v1);
    begin #5ns; $display("@%0t v1 = %0d in task call double_t3_delay(v1)", $time, v1); end
  join
  $display("v1 is %0d (result) after calling double_t3_delay(v1)", v1);
end

endmodule
