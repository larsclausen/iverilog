// Check real side effects in automatic function arguments.

module test;

  function automatic real identity(input real value);
    identity = value;
  endfunction

  function automatic [127:0] run(input real i, input integer op);
    real result;
    case (op)
      0: result = identity(i++);
      1: result = identity(++i);
      2: result = identity(i--);
      3: result = identity(--i);
    endcase
    run = {$realtobits(i), $realtobits(result)};
  endfunction

  bit failed = 1'b0;

  `define check(val, exp) \
    if ((val) !== (exp)) begin \
      $display("FAILED(%0d): '%s' expected %h, got %h", `__LINE__, \
               `"val`", exp, val); \
      failed = 1'b1; \
    end

  initial begin
    `check(run(2.5, 0), {$realtobits(3.5), $realtobits(2.5)});
    `check(run(2.5, 1), {$realtobits(3.5), $realtobits(3.5)});
    `check(run(2.5, 2), {$realtobits(1.5), $realtobits(2.5)});
    `check(run(2.5, 3), {$realtobits(1.5), $realtobits(1.5)});

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
