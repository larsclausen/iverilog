// Check that a class prefix cannot select an instance property.

class C;
  int value;
endclass

module test;
  initial $display(C::value); // Error: value requires a class instance.
endmodule
