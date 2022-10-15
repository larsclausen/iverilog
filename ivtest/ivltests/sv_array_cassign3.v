
module test;

  wire [1:0] x[1:0];
  wire [2:1] y[1:0];

  assign x = y;

  initial begin
    $display("PASSED");
  end

endmodule
