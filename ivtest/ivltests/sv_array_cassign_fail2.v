// Check that it is an error if the element type is not the same in a
// continuous array assignment.

module test;

  wire [1:0] x[2:0];
  reg [1:0] y[1:0];

  assign x = y;

endmodule
