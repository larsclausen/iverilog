// Check that a visible non-class type prevents package fallback.

package C;
  parameter int VALUE = 1;
endpackage

module test;
  typedef int C;
  initial $display(C::VALUE); // Error: C resolves to a non-class type.
endmodule
