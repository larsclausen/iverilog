

typedef reg [7:0] T1;
typedef T1 [3:0] T2;

module test(x);
  output T2 x;
  output T2 x;

  initial begin
    $display("FAILED");
  end

endmodule
