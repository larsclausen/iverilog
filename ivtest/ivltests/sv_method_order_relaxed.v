// Check relaxed declaration ordering for method receivers.

class C;

  integer value;

  function new;
    value = 1;
  endfunction

  function integer get;
    get = value;
  endfunction

  task set(input integer new_value);
    value = new_value;
  endtask

endclass

module test;

  reg failed;

  `define check(val, exp) \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %0d, got %0d", `__LINE__, \
               `"val`", exp, val); \
      failed = 1'b1; \
    end

  initial begin
    failed = 1'b0;
    object = new;

    `check(object.get(), 1)
    object.set(42);
    `check(object.get(), 42)

    if (!failed) begin
      $display("PASSED");
    end
  end

  C object;

endmodule
