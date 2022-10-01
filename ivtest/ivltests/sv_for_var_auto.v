// Check that a variable declared in foor loop is always automatic, even when
// the containing scope is not automatic.

module test;

  int count = 0;

  task t;
    for (int i = 0; i < 10; i = i + 1) begin
      count++;
      #10;
    end
  endtask

  initial begin
    fork
    t;
    #5 t;
    join

    if (count === 20) begin
      $display("PASSED");
    end else begin
      $display("FAILED");
    end
  end

endmodule
