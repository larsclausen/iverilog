// Check that it is an error to use a non constant expression as the repetition
// value in an assignment pattern.

module test;

  int x[];

  int r = 10;

  initial begin
    x = '{r{1, 2, 3}};
    $display("FAILED");
  end

endmodule
