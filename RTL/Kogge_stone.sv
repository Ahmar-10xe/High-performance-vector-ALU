module KS_ADDER #(
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,  // operands 
    output logic [WIDTH-1:0] sum,
    output logic             carry,
    input  logic             cin
);

  // Calculating propagate and generate signals for each pair of bits

  wire p[7:0],g[7:0],intermediate_p[6:0],intermediate_g[6:0],intermediate2_p[6:0],intermediate2_g[6:0];
  for (genvar i = 0; i < 8; i++) begin
    xor (p[i], a[i], b[i]);
    and (g[i], a[i], b[i]);
  end

  // Instantiations of greyCells and blackCells

  grayCell DUT0 (
      .Gi(g[0]),
      .Pi(p[0]),
      .GiPrev(cin),
      .G(sum_1_inp)
  );

  for (genvar i = 1; i < 8; i++) begin
    blackCell DUT50 (
        .Gi(g[i]),
        .GiPrev(g[i-1]),
        .Pi(p[i]),
        .PiPrev(p[i-1]),
        .G(intermediate_g[i-1]),
        .P(intermediate_p[i-1])
    );
  end

  grayCell DUT1 (
      .Gi(intermediate_g[0]),
      .Pi(intermediate_p[0]),
      .GiPrev(cin),
      .G(sum_2_inp)
  );
  grayCell DUT2 (
      .Gi(intermediate_g[1]),
      .Pi(intermediate_p[1]),
      .GiPrev(sum_1_inp),
      .G(sum_3_inp)
  );


  blackCell DUT3 (
      .Gi(intermediate_g[2]),
      .Pi(intermediate_p[2]),
      .GiPrev(intermediate_g[0]),
      .PiPrev(intermediate_p[0]),
      .G(intermediate2_g[0]),
      .P(intermediate2_p[0])
  );
  blackCell DUT4 (
      .Gi(intermediate_g[3]),
      .Pi(intermediate_p[3]),
      .GiPrev(intermediate_g[1]),
      .PiPrev(intermediate_p[1]),
      .G(intermediate2_g[1]),
      .P(intermediate2_p[1])
  );
  blackCell DUT5 (
      .Gi(intermediate_g[4]),
      .Pi(intermediate_p[4]),
      .GiPrev(intermediate_g[2]),
      .PiPrev(intermediate_p[2]),
      .G(intermediate2_g[2]),
      .P(intermediate2_p[2])
  );
  blackCell DUT6 (
      .Gi(intermediate_g[5]),
      .Pi(intermediate_p[5]),
      .GiPrev(intermediate_g[3]),
      .PiPrev(intermediate_p[3]),
      .G(intermediate2_g[3]),
      .P(intermediate2_p[3])
  );
  blackCell DUT7 (
      .Gi(intermediate_g[6]),
      .Pi(intermediate_p[6]),
      .GiPrev(intermediate_g[4]),
      .PiPrev(intermediate_p[4]),
      .G(intermediate2_g[4]),
      .P(intermediate2_p[4])
  );


  grayCell DUT8 (
      .Gi(intermediate2_g[0]),
      .Pi(intermediate2_p[0]),
      .GiPrev(cin),
      .G(sum_4_inp)
  );
  grayCell DUT9 (
      .Gi(intermediate2_g[1]),
      .Pi(intermediate2_p[1]),
      .GiPrev(sum_1_inp),
      .G(sum_5_inp)
  );
  grayCell DUT10 (
      .Gi(intermediate2_g[2]),
      .Pi(intermediate2_p[2]),
      .GiPrev(sum_2_inp),
      .G(sum_6_inp)
  );
  grayCell DUT11 (
      .Gi(intermediate2_g[3]),
      .Pi(intermediate2_p[3]),
      .GiPrev(sum_3_inp),
      .G(sum_7_inp)
  );


  blackCell DUT12 (
      .Gi(intermediate2_g[4]),
      .Pi(intermediate2_p[4]),
      .GiPrev(intermediate2_g[0]),
      .PiPrev(intermediate2_p[0]),
      .G(final_g),
      .P(final_p)
  );

  grayCell DUT13 (
      .Gi(final_g),
      .Pi(final_p),
      .GiPrev(cin),
      .G(carry)
  );

  // Calculating the final sum

  xor (sum[0], p[0], cin);
  xor (sum[1], p[1], sum_1_inp);
  xor (sum[2], p[2], sum_2_inp);
  xor (sum[3], p[3], sum_3_inp);
  xor (sum[4], p[4], sum_4_inp);
  xor (sum[5], p[5], sum_5_inp);
  xor (sum[6], p[6], sum_6_inp);
  xor (sum[7], p[7], sum_7_inp);


endmodule
