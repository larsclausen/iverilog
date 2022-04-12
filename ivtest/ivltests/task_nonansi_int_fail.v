// Check that 

module test;

  task t;
    input [15:0] x;
    shortint x;
    $display("FAILED");
  endtask

  initial t(10);

endmodule
