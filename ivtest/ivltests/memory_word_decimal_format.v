// Check that decimal field widths account for signed memory words.

module test;
  reg signed [7:0] words [0:1];
  reg [7:0] unsigned_words [0:1];
  reg [8*32-1:0] text;
  reg failed;
  integer index;

  `define check(fmt, val, exp) \
    $sformat(text, fmt, val); \
    if (text != exp) begin \
      $display("FAILED(%0d). '%s' expected [%s], got [%0s]", `__LINE__, \
               `"val`", exp, text); \
      failed = 1'b1; \
    end

  initial begin
    failed = 1'b0;
    words[0] = -1;
    words[1] = 1;
    unsigned_words[0] = 1;
    unsigned_words[1] = 255;
    index = 0;

    `check("%d", words[0], "  -1");
    `check("%d", words[1], "   1");
    `check("%d", words[index], "  -1");
    `check("%d", unsigned_words[0], "  1");
    `check("%d", unsigned_words[index], "  1");
    `check("%d", unsigned_words[1], "255");
    `check("%0d", words[index], "-1");
    `check("%6d", words[index], "    -1");
    `check("%d", words[index][7:0], "255");

    words[0] = -128;
    `check("%d", words[0], "-128");
    `check("%d", words[index], "-128");
    words[0] = 8'bx;
    `check("%d", words[index], "   x");
    words[0] = 8'bz;
    `check("%d", words[index], "   z");

    if (!failed) $display("PASSED");
  end
endmodule
