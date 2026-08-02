// Check that class parameters can be referenced before their declaration from
// class property initializers and methods.

module test;

  localparam int VALUE = 8;

  bit failed = 1'b0;

  `define check(val, exp) do \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %0d, got %0d", `__LINE__, `"val`", exp, val); \
      failed = 1'b1; \
    end \
  while(0)

  class C;
    int instance_value = VALUE;
    static int static_value = VALUE;

    function int get_value;
      return VALUE;
    endfunction

    function int get_default_value(int value = VALUE);
      return value;
    endfunction

    parameter int VALUE = 16;
  endclass

  C obj;

  initial begin
    obj = new;

    `check(obj.get_value(), 16);
    `check(obj.get_default_value(), 16);
    `check(obj.instance_value, 16);
    `check(obj.static_value, 16);

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
