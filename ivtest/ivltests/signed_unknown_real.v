// Check that X/Z bits become zero before signed conversion to real.

module test;
  reg signed [3:0] value;
  real result;
  reg failed;

  `define check(val, exp) \
    if (val != exp) begin \
      $display("FAILED(%0d). '%s' expected %g, got %g", `__LINE__, \
               `"val`", exp, val); \
      failed = 1'b1; \
    end

  initial begin
    failed = 1'b0;
    value = 4'b1x00;
    result = value;
    #1;
    `check(result, -8.0);
    `check($floor(value), -8.0);
    value = 4'b1z11;
    result = value;
    #1;
    `check(result, -5.0);
    `check($floor(value), -5.0);
    value = 4'b0x11;
    result = value;
    #1;
    `check(result, 3.0);
    `check($floor(value), 3.0);
    if (!failed) begin
      $display("PASSED");
    end
  end
endmodule
