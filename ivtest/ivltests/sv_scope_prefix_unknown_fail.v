// Check that an unknown scope prefix is diagnosed without a member lookup.

module test;
  initial $display(missing::value); // Error: The scope prefix is not declared.
endmodule
