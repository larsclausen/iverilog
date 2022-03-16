

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
