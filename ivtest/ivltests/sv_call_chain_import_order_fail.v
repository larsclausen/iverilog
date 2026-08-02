// Check that a function imported after a chained call is not visible.

package p;

  class C;
    function integer get;
      get = 1;
    endfunction
  endclass

  function C make;
    make = new;
  endfunction

endpackage

module test;

  initial begin
    $display("%0d", make().get());
  end

  import p::make;

endmodule
