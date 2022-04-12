// Check that it is possible to declare the data type for a vector type task
// port separately from the direction for non-ANSI style port declarations.

module test;

  task t;
    input [7:0] x;
    reg [3:0] x;
    $display("FAILED");
  endtask

  initial begin
    t(10);
  end

endmodule
