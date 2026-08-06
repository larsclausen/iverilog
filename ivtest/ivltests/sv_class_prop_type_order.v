// Check that class property types use normal declaration ordering.

module test;

  logic [3:0] a_later;
  logic [7:0] z_earlier;
  logic [2:0] inherited_name;

  bit failed = 1'b0;

  class C;
    // These names intentionally sort in the opposite order.
    logic [15:0] z_earlier;
    logic [$bits(z_earlier)-1:0] a_uses_earlier;
    logic [$bits(a_later)-1:0] z_uses_outer;
    logic [31:0] a_later;
  endclass

  class Base;
    logic [5:0] inherited_name;
  endclass

  // With no local declaration the inherited property is visible.
  class UsesBase extends Base;
    logic [$bits(inherited_name)-1:0] result;
  endclass

  // A later local declaration hides the inherited property before the local
  // declaration itself is visible, so the outer variable is used.
  class HidesBase extends Base;
    logic [$bits(inherited_name)-1:0] result;
    logic [11:0] inherited_name;
  endclass

  C object;
  UsesBase uses_base;
  HidesBase hides_base;

  initial begin
    object = new;
    uses_base = new;
    hides_base = new;

    if ($bits(object.a_uses_earlier) !== 16) begin
      $display("FAILED: earlier property width is %0d",
               $bits(object.a_uses_earlier));
      failed = 1'b1;
    end

    if ($bits(object.z_uses_outer) !== 4) begin
      $display("FAILED: outer variable width is %0d",
               $bits(object.z_uses_outer));
      failed = 1'b1;
    end

    if ($bits(uses_base.result) !== 6) begin
      $display("FAILED: inherited property width is %0d",
               $bits(uses_base.result));
      failed = 1'b1;
    end

    if ($bits(hides_base.result) !== 3) begin
      $display("FAILED: hidden base property width is %0d",
               $bits(hides_base.result));
      failed = 1'b1;
    end

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
