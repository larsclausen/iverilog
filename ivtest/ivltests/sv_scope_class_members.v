// Check types and values through package and nested class-type prefixes.

package p;
  class C;
    typedef logic [7:0] T;
    localparam int VALUE = 23;
    typedef enum { E = 7 } enum_t;
    static T value;
  endclass
endpackage

module test;
  class D;
    typedef p::C A;
  endclass

  D::A::T value;
  p::C::T [1:0] packed_value;

  function D::A::T read_value();
    return p::C::value;
  endfunction

  initial begin
    p::C::value = p::C::VALUE;
    D::A::value[3:0] = 4'h5;
    value = read_value();
    packed_value = {value, value};
    if (value === 8'h15 && packed_value === 16'h1515 && p::C::E == 7)
      $display("PASSED");
    else $display("FAILED");
  end
endmodule
