// Check that class parameters can be referenced before their declaration in
// constant expressions of other class declarations.

module test;

  localparam int WIDTH = 8;

  bit failed = 1'b0;

  `define check(val, exp) do \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %0d, got %0d", `__LINE__, `"val`", exp, val); \
      failed = 1'b1; \
    end \
  while(0)

  class C;
    logic [WIDTH-1:0] value;
    localparam int NEXT_WIDTH = WIDTH + 1;
    localparam int WIDTH = 16;

    function int get_width;
      return $bits(value);
    endfunction

    function int get_next_width;
      return NEXT_WIDTH;
    endfunction
  endclass

  C obj;

  initial begin
    obj = new;

    `check(obj.get_width(), 16);
    `check(obj.get_next_width(), 17);

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
