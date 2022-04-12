

typedef enum integer {
  A, B
} T;

module test;

  task t;
    input [31:0] x;
    T x;
    $display("FAILED");
  endtask

  initial t(10);

endmodule
