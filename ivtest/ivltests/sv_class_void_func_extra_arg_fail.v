// Check that a class void function rejects one extra argument.

module test;
  class C;
    function void f(input integer a);
      $display("a=%0d", a);
    endfunction
  endclass

  C c;

  initial begin
    c = new;
    c.f(1, 2); // Error: The function has only one explicit argument.
    $display("FAILED");
  end
endmodule
