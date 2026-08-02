// Check that class enum literals can be referenced before their declaration.

module test;

  localparam int VALUE = 8;
  localparam int WIDTH = 9;

  bit failed = 1'b0;

  `define check(val, exp) do \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %0d, got %0d", `__LINE__, `"val`", exp, val); \
      failed = 1'b1; \
    end \
  while(0)

  class C;
    logic [WIDTH-1:0] value;

    function int get_value;
      return VALUE;
    endfunction

    typedef enum int {
      VALUE = 16,
      WIDTH = 17
    } value_t;
  endclass

  C obj;

  initial begin
    obj = new;

    `check(obj.get_value(), 16);
    `check($bits(obj.value), 17);

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
