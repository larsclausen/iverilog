// Check a typed constructor call with a package-scoped class type.

package p;
  class C;
    int value = 23;
  endclass
endpackage

module test;
  p::C object;

  initial begin
    object = p::C::new;

    if (object.value === 23) begin
      $display("PASSED");
    end else begin
      $display("FAILED");
    end
  end
endmodule
