
module test;

  task t;
    input [3:0] x;
    real x;
    $display("FAILED");
  endtask

  initial t(10);

endmodule
