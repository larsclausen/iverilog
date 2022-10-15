
module test;

  wire enum integer {
    A
  } x[1:0];
  integer y[1:0];

  assign x = y;

endmodule
