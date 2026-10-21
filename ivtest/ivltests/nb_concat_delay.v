// Check that a nonblocking concatenation evaluates its delay only once.

module test;

  reg a;
  reg [3:0] b;
  reg [3:0] c[0:1];
  integer calls, word, offset;

  function integer delay_value;
    input integer step;
    begin
      calls = calls + 1;
      delay_value = calls * step;
    end
  endfunction

  initial begin
    calls = 0;
    word = 1;
    offset = 2;
    a = 0;
    b = 0;
    c[1] = 0;

    {a, b[0], b[offset], c[word][offset +: 1]} <= #(delay_value(2)) 4'b1111;
    #3;

    if (calls !== 1 || a !== 1'b1 || b !== 4'b0101 || c[1] !== 4'b0100) begin
      $display("FAILED");
    end else begin
      $display("PASSED");
    end
  end

endmodule
