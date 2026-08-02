// Check that inherited class enum literals take precedence over names in the
// enclosing scope. Check unqualified, super-qualified, this-qualified, and
// object-qualified references.

module test;

  localparam int VALUE = 8;
  localparam int LIMIT = 9;

  bit failed = 1'b0;

  `define check(val, exp) do \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %0d, got %0d", `__LINE__, `"val`", exp, val); \
      failed = 1'b1; \
    end \
  while(0)

  class Base;
    typedef enum int {
      VALUE = 18,
      LIMIT = 19
    } value_t;
  endclass

  class Middle extends Base;
  endclass

  class Derived extends Middle;
    logic [VALUE-1:0] value;

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

  Derived obj;

  initial begin
    obj = new;

    `check(obj.get_value(), 18);
    `check(obj.get_limit(), 19);
    `check(obj.get_super_value(), 18);
    `check(obj.VALUE, 18);
    `check($bits(obj.value), 18);

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
