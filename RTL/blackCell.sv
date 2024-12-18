module blackCell (
    output logic G,       // Output Generate signal
    output logic P,       // Output Propagate signal
    input  logic Gi,      // Generate signal of ith stage
    input  logic Pi,      // Propagate signal of ith stage
    input  logic GiPrev,  // Generate signal of previous stage
    input  logic PiPrev   // Propagate signal of previous stage
);
  wire a;
  and (a, Pi, GiPrev);
  or  (G, a, Gi);
  and (P, PiPrev, Pi);
endmodule
