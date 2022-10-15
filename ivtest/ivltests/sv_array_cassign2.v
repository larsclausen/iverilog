
module test;

  wire [1:0] x[1:0];
  wire [1:0] y[2:1];

  assign x = y;

  initial begin
    $display("PASSED");
  end

endmodule
