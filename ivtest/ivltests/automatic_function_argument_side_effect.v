// Check that automatic function arguments update variables in the caller.

module test;

  function automatic integer identity(input integer value);
    identity = value;
  endfunction

  function automatic [63:0] run(input integer i, input integer op);
    integer result;
    case (op)
      0: result = identity(i++);
      1: result = identity(++i);
      2: result = identity(i--);
      3: result = identity(--i);
      4: result = identity(identity(i++));
    endcase
    run = {i, result};
  endfunction

  function automatic integer recurse(input integer depth, input integer value);
    integer result;
    if (depth == 0) begin
      recurse = value;
    end else begin
      result = recurse(depth - 1, value++);
      recurse = value + result;
    end
  endfunction

  bit failed = 1'b0;

  `define check(val, exp) \
    if ((val) !== (exp)) begin \
      $display("FAILED(%0d): '%s' expected %h, got %h", `__LINE__, \
               `"val`", exp, val); \
      failed = 1'b1; \
    end

  initial begin
    `check(run(2, 0), {32'd3, 32'd2});
    `check(run(2, 1), {32'd3, 32'd3});
    `check(run(2, 2), {32'd1, 32'd2});
    `check(run(2, 3), {32'd1, 32'd1});
    `check(run(2, 4), {32'd3, 32'd2});
    `check(recurse(2, 2), 32'd8);

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
