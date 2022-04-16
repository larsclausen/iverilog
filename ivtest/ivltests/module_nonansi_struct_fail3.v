

typedef struct packed {
  reg [31:0] x;
  reg [7:0] y;
} T;


module test(x);
  T x;
  output T x;

  initial begin
    $display("FAILED");
  end

endmodule
