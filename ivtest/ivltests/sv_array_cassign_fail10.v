// Check that it is an error if the element type is not the same in a
// continuous array assignment, even if the difference is just 2-state vs.
// 4-state.

module test;

  wire integer  x[1:0];
  enum integer {
    A
  } y[1:0];

  assign x = y;

endmodule
