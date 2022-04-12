
module test;

  task t;
    input [31:0] x;
    integer x;
    $display("FAILED");
  endtask

  initial t(10);

endmodule
