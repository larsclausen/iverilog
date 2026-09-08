// Check that ordinary class lookup takes precedence over package lookup.

package M;
  parameter int VALUE = 1;
endpackage

module M(output wire [31:0] value);
  assign value = M::VALUE; // Selects the package, not this module.
endmodule

module test;
  class M;
    localparam int VALUE = 2;
  endclass

  wire [31:0] value;
  M i_m(value);

  initial begin
    #1;
    if (M::VALUE == 2 && value == 1) $display("PASSED");
    else $display("FAILED");
  end
endmodule
