// Check that package and type names can coexist in different namespaces.

package p;
  typedef int T;
endpackage

import p::*;

package T;
  parameter int VALUE = 23;
endpackage

module test;
  import T::VALUE;

  T value;
  reg failed;

  initial begin
    failed = 1'b0;
    value = VALUE;

    if (value !== 23) begin
      $display("FAILED(%0d). Package import or type lookup failed", `__LINE__);
      failed = 1'b1;
    end

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
