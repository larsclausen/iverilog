
typedef reg [7:0] T1;
typedef T1 [3:0] T2;

module test;

  task t;
    input [31:0] x;
    T2 x;
    $display("FAILED");
  endtask

  initial t(10);

endmodule
