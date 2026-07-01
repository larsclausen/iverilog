// Check -Wshadow warnings involving classes and class properties.

class SHADOW_CLASS_CLASS;
endclass

class SHADOW_CLASS_TYPE;
endclass

integer SHADOW_ID_CLASS;

typedef int SHADOW_TYPE_CLASS;
integer SHADOW_PROPERTY_ID;
typedef int SHADOW_PROPERTY_TYPE;

module test;

  class SHADOW_CLASS_CLASS;
  endclass

  class SHADOW_TYPE_CLASS;
  endclass

  class SHADOW_ID_CLASS;
  endclass

  class SHADOW_CLASS_ID;
  endclass

  typedef int SHADOW_CLASS_TYPE;

  class shadow_property_test;
    int SHADOW_PROPERTY_ID;
    int SHADOW_PROPERTY_TYPE;
    int SHADOW_ID_PROPERTY;

    function void check();
      int SHADOW_ID_PROPERTY;
    endfunction
  endclass

  initial begin
    reg failed;
    integer SHADOW_CLASS_ID;

    failed = 1'b0;

    if (!failed) begin
      $display("PASSED");
    end
  end

endmodule
