// Check that VPI reads preserve dynamic array and queue element signedness.

module M #(parameter WIDTH = 8) (output reg failed);

  reg signed [WIDTH-1:0] s4;
  reg [WIDTH-1:0] u4;
  bit signed [WIDTH-1:0] s2;
  bit [WIDTH-1:0] u2;
  reg signed [WIDTH-1:0] da_s4 [], q_s4 [$];
  reg [WIDTH-1:0] da_u4 [], q_u4 [$];
  bit signed [WIDTH-1:0] da_s2 [], q_s2 [$];
  bit [WIDTH-1:0] da_u2 [], q_u2 [$];
  integer index;

  `define check(array, reference) \
    if (!$check_array_word($sformatf("%m.%s", `"array`"), index, reference)) begin \
      $display("FAILED(%0d). '%s' width %0d", `__LINE__, `"array`", WIDTH); \
      failed = 1'b1; \
    end

  `define check_value(value) \
    s4 = value; \
    u4 = value; \
    s2 = value; \
    u2 = value; \
    for (index = 0; index < 2; index = index + 1) begin \
      da_s4[index] = s4; q_s4[index] = s4; \
      da_u4[index] = u4; q_u4[index] = u4; \
      da_s2[index] = s2; q_s2[index] = s2; \
      da_u2[index] = u2; q_u2[index] = u2; \
      `check(da_s4, s4); \
      `check(q_s4, s4); \
      `check(da_u4, u4); \
      `check(q_u4, u4); \
      `check(da_s2, s2); \
      `check(q_s2, s2); \
      `check(da_u2, u2); \
      `check(q_u2, u2); \
    end

  initial begin
    failed = 1'b0;
    da_s4 = new[2];
    da_u4 = new[2];
    da_s2 = new[2];
    da_u2 = new[2];
    repeat (2) begin
      q_s4.push_back(0);
      q_u4.push_back(0);
      q_s2.push_back(0);
      q_u2.push_back(0);
    end

    `check_value(0);
    `check_value(1);
    `check_value('1);
    `check_value({WIDTH{1'b1}} << (WIDTH-1));
    `check_value({WIDTH{1'b1}} >> 1);
    `check_value({{(WIDTH-1){1'b1}}, 1'bx});
    `check_value({{(WIDTH-1){1'b1}}, 1'bz});
  end

  `undef check
  `undef check_value

endmodule

module test;

  wire [5:0] vector_failed;
  bit failed = 1'b0;
  byte signed_bytes [];
  byte unsigned unsigned_bytes [];
  longint signed_longs [$];
  longint unsigned unsigned_longs [$];

  M #(1) m1(vector_failed[0]);
  M #(8) m8(vector_failed[1]);
  M #(32) m32(vector_failed[2]);
  M #(33) m33(vector_failed[3]);
  M #(65) m65(vector_failed[4]);
  M #(129) m129(vector_failed[5]);

  `define check(array, expected) \
    if (!$check_array_word($sformatf("%m.%s", `"array`"), 0, expected)) begin \
      $display("FAILED(%0d). '%s'", `__LINE__, `"array`"); \
      failed = 1'b1; \
    end

  task automatic check_local;
    byte values [];
    byte unsigned queue [$];
    values = new[1];
    values[0] = -1;
    queue.push_back(-1);
    `check(values, -1);
    `check(queue, 255);
  endtask

  initial begin
    signed_bytes = new[1];
    unsigned_bytes = new[1];
    signed_bytes[0] = -1;
    unsigned_bytes[0] = -1;
    signed_longs.push_back(-1);
    unsigned_longs.push_back(-1);

    `check(signed_bytes, -1);
    `check(unsigned_bytes, 255);
    `check(signed_longs, -64'sd1);
    `check(unsigned_longs, 64'hffffffffffffffff);
    check_local;

    #1;
    if (!failed && vector_failed === 6'b0) $display("PASSED");
  end

endmodule
