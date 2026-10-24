// Check that constant conversions to real treat individual X/Z bits as zero.

module test;
  localparam real x_value = 4'sb1x00;
  localparam real z_value = 4'sb1z11;
  localparam real positive = 4'sb0x11;
  localparam real x_sign = 4'sbx111;
  localparam real z_sign = 4'sbz111;
  localparam real all_x = 4'sbxxxx;
  localparam real all_z = 4'sbzzzz;
  localparam real unsigned_value = 4'b1x11;
  localparam real defined_value = 4'sb1011;
  localparam real wide_value = 65'sh1_0000_0000_0000_000x;
  localparam real mixed_value = 4'sb1x00 + 1.0;
  localparam real itor_value = $itor(4'sb1z11);
  localparam real floor_value = $floor(4'sb1x00);
  reg failed;

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
    `check(x_sign, 7.0);
    `check(z_sign, 7.0);
    `check(all_x, 0.0);
    `check(all_z, 0.0);
    `check(unsigned_value, 11.0);
    `check(defined_value, -5.0);
    `check(wide_value, -18446744073709551616.0);
    `check(mixed_value, -7.0);
    `check(itor_value, -5.0);
    `check(floor_value, -8.0);
    if (!failed) begin
      $display("PASSED");
    end
  end
endmodule
