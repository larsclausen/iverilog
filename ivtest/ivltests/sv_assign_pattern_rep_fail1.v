// Check that it is an error to use zero as the repetition value in an
// assignment pattern.

module test;

  int x[];

  initial begin
    x = '{0{1, 2, 3}};
    $display("FAILED");
  end

endmodule
