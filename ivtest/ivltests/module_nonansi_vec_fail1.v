// Check that it is possible to declare the data type for a vector type module
// port separately from the direction for non-ANSI style port declarations.
// declarations.

module test(x);
  output [3:0] x;
  reg [7:0] x;

  initial begin
    $display("FAILED");
  end

endmodule
