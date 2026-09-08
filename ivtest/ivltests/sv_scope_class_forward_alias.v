// Check an alias of a forward class through a compilation-unit prefix.

typedef class C;
typedef C A;

class C;
  typedef logic [7:0] T;
  localparam int VALUE = 23;
endclass

module test;
  typedef $unit::A::T T;
  T value;
  initial begin
    value = $unit::A::VALUE;
    if (value === 8'd23) $display("PASSED");
    else $display("FAILED");
  end
endmodule
