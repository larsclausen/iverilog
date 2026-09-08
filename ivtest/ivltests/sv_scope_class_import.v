// Check that a class scope prefix activates a wildcard-imported class.

package p;
  class C;
    typedef logic [7:0] T;
    localparam int VALUE = 23;
  endclass
endpackage

module test;
  import p::*;
  C::T value;
  initial begin
    value = C::VALUE;
    if (value === 8'd23) $display("PASSED");
    else $display("FAILED");
  end
endmodule
