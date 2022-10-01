// Check that the loop variables of a foreach loop are always automatic, even if
// the containing scope is not automatic

module test;

  int count = 0;

  int a[10];

  task t;
    foreach (a[i]) begin
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
