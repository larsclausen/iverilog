// Check that it is an error to use a float as the repetition value in an
// assignment pattern.

module test;

  int x[];

  initial begin
    x = '{3.5{1, 2, 3}};

    $display("FAILED");
  end

endmodule
