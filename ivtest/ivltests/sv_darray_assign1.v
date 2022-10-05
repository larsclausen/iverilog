// Check that dynamic arrays with compatible packed base types can be assigned
// to each other. Even if the element types are not identical.

module test;

  typedef bit [31:0] T1;
  typedef bit [31:0] T2[];
  typedef bit [31:0] T3[$];

  // For two packed types to be compatible they need to have the same packed
  // width, both be 2-state or 4-state and both be either signed or unsigned.
  bit [32:1] d1[];
  bit [7:0][3:0] d2[];
  int unsigned d3[];
  T1 d4[];
  T2 d5;

  // Queues and darrays can be assigned to each other if the element type is
  // equivalent.
  bit [32:1] q1[$];
  bit [7:0][3:0] q2[$];
  int unsigned q3[$];
  T1 q4[$];
  T3 q5;


  initial begin
  /*
    d1 = new[1];
    d2 = d1;
    d3 = d2;
    d4 = d3;
    d5 = d4;
    d1 = d5;

    q1.push_back(0);
    q2 = q1;
    q3 = q2;
    q4 = q3;
    q5 = q4;
    q1 = q5;
*/
    q1 = q2;
    q1 = d1;
    d1 = q1;
/*
    q3 = d2;
    d4 = q3;
    q5 = d4;
    d1 = q5;
*/
    $display("PASSED");
  end

endmodule
