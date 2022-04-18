// Check that it is an error to have a non-ansi port

typedef enum integer {
  A, B
} T;

module test(x);
  output [31:0] x;
  T x;

  initial begin
    $display("FAILED");
  end

endmodule
