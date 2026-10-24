// Check that constant functions convert signed X/Z values to real correctly.

module test;
  reg failed;

  function real convert;
    input signed [3:0] value;
    begin
      convert = value;
    end
  endfunction

  localparam real x_value = convert(4'b1x00);
  localparam real z_value = convert(4'b1z11);
  localparam real positive = convert(4'b0x11);
  localparam real unknown_sign = convert(4'bx111);

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
    `check(positive, 3.0);
    `check(unknown_sign, 7.0);
    if (!failed) begin
      $display("PASSED");
    end
  end
endmodule
