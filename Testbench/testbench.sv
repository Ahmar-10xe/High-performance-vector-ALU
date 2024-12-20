
`timescale 1ns / 1ps

module alu_tb;

  // Parameters
  parameter WIDTH = 8;
  parameter BITS = 64;
  parameter PRECISION_BITS = 2;

  // DUT Signals
  logic clk, rst;
  logic [BITS-1:0] a, b, result_final, expected_result, expected_result1;
  logic [PRECISION_BITS-1:0] precision;
  logic [3:0] opcode;
  logic carry, test_passed;

  // Clock Generation
  always #5 clk = ~clk;

  // Instantiate the DUT
  alu #(
      .WIDTH(WIDTH),
      .BITS(BITS),
      .precision_bits(PRECISION_BITS)
  ) DUT (
      .clk(clk),
      .rst(rst),
      .a(a),
      .b(b),
      .result_final(result_final),
      .precision(precision),
      .opcode(opcode),
      .carry(carry)
  );

  // Initialize signals
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
    clk = 0;
    rst = 1;
    a = 0;
    b = 0;
    precision = 0;
    opcode = 0;
    test_passed = 1;
    #1 rst = 0;
  end

  // Task to calculate the expected result
  task compute_expected_result;
    input [BITS-1:0] a_in, b_in;
    input [3:0] opcode_in;
    input [1:0] precision;
    output [BITS-1:0] result_out;
    begin
      case (opcode_in)
        4'b0000: result_out = a_in & b_in;  // AND
        4'b0001: result_out = a_in | b_in;  // OR
        4'b0010: result_out = a_in ^ b_in;  // XOR
        4'b0011: // ADD with precision handling
                begin
          if (precision == 2'b11) result_out = a_in + b_in;
          else if (precision == 2'b00) begin
            result_out[7:0]   = a_in[7:0] + b_in[7:0];
            result_out[15:8]  = a_in[15:8] + b_in[15:8];
            result_out[23:16] = a_in[23:16] + b_in[23:16];
            result_out[31:24] = a_in[31:24] + b_in[31:24];
            result_out[39:32] = a_in[39:32] + b_in[39:32];
            result_out[47:40] = a_in[47:40] + b_in[47:40];
            result_out[55:48] = a_in[55:48] + b_in[55:48];
            result_out[63:56] = a_in[63:56] + b_in[63:56];
          end else if (precision == 2'b01) begin
            result_out[15:0]  = a_in[15:0] + b_in[15:0];
            result_out[31:16] = a_in[31:16] + b_in[31:16];
            result_out[47:32] = a_in[47:32] + b_in[47:32];
            result_out[63:48] = a_in[63:48] + b_in[63:48];
          end else if (precision == 2'b10) begin
            result_out[31:0]  = a_in[31:0] + b_in[31:0];
            result_out[63:32] = a_in[63:32] + b_in[63:32];

          end
        end
        4'b0100: // set equal
                begin
          if (precision == 2'b11) result_out = (a_in == b_in) ? 1 : 0;
          else if (precision == 2'b00) begin
            result_out[7:0]   = (a_in[7:0] == b_in[7:0]) ? 8'd1 : 8'd0;
            result_out[15:8]  = (a_in[15:8] == b_in[15:8]) ? 8'd1 : 8'd0;
            result_out[23:16] = (a_in[23:16] == b_in[23:16]) ? 8'd1 : 8'd0;
            result_out[31:24] = (a_in[31:24] == b_in[31:24]) ? 8'd1 : 8'd0;
            result_out[39:32] = (a_in[39:32] == b_in[39:32]) ? 8'd1 : 8'd0;
            result_out[47:40] = (a_in[47:40] == b_in[47:40]) ? 8'd1 : 8'd0;
            result_out[55:48] = (a_in[55:48] == b_in[55:48]) ? 8'd1 : 8'd0;
            result_out[63:56] = (a_in[63:56] == b_in[63:56]) ? 8'd1 : 8'd0;
          end else if (precision == 2'b01) begin
            result_out[15:0]  = (a_in[15:0] == b_in[15:0]) ? 16'd1 : 16'd0;
            result_out[31:16] = (a_in[31:16] == b_in[31:16]) ? 16'd1 : 16'd0;
            result_out[47:32] = (a_in[47:32] == b_in[47:32]) ? 16'd1 : 16'd0;
            result_out[63:48] = (a_in[63:48] == b_in[63:48]) ? 16'd1 : 16'd0;
          end else if (precision == 2'b10) begin
            result_out[31:0]  = (a_in[31:0] == b_in[31:0]) ? 32'd1 : 32'd0;
            result_out[63:32] = (a_in[63:32] == b_in[63:32]) ? 32'd1 : 32'd0;

          end
        end

        4'b0101: // set equal
                begin
          if (precision == 2'b11) result_out = (a_in != b_in) ? 1 : 0;
          else if (precision == 2'b00) begin
            result_out[7:0]   = (a_in[7:0] != b_in[7:0]) ? 8'd1 : 8'd0;
            result_out[15:8]  = (a_in[15:8] != b_in[15:8]) ? 8'd1 : 8'd0;
            result_out[23:16] = (a_in[23:16] != b_in[23:16]) ? 8'd1 : 8'd0;
            result_out[31:24] = (a_in[31:24] != b_in[31:24]) ? 8'd1 : 8'd0;
            result_out[39:32] = (a_in[39:32] != b_in[39:32]) ? 8'd1 : 8'd0;
            result_out[47:40] = (a_in[47:40] != b_in[47:40]) ? 8'd1 : 8'd0;
            result_out[55:48] = (a_in[55:48] != b_in[55:48]) ? 8'd1 : 8'd0;
            result_out[63:56] = (a_in[63:56] != b_in[63:56]) ? 8'd1 : 8'd0;
          end else if (precision == 2'b01) begin
            result_out[15:0]  = (a_in[15:0] != b_in[15:0]) ? 16'd1 : 16'd0;
            result_out[31:16] = (a_in[31:16] != b_in[31:16]) ? 16'd1 : 16'd0;
            result_out[47:32] = (a_in[47:32] != b_in[47:32]) ? 16'd1 : 16'd0;
            result_out[63:48] = (a_in[63:48] != b_in[63:48]) ? 16'd1 : 16'd0;
          end else if (precision == 2'b10) begin
            result_out[31:0]  = (a_in[31:0] != b_in[31:0]) ? 32'd1 : 32'd0;
            result_out[63:32] = (a_in[63:32] != b_in[63:32]) ? 32'd1 : 32'd0;

          end
        end
        4'b0110: // SUB with precision handling
                begin
          if (precision == 2'b11) result_out = a_in - b_in;
          else if (precision == 2'b00) begin
            result_out[7:0]   = a_in[7:0] - b_in[7:0];
            result_out[15:8]  = a_in[15:8] - b_in[15:8];
            result_out[23:16] = a_in[23:16] - b_in[23:16];
            result_out[31:24] = a_in[31:24] - b_in[31:24];
            result_out[39:32] = a_in[39:32] - b_in[39:32];
            result_out[47:40] = a_in[47:40] - b_in[47:40];
            result_out[55:48] = a_in[55:48] - b_in[55:48];
            result_out[63:56] = a_in[63:56] - b_in[63:56];
          end else if (precision == 2'b01) begin
            result_out[15:0]  = a_in[15:0] - b_in[15:0];
            result_out[31:16] = a_in[31:16] - b_in[31:16];
            result_out[47:32] = a_in[47:32] - b_in[47:32];
            result_out[63:48] = a_in[63:48] - b_in[63:48];
          end else if (precision == 2'b10) begin
            result_out[31:0]  = a_in[31:0] - b_in[31:0];
            result_out[63:32] = a_in[63:32] - b_in[63:32];


          end
        end
        4'b1000: // Averaging ADD with precision handling
                begin
          if (precision == 2'b11) result_out = (a_in + b_in) >> 1;
          else if (precision == 2'b00) begin
            result_out[7:0]   = (a_in[7:0] + b_in[7:0]) >> 1;
            result_out[15:8]  = (a_in[15:8] + b_in[15:8]) >> 1;
            result_out[23:16] = (a_in[23:16] + b_in[23:16]) >> 1;
            result_out[31:24] = (a_in[31:24] + b_in[31:24]) >> 1;
            result_out[39:32] = (a_in[39:32] + b_in[39:32]) >> 1;
            result_out[47:40] = (a_in[47:40] + b_in[47:40]) >> 1;
            result_out[55:48] = (a_in[55:48] + b_in[55:48]) >> 1;
            result_out[63:56] = (a_in[63:56] + b_in[63:56]) >> 1;
          end else if (precision == 2'b01) begin
            result_out[15:0]  = (a_in[15:0] + b_in[15:0]) >> 1;
            result_out[31:16] = (a_in[31:16] + b_in[31:16]) >> 1;
            result_out[47:32] = (a_in[47:32] + b_in[47:32]) >> 1;
            result_out[63:48] = (a_in[63:48] + b_in[63:48]) >> 1;
          end else if (precision == 2'b10) begin
            result_out[31:0]  = (a_in[31:0] + b_in[31:0]) >> 1;
            result_out[63:32] = (a_in[63:32] + b_in[63:32]) >> 1;

          end
        end

        4'b0111: // Averaging SUB with precision handling
                begin
          if (precision == 2'b11) result_out = (a_in - b_in) >> 1;
          else if (precision == 2'b00) begin
            result_out[7:0]   = (a_in[7:0] - b_in[7:0]) >> 1;
            result_out[15:8]  = (a_in[15:8] - b_in[15:8]) >> 1;
            result_out[23:16] = (a_in[23:16] - b_in[23:16]) >> 1;
            result_out[31:24] = (a_in[31:24] - b_in[31:24]) >> 1;
            result_out[39:32] = (a_in[39:32] - b_in[39:32]) >> 1;
            result_out[47:40] = (a_in[47:40] - b_in[47:40]) >> 1;
            result_out[55:48] = (a_in[55:48] - b_in[55:48]) >> 1;
            result_out[63:56] = (a_in[63:56] - b_in[63:56]) >> 1;
          end else if (precision == 2'b01) begin
            result_out[15:0]  = (a_in[15:0] - b_in[15:0]) >> 1;
            result_out[31:16] = (a_in[31:16] - b_in[31:16]) >> 1;
            result_out[47:32] = (a_in[47:32] - b_in[47:32]) >> 1;
            result_out[63:48] = (a_in[63:48] - b_in[63:48]) >> 1;
          end else if (precision == 2'b10) begin
            result_out[31:0]  = (a_in[31:0] - b_in[31:0]) >> 1;
            result_out[63:32] = (a_in[63:32] - b_in[63:32]) >> 1;

          end
        end
        4'b1001: //  MAX operation
                begin
          if (precision == 2'b11) result_out = ($signed(a_in) < $signed(b_in)) ? b_in : a_in;
          else if (precision == 2'b00) begin
            result_out[7:0] = ($signed(a_in[7:0]) < $signed(b_in[7:0])) ? b_in[7:0] : a_in[7:0];
            result_out[15:8] = ($signed(a_in[15:8]) < $signed(b_in[15:8])) ? b_in[15:8] :
                a_in[15:8];
            result_out[23:16] = ($signed(a_in[23:16]) < $signed(b_in[23:16])) ? b_in[23:16] :
                a_in[23:16];
            result_out[31:24] = ($signed(a_in[31:24]) < $signed(b_in[31:24])) ? b_in[31:24] :
                a_in[31:24];
            result_out[39:32] = ($signed(a_in[39:32]) < $signed(b_in[39:32])) ? b_in[39:32] :
                a_in[39:32];
            result_out[47:40] = ($signed(a_in[47:40]) < $signed(b_in[47:40])) ? b_in[47:40] :
                a_in[47:40];
            result_out[55:48] = ($signed(a_in[55:48]) < $signed(b_in[55:48])) ? b_in[55:48] :
                a_in[55:48];
            result_out[63:56] = ($signed(a_in[63:56]) < $signed(b_in[63:56])) ? b_in[63:56] :
                a_in[63:56];
          end else if (precision == 2'b01) begin
            result_out[15:0] = ($signed(a_in[15:0]) < $signed(b_in[15:0])) ? b_in[15:0] :
                a_in[15:0];
            result_out[31:16] = ($signed(a_in[31:16]) < $signed(b_in[31:16])) ? b_in[31:16] :
                a_in[31:16];
            result_out[47:32] = ($signed(a_in[47:32]) < $signed(b_in[47:32])) ? b_in[47:32] :
                a_in[47:32];
            result_out[63:48] = ($signed(a_in[63:48]) < $signed(b_in[63:48])) ? b_in[63:48] :
                a_in[63:48];
          end else if (precision == 2'b10) begin
            result_out[31:0] = ($signed(a_in[31:0]) < $signed(b_in[31:0])) ? b_in[31:0] :
                a_in[31:0];
            result_out[63:32] = ($signed(a_in[63:32]) < $signed(b_in[63:32])) ? b_in[63:32] :
                a_in[63:32];

          end
        end

        4'b1010: begin  // MIN operation 

          if (precision == 2'b11) result_out = ($signed(a_in) > $signed(b_in)) ? b_in : a_in;
          else if (precision == 2'b00) begin
            result_out[7:0] = ($signed(a_in[7:0]) > $signed(b_in[7:0])) ? b_in[7:0] : a_in[7:0];
            result_out[15:8] = ($signed(a_in[15:8]) > $signed(b_in[15:8])) ? b_in[15:8] :
                a_in[15:8];
            result_out[23:16] = ($signed(a_in[23:16]) > $signed(b_in[23:16])) ? b_in[23:16] :
                a_in[23:16];
            result_out[31:24] = ($signed(a_in[31:24]) > $signed(b_in[31:24])) ? b_in[31:24] :
                a_in[31:24];
            result_out[39:32] = ($signed(a_in[39:32]) > $signed(b_in[39:32])) ? b_in[39:32] :
                a_in[39:32];
            result_out[47:40] = ($signed(a_in[47:40]) > $signed(b_in[47:40])) ? b_in[47:40] :
                a_in[47:40];
            result_out[55:48] = ($signed(a_in[55:48]) > $signed(b_in[55:48])) ? b_in[55:48] :
                a_in[55:48];
            result_out[63:56] = ($signed(a_in[63:56]) > $signed(b_in[63:56])) ? b_in[63:56] :
                a_in[63:56];
          end else if (precision == 2'b01) begin
            result_out[15:0] = ($signed(a_in[15:0]) > $signed(b_in[15:0])) ? b_in[15:0] :
                a_in[15:0];
            result_out[31:16] = ($signed(a_in[31:16]) > $signed(b_in[31:16])) ? b_in[31:16] :
                a_in[31:16];
            result_out[47:32] = ($signed(a_in[47:32]) > $signed(b_in[47:32])) ? b_in[47:32] :
                a_in[47:32];
            result_out[63:48] = ($signed(a_in[63:48]) > $signed(b_in[63:48])) ? b_in[63:48] :
                a_in[63:48];
          end else if (precision == 2'b10) begin
            result_out[31:0] = ($signed(a_in[31:0]) > $signed(b_in[31:0])) ? b_in[31:0] :
                a_in[31:0];
            result_out[63:32] = ($signed(a_in[63:32]) > $signed(b_in[63:32])) ? b_in[63:32] :
                a_in[63:32];

          end
        end
      endcase
    end
  endtask



  /*     
        
        4'b0111: result_out = (a_in + b_in) >> 1; // Average ADD
        4'b1000: result_out = (a_in - b_in) >> 1; // Average SUB
        default: result_out = 0;  */


  // Testbench logic
  initial begin
    integer i;
    for (i = 0; i < 4000; i = i + 1) begin
      // Generate random inputs
      a = $random;
      b = $random;
      precision = $random % (1 << PRECISION_BITS);
      opcode = ($random % 11) & 4'b1111;  // Mask to 4 bits explicitly

      @(posedge clk) begin
        expected_result1 = expected_result;
      end
      // Compute expected result
      compute_expected_result(a, b, opcode, precision, expected_result);

      // Apply inputs to DUT
      @(posedge clk);
      #1;  // Small delay for stability

      // Check the result
      if (result_final !== expected_result) begin
        $display("TEST FAILED: a=%h, b=%h, opcode=%b,precision=%b, result=%h (expected=%h)", a, b,
                 opcode, precision, result_final, expected_result);
        test_passed = 0;
        $stop;
      end else begin
        $display("TEST PASSED: aa=%d,bb=%d,rr=%d,a=%h, b=%h, opcode=%b,precision=%b, result=%h",
                 a[31:16], b[31:16], result_final[31:16], a, b, opcode, precision, result_final);
      end
    end

    if (test_passed) begin
      $display("All tests passed!");
    end else begin
      $display("Some tests failed!");
    end
    $finish;
  end

endmodule





