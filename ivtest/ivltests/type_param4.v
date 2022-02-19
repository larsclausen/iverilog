
module test #(
  parameter A = 10,
  localparam type T1 = logic [A-1:0]
);

  T1 x;

  initial begin
    if ($bits(x) == A &&
        $bits(T1) == A) begin
      $display("PASSED");
    end else begin
      $display("FAILED");
    end
  end

endmodule
