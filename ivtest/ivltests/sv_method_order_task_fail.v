// Check that a task method receiver must be declared before the call.

class C;
  task run;
  endtask
endclass

module test;

  initial begin
    object.run();
  end

  C object;

endmodule
