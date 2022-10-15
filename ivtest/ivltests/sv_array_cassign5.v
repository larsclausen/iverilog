
module test;

  wire [3:0] x[1:0];
  wire [1:0][1:0] y[1:0];

  assign x = y;

  initial begin
    $display("PASSED");
  end

endmodule
