
module test #(
  type T1 = int
);

  T1 x;

  initial begin
    if ($bits(x) == $bits(int) &&
        $bits(T1) == $bits(int)) begin
      $display("PASSED");
    end else begin
      $display("FAILED");
    end
  end

endmodule
