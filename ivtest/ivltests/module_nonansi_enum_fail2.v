// Check that it is not possible to declare a port again as a signal if the port
// as an explicit enum type.

typedef enum integer {
  A, B
} T;

module test(x);
  output T x;
  T x;

  initial begin
    $display("FAILED");
  end

endmodule
