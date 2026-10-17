// Check signedness metadata for two-state, dynamic array and queue words.

module test;

  bit failed = 1'b0;
  bit signed [7:0] signed_words [0:1];
  bit [7:0] unsigned_words [0:1];
  reg signed [7:0] signed_da [];
  reg [7:0] unsigned_da [];
  bit signed [32:0] signed_q [$];
  bit [32:0] unsigned_q [$];
  byte bytes [0:1];
  byte unsigned unsigned_bytes [0:1];
  integer integers [0:1];
  wire signed [7:0] signed_nets [0:1];
  wire [7:0] unsigned_nets [0:1];
  string path;
  integer index;

  assign signed_nets[0] = -1;
  assign signed_nets[1] = 0;
  assign unsigned_nets[0] = -1;
  assign unsigned_nets[1] = 0;

  `define check(val, exp) \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %0d, got %0d", `__LINE__, \
               `"val`", exp, val); \
      failed = 1'b1; \
    end

  `define check_word(array, idx, exp) \
    $sformat(path, "%m.%s", `"array`"); \
    `check($vpi_word_signed(path, idx), exp);

  task automatic check_local;
    reg signed [7:0] fixed_words [0:1];
    reg [7:0] unsigned_fixed [0:1];
    byte dynamic_words [];
    byte unsigned queue_words [$];
    fixed_words[0] = -1;
    unsigned_fixed[0] = -1;
    dynamic_words = new[1];
    dynamic_words[0] = -1;
    queue_words.push_back(-1);
    `check($vpi_signed(fixed_words[0]), 1);
    `check($vpi_signed(unsigned_fixed[0]), 0);
    `check_word(fixed_words, 0, 1);
    `check_word(unsigned_fixed, 0, 0);
    `check_word(dynamic_words, 0, 1);
    `check_word(queue_words, 0, 0);
  endtask

  initial begin
    signed_da = new[2];
    unsigned_da = new[2];
    repeat (2) begin
      signed_q.push_back(-1);
      unsigned_q.push_back(-1);
    end

    for (index = 0; index < 2; index = index + 1) begin
      signed_words[index] = -1;
      unsigned_words[index] = -1;
      signed_da[index] = -1;
      unsigned_da[index] = -1;
      bytes[index] = -1;
      unsigned_bytes[index] = -1;
      integers[index] = -1;

      `check($vpi_signed(signed_words[index]), 1);
      `check($vpi_signed(unsigned_words[index]), 0);
      `check($vpi_signed(signed_nets[index]), 1);
      `check($vpi_signed(unsigned_nets[index]), 0);
      `check($vpi_signed(signed_da[index]), 1);
      `check($vpi_signed(unsigned_da[index]), 0);
      `check($vpi_signed(signed_q[index]), 1);
      `check($vpi_signed(unsigned_q[index]), 0);
      `check($vpi_signed(integers[index]), 1);
      `check_word(signed_words, index, 1);
      `check_word(unsigned_words, index, 0);
      `check_word(signed_nets, index, 1);
      `check_word(unsigned_nets, index, 0);
      `check_word(signed_da, index, 1);
      `check_word(unsigned_da, index, 0);
      `check_word(signed_q, index, 1);
      `check_word(unsigned_q, index, 0);
      `check_word(bytes, index, 1);
      `check_word(unsigned_bytes, index, 0);
      `check_word(integers, index, 1);
    end

    check_local;
    if (!failed) $display("PASSED");
  end

endmodule
