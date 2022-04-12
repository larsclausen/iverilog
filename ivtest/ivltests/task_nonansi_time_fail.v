
module test;

  task t;
    input [63:0] x;
    time x;
    $display("FAILED");
  endtask

  initial t(10);

endmodule
