

typedef struct packed {
  reg [31:0] x;
  reg [7:0] y;
} T;

module test;

  task t;
    input [47:0] x;
    T x;
    $display("FAILED");
  endtask

  initial t(10);

endmodule
