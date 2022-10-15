
module test;

  wire [31:0] x[1:0];
  wire integer y[1:0];

  assign x = y;

  initial begin
    $display("PASSED");
  end

endmodule
