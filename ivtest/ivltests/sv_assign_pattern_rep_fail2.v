// Check that it is an error to use a negative value as the repetition value in
// an assignment pattern.

module test;

  int x[];

  initial begin
    x = '{-1{1, 2, 3}};
    $display("FAILED");
  end

endmodule
