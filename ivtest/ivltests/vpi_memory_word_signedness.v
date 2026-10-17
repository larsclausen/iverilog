// Check that VPI memory words report their declared signedness.

module M #(parameter WIDTH = 8, LEFT = 0, RIGHT = 1) (output reg failed);

  reg signed [WIDTH-1:0] signed_words [LEFT:RIGHT];
  reg [WIDTH-1:0] unsigned_words [LEFT:RIGHT];
  reg signed [WIDTH-1:0] ordinary;
  reg [8*128-1:0] path;
  integer index, base;

  `define check(val, exp) \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %0d, got %0d", `__LINE__, \
               `"val`", exp, val); \
      failed = 1'b1; \
    end

  `define check_word(array, idx, exp) \
    $sformat(path, "%m.%s", `"array`"); \
    `check($vpi_word_signed(path, idx), exp);

  initial begin
    failed = 1'b0;
    signed_words[LEFT] = -1;
    signed_words[RIGHT] = 0;
    unsigned_words[LEFT] = -1;
    unsigned_words[RIGHT] = 0;
    ordinary = -1;
    base = 0;

    `check($vpi_signed(ordinary), 1);
    `check($vpi_signed(signed_words[LEFT]), 1);
    `check($vpi_signed(signed_words[RIGHT]), 1);
    `check($vpi_signed(unsigned_words[LEFT]), 0);
    `check_word(signed_words, LEFT, 1);
    `check_word(signed_words, RIGHT, 1);
    `check_word(unsigned_words, LEFT, 0);

    for (index = (LEFT < RIGHT ? LEFT : RIGHT);
         index <= (LEFT < RIGHT ? RIGHT : LEFT); index = index + 1) begin
      `check($vpi_signed(signed_words[index]), 1);
      `check($vpi_signed(unsigned_words[index]), 0);
      `check_word(signed_words, index, 1);
      `check_word(unsigned_words, index, 0);

      // Packed selects are unsigned, including a full-width part-select.
      if (WIDTH > 1) begin
        `check($vpi_signed(signed_words[index][0]), 0);
        `check($vpi_signed(signed_words[index][WIDTH-1:0]), 0);
        `check($vpi_signed(signed_words[index][base +: WIDTH]), 0);
      end
      `check($vpi_signed($signed(unsigned_words[index])), 1);
      `check($vpi_signed($unsigned(signed_words[index])), 0);
    end
  end

  `undef check
  `undef check_word

endmodule

module test;

  wire [5:0] failed;
  M #(1) m1(failed[0]);
  M #(8) m8(failed[1]);
  M #(33) m33(failed[2]);
  M #(65) m65(failed[3]);
  M #(8, 4, 3) descending(failed[4]);
  M #(8, -2, -1) negative(failed[5]);

  initial begin
    #1;
    if (failed === 6'b0) $display("PASSED");
  end

endmodule
