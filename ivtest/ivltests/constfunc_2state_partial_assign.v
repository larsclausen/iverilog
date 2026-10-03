// Check that a partial assignment in a constant function leaves other bits zero.

module test;

  function logic [7:0] f(input logic [3:0] value);
    bit [7:0] v;
    v[3:0] = value;
    f = v;
  endfunction

  localparam logic [7:0] P = f(4'h5);

  initial begin
    if (P !== 8'h05) begin
      $display("FAILED: expected 05, got %h", P);
    end else begin
      $display("PASSED");
    end
  end

endmodule
