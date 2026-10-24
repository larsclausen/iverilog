// Check that X/Z bits become zero before signed conversion to real.

module test;
  reg signed [3:0] value;
  wire real continuous_result = value;
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
    #1;
    `check(continuous_result, -8.0);
    value = 4'b1z11;
    #1;
    `check(continuous_result, -5.0);
    value = 4'b0x11;
    #1;
    `check(continuous_result, 3.0);
    if (!failed) begin
      $display("PASSED");
    end
  end
endmodule
