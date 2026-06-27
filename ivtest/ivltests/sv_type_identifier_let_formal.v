// Check that type identifiers can be used as let formal identifiers.

typedef int T;
typedef int U;
typedef int V;
typedef int W;

module test;
  let f(T, int U, T W, untyped V [1:0]) = 1;
endmodule
