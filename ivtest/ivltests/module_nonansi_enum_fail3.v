// Check that it is not possible to declare a port with an explicit type for a
// signal that that has already been declared with an enum type.

typedef enum integer {
  A, B
} T;

module test(x);
  T x;
  output T x;

  initial begin
    $display("FAILED");
  end

endmodule
