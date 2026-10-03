// Check that a constant function preserves X in untouched logic members.

module test;

  typedef struct packed {
    logic [3:0] a;
    bit [3:0] b;
  } S;

  function logic [7:0] f(input logic [3:0] value);
    S s;
    s.b = value;
    f = s;
  endfunction

  localparam logic [7:0] P = f(4'h5);

  initial begin
    if (P !== 8'hx5) begin
      $display("FAILED: expected x5, got %h", P);
    end else begin
      $display("PASSED");
    end
  end

endmodule
