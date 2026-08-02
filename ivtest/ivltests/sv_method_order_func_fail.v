// Check that a method receiver must be declared before the call.

class C;
  function integer get;
    get = 1;
  endfunction
endclass

module test;

  initial begin
    $display("%0d", object.get());
  end

  C object;

endmodule
