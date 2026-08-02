// Check that class parameters are inherited and take precedence over names in
// the enclosing scope. Check unqualified, super-qualified, this-qualified, and
// object-qualified references. Check that lookup in the derived class still
// follows lexical declaration order.

module test;

  localparam int VALUE = 8;
  localparam int LIMIT = 9;
  localparam int ORDER = 10;

  bit failed = 1'b0;

  `define check(val, exp) do \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %0d, got %0d", `__LINE__, `"val`", exp, val); \
      failed = 1'b1; \
    end \
  while(0)

  class Base;
    parameter int VALUE = 16;
    localparam int LIMIT = 17;
  endclass

  class Middle extends Base;
  endclass

  class Derived extends Middle;
    function int get_value;
      return VALUE;
    endfunction

    function int get_limit;
      return this.LIMIT;
    endfunction

    function int get_super_value;
      return super.VALUE;
    endfunction
  endclass

  class Shadowed extends Base;
    int VALUE;

    function int get_value;
      return VALUE;
    endfunction
  endclass

  class Ordered extends Base;
    function int get_before;
      return ORDER;
    endfunction

    localparam int ORDER = 24;

    function int get_after;
      return ORDER;
    endfunction
  endclass

  Derived obj;
  Shadowed shadowed;
  Ordered ordered;

  initial begin
    obj = new;
    shadowed = new;
    ordered = new;
    shadowed.VALUE = 23;

    `check(obj.get_value(), 16);
    `check(obj.get_limit(), 17);
    `check(obj.get_super_value(), 16);
    `check(obj.VALUE, 16);
    `check(obj.LIMIT, 17);
    `check(shadowed.get_value(), 23);
    `check(ordered.get_before(), 10);
    `check(ordered.get_after(), 24);

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
