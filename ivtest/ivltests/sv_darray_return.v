// Check that functions returning a dynamic array are supported

module test;

  typedef int T[];

  function T f(int n);
    if (n == 1) begin
      f = new[n];
      f[0] = 32'h12345678;
    end else begin
      f[0] = n;
    end
  endfunction

  initial begin
    T d1, d2;
    d1 = f(1);
    d2 = f(2);
    if (d1.size() == 1 && d2[0] == 32'h12345678) begin
      $display("PASSED");
    end else begin
      $display("FAILED");
    end
  end

endmodule
