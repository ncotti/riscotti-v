`include "data_types.svh"

module alu
    import data_types::*;
#(
    int WIDTH = 32
) (
    input logic signed [WIDTH-1:0] op1,
    input logic signed [WIDTH-1:0] op2,
    input alu_mode_t mode,
    output logic signed [WIDTH-1:0] out,
    output logic div_by_zero
);
    timeunit 1ns; timeprecision 1ns;

    always_comb begin
        case (mode)
            ALU_ADD: out = op1 + op2;
            ALU_SUB: out = op1 - op2;
            ALU_MUL: out = op1 * op2;
            ALU_DIV: out = (op2 == 0) ? 'sd0 : op1 / op2;
            ALU_XOR: out = op1 ^ op2;
            ALU_OR: out = op1 | op2;
            ALU_AND: out = op1 & op2;
            ALU_SLL: out = op1 << op2;
            ALU_SRL: out = op1 >> op2;
            ALU_SRA: out = op1 >>> op2;
            ALU_SLT: out = (op1 < op2) ? 32'sd1 : 32'sd0;
            ALU_SLTU: out = (unsigned'(op1) < unsigned'(op2)) ? 32'sd1 : 32'sd0;
            default: out = '0;
        endcase
    end

    assign div_by_zero = (op2 == 0) & (mode == ALU_DIV);

endmodule : alu

