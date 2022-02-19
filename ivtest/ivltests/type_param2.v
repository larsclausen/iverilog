
module test #(
  parameter type T1 = int, T2 = real
);

  T1 x;
  T2 y;

  initial begin
    if ($bits(x) == $bits(int) &&
        $bits(T1) == $bits(int) &&
        y === 0.0) begin
      $display("PASSED");
    end else begin
      $display("FAILED");
    end
  end

endmodule
