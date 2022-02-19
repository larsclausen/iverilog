
module test;

  parameter A = 10;
  localparam type T = logic [A-1:0];

  T x;

  initial begin
    if ($bits(T) == A && $bits(x) == A) begin
      $display("PASSED");
    end else begin
      $display("FAILED");
    end
  end

endmodule
