// Check that foreach can resolve arrays in compilation-unit scope.

reg [31:0] A[0:1];

module test;

  reg failed;

  `define check(val, exp) \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %0d, got %0d", `__LINE__, \
               `"val`", exp, val); \
      failed = 1'b1; \
    end

  initial begin
    failed = 1'b0;

    foreach (A[i]) begin
      A[i] = i + 1;
    end

    `check(A[0], 1);
    `check(A[1], 2);

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
