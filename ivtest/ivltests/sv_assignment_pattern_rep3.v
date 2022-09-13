
module test;

  `define check(val, exp) \
    if (val != exp) begin \
      $display("FAILED(%0d): %s, expected %0h got %0h", `__LINE__, `"val`", exp, val); \
      failed = 1'b1; \
    end


  bit failed;

  int x[$];
  real y[$];
  string z[$];
  int i = 3;
  string s;

  initial begin
    x = '{3{1, 2, i++}};
    y = '{3{1.0, 2.0, 3.0}};
    z = '{3{"a", "b", "c"}};

    `check(i, 4)
    `check(x.size(), 9)
    `check(y.size(), 9)
    `check(z.size(), 9)

    foreach (x[i]) begin
      `check(x[i], 1 + (i % 3))
    end

    foreach (y[i]) begin
      `check(y[i], 1.0 + (i % 3))
    end

    foreach (z[i]) begin
      s = z[i];
      `check(s[0], "a" + (i % 3))
    end

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
