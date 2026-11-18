// Check that a forced net follows updates from a partially driven source net.

module test;
  reg [3:0] drive;
  wire [7:0] source, target;
  assign source[5:2] = drive;
  reg failed;

  `define check(val, exp) \
    if (val !== exp) begin \
      $display("FAILED(%0d). '%s' expected %b, got %b", `__LINE__, \
               `"val`", exp, val); \
      failed = 1'b1; \
    end

  initial begin
    failed = 1'b0;
    drive = 4'b1010;
    force target = source;
    #1;
    `check(target, {2'bzz, 4'b1010, 2'bzz});
    drive = 4'b01xz;
    #1;
    `check(target, {2'bzz, 4'b01xz, 2'bzz});
    if (!failed) begin
      $display("PASSED");
    end
  end
endmodule
