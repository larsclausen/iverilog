// Check that a class-scoped lookup does not fall back to a package or an outer value.

package C;
  parameter int VALUE = 42;
endpackage

module test;
  localparam int VALUE = 23;
  class C;
  endclass
  initial $display(C::VALUE); // Error: VALUE is not declared in C.
endmodule
