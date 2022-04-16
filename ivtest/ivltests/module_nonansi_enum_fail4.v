// Check that it is not possible to declare a port of the same name multiple
// types if the port has an enum type.

typedef enum integer {
  A, B
} T;

module test(x);
  output T x;
  output T x;

  initial begin
    $display("FAILED");
  end

endmodule
