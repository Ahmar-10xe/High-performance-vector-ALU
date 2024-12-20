module gray_cell (
    output logic G,  // Output Generate signal
    input logic Gi,  // Generate signal of ith stage
    input logic Pi,  // Propagate signal of ith stage
    input logic GiPrev  // Generate signal of previous stage
);
  wire a;
  and (a, Pi, GiPrev);
  or  (G, a, Gi);
endmodule
