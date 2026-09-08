// Check that a visible variable prevents package fallback.

package C;
  parameter int VALUE = 1;
endpackage

module test;
  int C;
  initial $display(C::VALUE); // Error: C resolves to a variable, not a class type.
endmodule
