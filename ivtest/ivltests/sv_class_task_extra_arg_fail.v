// Check that a class task rejects one extra argument.

module test;
  class C;
    task t(input integer a);
      $display("a=%0d", a);
    endtask
  endclass

  C c;

  initial begin
    c = new;
    c.t(1, 2); // Error: The task has only one explicit argument.
    $display("FAILED");
  end
endmodule
