// Check that -Wshadow warns about symbols shadowing outer-scope symbols.

package shadow_pkg;
  integer SHADOW_ID_IMPORT;
  integer NO_SHADOW_ID_WILDCARD;
endpackage

typedef int SHADOW_TYPE_TYPE;
typedef int SHADOW_ID_TYPE;

module test;

  import shadow_pkg::SHADOW_ID_IMPORT;
  import shadow_pkg::*;

  typedef int SHADOW_TYPE_TYPE;

  integer SHADOW_TYPE_ID;
  integer SHADOW_ID_TYPE;

  initial begin
    reg failed;
    typedef int SHADOW_TYPE_ID;
    integer SHADOW_ID_IMPORT;
    // Wildcard imports do not participate in shadow warnings.
    integer NO_SHADOW_ID_WILDCARD;

    failed = 1'b0;

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
