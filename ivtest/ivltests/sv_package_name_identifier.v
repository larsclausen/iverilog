// Check that package names can also be used as ordinary identifiers.

package values;
  logic [7:0] p = 23;
  logic [7:0] \q = 24;
endpackage

package p;
  parameter int VALUE = 42;
endpackage

package \q ;
  parameter int VALUE = 43;
endpackage

module test;
  reg failed;

  `define check(expr, value) \
    if (expr !== value) begin \
      $display("FAILED(%0d). '%s' expected %0d, got %0d", `__LINE__, \
               `"expr`", value, expr ); \
      failed = 1'b1; \
    end

  initial begin
    failed = 1'b0;
    begin : imported_values
      import values::*;
      `check(p, 23)
      `check(\q , 24)
    end
    `check(p::VALUE, 42)
    `check(\q ::VALUE, 43)
    if (!failed) $display("PASSED");
  end
endmodule
