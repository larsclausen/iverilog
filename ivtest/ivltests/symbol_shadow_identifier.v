// Check that -Wshadow warns about identifiers shadowing identifiers.

module test;

  integer SHADOW_ID;
  parameter SHADOW_PARAMETER = 0;
  wire SHADOW_NET;
  event SHADOW_EVENT;

  function integer SHADOW_FUNCTION;
    input unused;
    SHADOW_FUNCTION = 0;
  endfunction

  initial begin : SHADOW_BLOCK
  end

  initial begin : main
    reg failed;
    integer SHADOW_ID;
    integer SHADOW_PARAMETER;
    integer SHADOW_NET;
    integer SHADOW_EVENT;
    integer SHADOW_FUNCTION;
    integer SHADOW_BLOCK;

    failed = 1'b0;

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
