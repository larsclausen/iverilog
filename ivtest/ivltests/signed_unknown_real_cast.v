// Check that real casts treat signed X/Z values consistently at compile time and runtime.

module test;
  localparam real x_value = real'(4'sb1x00);
  localparam real z_value = real'(4'sb1z11);
  reg signed [3:0] value;
  real result;
  reg failed;

  function real convert(input signed [3:0] value);
    convert = real'(value);
  endfunction

  localparam real function_value = convert(4'sb1x00);

  `define check(val, exp) \
    if (val != exp) begin \
      $display("FAILED(%0d). '%s' expected %g, got %g", `__LINE__, \
               `"val`", exp, val); \
      failed = 1'b1; \
    end

  initial begin
    failed = 1'b0;
    `check(x_value, -8.0);
    `check(z_value, -5.0);
    `check(function_value, -8.0);
    value = 4'b1x00;
    result = real'(value);
    `check(result, -8.0);
    value = 4'b1z11;
    result = real'(value);
    `check(result, -5.0);
    if (!failed) begin
      $display("PASSED");
    end
  end
endmodule
