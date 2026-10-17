// Check that stochastic queue inputs preserve memory word signedness.

module test;
  reg signed [7:0] words [0:1];
  reg [7:0] unsigned_words [0:1];
  reg failed;
  integer status, job, info, index;

  `define check(val, exp) \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %h, got %h", `__LINE__, \
               `"val`", exp, val); \
      failed = 1'b1; \
    end

  `define roundtrip(job_arg, info_arg, job_exp, info_exp) \
    $q_add(1, job_arg, info_arg, status); \
    `check(status, 0); \
    $q_remove(1, job, info, status); \
    `check(status, 0); \
    `check(job, job_exp); \
    `check(info, info_exp);

  initial begin
    failed = 1'b0;
    words[0] = -1;
    words[1] = -128;
    unsigned_words[0] = 255;
    unsigned_words[1] = 128;
    index = 0;

    $q_initialize(1, 1, 2, status);
    `check(status, 0);
    `roundtrip(words[0], words[1], -1, -128);
    `roundtrip(words[index], words[index+1], -1, -128);
    `roundtrip(unsigned_words[index], unsigned_words[index+1], 255, 128);
    `roundtrip(words[index][7:0], words[index+1][7:0], 255, 128);

    // A negative maximum length must be rejected, not zero-extended.
    $q_initialize(2, 1, words[0], status);
    `check(status, 5);
    $q_initialize(3, 1, words[index], status);
    `check(status, 5);
    $q_initialize(4, 1, unsigned_words[index], status);
    `check(status, 0);

    words[0] = 8'hx1;
    words[1] = 8'hz1;
    `roundtrip(words[index], words[index+1], 32'hxxxxxxx1, 32'hzzzzzzz1);

    if (!failed) $display("PASSED");
  end
endmodule
