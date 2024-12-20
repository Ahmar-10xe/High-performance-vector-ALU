module alu #(
    parameter WIDTH     = 8,  // Width of the input and output operands to each individual adders
    parameter BITS      = 64,  // Width of the output of all the adders combined
    parameter PRECISION = 2  // Precision of the input operand
) (
    input  logic                 clk,rst,       // Clock and reset signals
    input  logic [     BITS-1:0] a,             // First operand
    input  logic [     BITS-1:0] b,             // Second operand
    output logic [     BITS-1:0] result_final,  // Final result
    input  logic [PRECISION-1:0] precision,
    input  logic [          3:0] opcode,        // Opcode for the operation to be performed
    output logic                 carry          // Carry out of the ALU
);
  logic carry_in,carry_in_d;  // Input carry after being saved in a register and before being saved respectively
  logic sub, sub_d;  // Signals to decide whether to perform addition or subtraction
  logic [          6:0] enable;  // signal to select whether to cascade adders or not
  logic [PRECISION-1:0] precision_reg;
  logic [     BITS-1:0] result;  // adder and subtractor output
  logic [     BITS-1:0] result_i;
  logic [     BITS-1:0] xor_out;  // XOR output
  logic [     BITS-1:0] and_out;  // AND output
  logic [     BITS-1:0] or_out;  // OR output
  logic [     BITS-1:0] setu_out;  // SET EQUAL output
  logic [     WIDTH-1:0] setu_out_i;  // SET EQUAL intermediate output
  logic [     BITS-1:0] setnu_out;  // SET NOT EQUAL output
  logic [     BITS-1:0] avg_add_sub_out;  // AVG ADD SUB output
  logic [     WIDTH-1:0] setnu_out_i;  // SET NOT EQUAL intermediate output
  logic [BITS-1:0] adder_b, b_reg;  // adder b input and register to store b
  wire c1, c2, c3, c4, c5, c6, c7, c8, c12, c10, c14;  // carry signals
  logic [BITS-1:0] a_reg, max_out, min_out;  // register to store a
  logic [3:0] opcode_reg;  // register to store opcode
  assign carry_in_d = sub_d ? 1 : 0;  // carry in to the ALU based on the opcode


  // Instantiations

  ks_adder DUT1 (
      .a(a_reg[7:0]),
      .b(adder_b[7:0]),
      .cin(carry_in),
      .sum(result[7:0]),
      .carry(c1)
  );


  ks_adder DUT2 (
      .a(a_reg[15:8]),
      .b(adder_b[15:8]),
      .cin(c2),
      .sum(result[15:8]),
      .carry(c3)
  );

  ks_adder DUT3 (
      .a(a_reg[23:16]),
      .b(adder_b[23:16]),
      .cin(c4),
      .sum(result[23:16]),
      .carry(c5)
  );

  ks_adder DUT4 (
      .a(a_reg[31:24]),
      .b(adder_b[31:24]),
      .cin(c6),
      .sum(result[31:24]),
      .carry(c7)
  );

  ks_adder DUT5 (
      .a(a_reg[39:32]),
      .b(adder_b[39:32]),
      .cin(c8),
      .sum(result[39:32]),
      .carry(c9)
  );

  ks_adder DUT6 (
      .a(a_reg[47:40]),
      .b(adder_b[47:40]),
      .cin(c10),
      .sum(result[47:40]),
      .carry(c11)
  );

  ks_adder DUT7 (
      .a(a_reg[55:48]),
      .b(adder_b[55:48]),
      .cin(c12),
      .sum(result[55:48]),
      .carry(c13)
  );

  ks_adder DUT8 (
      .a(a_reg[63:56]),
      .b(adder_b[63:56]),
      .cin(c14),
      .sum(result[63:56]),
      .carry(carry)
  );



  // MUX for selecting the carry based on the input precision

  always_comb begin
    unique case (precision_reg)
      2'b00:   enable = '0;
      2'b01:   enable = 7'b1010101;
      2'b10:   enable = 7'b1110111;
      2'b11:   enable = '1;
      default: enable = '0;
    endcase
  end

  // Logical operations

  assign adder_b = sub ? (~b_reg) : b_reg;
  assign and_out = a_reg & adder_b;
  assign or_out  = a_reg | adder_b;
  assign xor_out = a_reg ^ adder_b;

  assign sub_d = (opcode[2] & opcode[1]) | (opcode[3] & opcode[0] ) | (opcode[3] & opcode[1] );          // sub signal used to determine whether to perform addition or subtraction

  // Averaging add and sub operations
  /*for (genvar i = BITS - 9; i > WIDTH - 2; i = i - 8) begin
    assign avg_add_sub_out[i:i-7] = {enable[(i-7)/8] ? result[i+1] : result[i], result[i:i-6]};
  end

  assign avg_add_sub_out[63:56] = {result[63], result[63:57]};  */
  
    // Averaging add and sub operations
  for (genvar i = BITS - 9; i > WIDTH - 2; i = i - 8) begin
    assign avg_add_sub_out[i:i-7] = {enable[(i-7)/8] ? result[i+1] : 1'b0, result[i:i-6]};
  end

  assign avg_add_sub_out[63:56] = {1'b0, result[63:57]};

  // Carry selection based on enable signals
  assign c2  = enable[0] ? c1  : (sub ? 1 : 0);
  assign c4  = enable[1] ? c3  : (sub ? 1 : 0);
  assign c6  = enable[2] ? c5  : (sub ? 1 : 0);          // Align
  assign c8  = enable[3] ? c7  : (sub ? 1 : 0);
  assign c10 = enable[4] ? c9  : (sub ? 1 : 0);
  assign c12 = enable[5] ? c11 : (sub ? 1 : 0);
  assign c14 = enable[6] ? c13 : (sub ? 1 : 0);


  // Registers to store inputs
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      a_reg <= 0;
      b_reg <= 0;
      opcode_reg <= 0;
      precision_reg <= 0;
      carry_in <= 0;
      sub <= 0;
    end 
    else begin
      a_reg <= a;
      b_reg <= b;
      opcode_reg <= opcode;
      precision_reg <= precision;
      carry_in <= carry_in_d;
      sub <= sub_d;
    end
  end

  //set equal calculation
  for (genvar i = 0; i < 64; i = i + 8) begin
    assign setu_out_i[i/8] = (xor_out[i+7:i]) ? 1'b0 : 1'b1;
  end

  always_comb begin
    setu_out = '0;
    unique case (precision_reg)
      2'b11: begin
        setu_out[0] = setu_out_i[0] & setu_out_i[1] & setu_out_i[2] & setu_out_i[3]
                      & setu_out_i[4] & setu_out_i[5] & setu_out_i[6] & setu_out_i[7];
      end
      2'b10: begin
        setu_out[0]  = setu_out_i[0] & setu_out_i[1] & setu_out_i[2] & setu_out_i[3];
        setu_out[32] = setu_out_i[4] & setu_out_i[5] & setu_out_i[6] & setu_out_i[7];
      end
      2'b01: begin
        setu_out[0]  = setu_out_i[0] & setu_out_i[1];
        setu_out[16] = setu_out_i[2] & setu_out_i[3];
        setu_out[32] = setu_out_i[4] & setu_out_i[5];
        setu_out[48] = setu_out_i[6] & setu_out_i[7];
      end
      2'b00: begin
        setu_out[0]  = setu_out_i[0];
        setu_out[8]  = setu_out_i[1];
        setu_out[16] = setu_out_i[2];
        setu_out[24] = setu_out_i[3];
        setu_out[32] = setu_out_i[4];
        setu_out[40] = setu_out_i[5];
        setu_out[48] = setu_out_i[6];
        setu_out[56] = setu_out_i[7];
      end
    endcase
  end

  // set not equal calculation
  for (genvar i = 0; i < 64; i = i + 8) begin
    assign setnu_out_i[i/8] = (xor_out[i+7:i]) ? 1'b1 : 1'b0;
  end

  always_comb begin
    setnu_out = '0;
    unique case (precision_reg)
      2'b11: begin
        setnu_out[0] = setnu_out_i[0] | setnu_out_i[1] |setnu_out_i[2] | setnu_out_i[3]
                       | setnu_out_i[4] | setnu_out_i[5] | setnu_out_i[6] | setnu_out_i[7];
      end
      2'b10: begin
        setnu_out[0]  = setnu_out_i[0] | setnu_out_i[1] | setnu_out_i[2] | setnu_out_i[3];
        setnu_out[32] = setnu_out_i[4] | setnu_out_i[5] | setnu_out_i[6] | setnu_out_i[7];
      end
      2'b01: begin
        setnu_out[0]  = setnu_out_i[0] | setnu_out_i[1];
        setnu_out[16] = setnu_out_i[2] | setnu_out_i[3];
        setnu_out[32] = setnu_out_i[4] | setnu_out_i[5];
        setnu_out[48] = setnu_out_i[6] | setnu_out_i[7];
      end
      2'b00: begin
        setnu_out[0]  = setnu_out_i[0];
        setnu_out[8]  = setnu_out_i[1];
        setnu_out[16] = setnu_out_i[2];
        setnu_out[24] = setnu_out_i[3];
        setnu_out[32] = setnu_out_i[4];
        setnu_out[40] = setnu_out_i[5];
        setnu_out[48] = setnu_out_i[6];
        setnu_out[56] = setnu_out_i[7];
      end
    endcase
  end


  always @(posedge clk or posedge rst) begin
    if (rst) begin
       result_final <= 0;
    end
    else begin
      result_final <= result_i;
    end
  end



  // Max-min out

  always_comb begin
    unique case (precision_reg)
      2'b11: begin
        if ((result[63] & adder_b[63]) | (a_reg[63] & adder_b[63]) | (result[63] & a_reg[63])) begin
          max_out = b_reg;
          min_out = a_reg;
        end
        else begin
           max_out = a_reg;
           min_out = b_reg;
        end
      end

      2'b10: begin
        if ((result[63] & adder_b[63]) | (a_reg[63] & adder_b[63]) | (result[63] & a_reg[63])) begin
          max_out[63:32] = b_reg[63:32];
          min_out[63:32] = a_reg[63:32];
        end
        else begin
           max_out[63:32] = a_reg[63:32];
           min_out[63:32] = b_reg[63:32];
        end

        if ((result[31] & adder_b[31]) | (a_reg[31] & adder_b[31]) | (result[31] & a_reg[31])) begin
          max_out[31:0] = b_reg[31:0];
          min_out[31:0] = a_reg[31:0];
        end
        else begin
           max_out[31:0] = a_reg[31:0];
          min_out[31:0] = b_reg[31:0];
        end
      end

      2'b01: begin
        if ((result[63] & adder_b[63]) | (a_reg[63] & adder_b[63]) | (result[63] & a_reg[63])) begin
          max_out[63:48] = b_reg[63:48];
          min_out[63:48] = a_reg[63:48];
        end
        else begin
           max_out[63:48] = a_reg[63:48];
           min_out[63:48] = b_reg[63:48];
        end


        if ((result[47] & adder_b[47]) | (a_reg[47] & adder_b[47]) | (result[47] & a_reg[47])) begin
          max_out[47:32] = b_reg[47:32];
          min_out[47:32] = a_reg[47:32];
        end
        else begin
           max_out[47:32] = a_reg[47:32];
           min_out[47:32] = b_reg[47:32];
        end


        if ((result[31] & adder_b[31]) | (a_reg[31] & adder_b[31]) | (result[31] & a_reg[31])) begin
          max_out[31:16] = b_reg[31:16];
          min_out[31:16] = a_reg[31:16];
        end
        else begin 
          max_out[31:16] = a_reg[31:16];
          min_out[31:16] = b_reg[31:16];
        end


        if ((result[15] & adder_b[15]) | (a_reg[15] & adder_b[15]) | (result[15] & a_reg[15])) begin
          max_out[15:0] = b_reg[15:0];
          min_out[15:0] = a_reg[15:0];
        end
        else begin
           max_out[15:0] = a_reg[15:0];
           min_out[15:0] = b_reg[15:0];
        end
      end


      2'b00: begin
        if ((result[63] & adder_b[63]) | (a_reg[63] & adder_b[63]) | (result[63] & a_reg[63])) begin
          max_out[63:56] = b_reg[63:56];
          min_out[63:56] = a_reg[63:56];
        end
        else begin
           max_out[63:56] = a_reg[63:56];
           min_out[63:56] = b_reg[63:56];
        end


        if ((result[55] & adder_b[55]) | (a_reg[55] & adder_b[55]) | (result[55] & a_reg[55])) begin
          max_out[55:48] = b_reg[55:48];
          min_out[55:48] = a_reg[55:48];
        end
        else begin
           max_out[55:48] = a_reg[55:48];
           min_out[55:48] = b_reg[55:48];
        end


        if ((result[47] & adder_b[47]) | (a_reg[47] & adder_b[47]) | (result[47] & a_reg[47])) begin
          max_out[47:40] = b_reg[47:40];
          min_out[47:40] = a_reg[47:40];
        end
        else begin 
          max_out[47:40] = a_reg[47:40];
          min_out[47:40] = b_reg[47:40];
        end


        if ((result[39] & adder_b[39]) | (a_reg[39] & adder_b[39]) | (result[39] & a_reg[39])) begin
          max_out[39:32] = b_reg[39:32];
          min_out[39:32] = a_reg[39:32];
        end
        else begin 
          max_out[39:32] = a_reg[39:32];
          min_out[39:32] = b_reg[39:32];
        end

        if ((result[31] & adder_b[31]) | (a_reg[31] & adder_b[31]) | (result[31] & a_reg[31])) begin
          max_out[31:24] = b_reg[31:24];
          min_out[31:24] = a_reg[31:24];
        end
        else begin
           max_out[31:24] = a_reg[31:24];
           min_out[31:24] = b_reg[31:24];
        end

        if ((result[23] & adder_b[23]) | (a_reg[23] & adder_b[23]) | (result[23] & a_reg[23])) begin
          max_out[23:16] = b_reg[23:16];
          min_out[23:16] = a_reg[23:16];
        end
        else begin
           max_out[23:16] = a_reg[23:16];
           min_out[23:16] = b_reg[23:16];
        end

        if ((result[15] & adder_b[15]) | (a_reg[15] & adder_b[15]) | (result[15] & a_reg[15])) begin
          max_out[15:8] = b_reg[15:8];
          min_out[15:8] = a_reg[15:8];
        end
        else begin
           max_out[15:8] = a_reg[15:8];
           min_out[15:8] = b_reg[15:8];
        end

        if ((result[7] & adder_b[7]) | (a_reg[7] & adder_b[7]) | (result[7] & a_reg[7])) begin
          max_out[7:0] = b_reg[7:0];
          min_out[7:0] = a_reg[7:0];
        end
        else begin
           max_out[7:0] = a_reg[7:0];
           min_out[7:0] = b_reg[7:0];
        end
      end

    endcase
  end



  // MUX for selecting the final result based on opcode

  always_comb begin
    unique case (opcode_reg)
      4'b0000: result_i = and_out;
      4'b0001: result_i = or_out;
      4'b0010: result_i = xor_out;
      4'b0011: result_i = result;
      4'b0100: result_i = setu_out;
      4'b0101: result_i = setnu_out;
      4'b0110: result_i = result;
      4'b0111: result_i = avg_add_sub_out;
      4'b1000: result_i = avg_add_sub_out;
      4'b1001: result_i = max_out;
      4'b1010: result_i = min_out;
      default: result_i = '0;
    endcase
  end

endmodule
