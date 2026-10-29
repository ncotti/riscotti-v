`include "data_types.svh"

module alu
    import data_types::*;
#(
    int WIDTH = 32
) (
    input logic [WIDTH-1:0] op1,
    input logic [WIDTH-1:0] op2,
    input alu_mode_t mode,
    output logic [WIDTH-1:0] out,
    output logic div_by_zero
);
    timeunit 1ns; timeprecision 1ns;

    always_comb begin
        /* verilator lint_off UNUSEDSIGNAL */
        logic [63:0] mul_64bit;
        logic [63:0] smul_64bit;

        /* verilator lint_off UNUSEDSIGNAL */
        logic [63:0] sumul_64bit, sumul_64bit_extra;
        // sop stands for "signed op"
        logic signed [31:0] sop1, sop2;

        logic [31:0] op1_extra;

        op1_extra = (op1[31] & 1'b1) ? ~op1 + 1 : op1;

        sop1 = signed'(op1);
        sop2 = signed'(op2);
        mul_64bit = op1 * op2;
        smul_64bit = sop1 * sop2;
        sumul_64bit_extra = op1_extra * op2;
        sumul_64bit = (op1[31] & 1'b1) ? ~sumul_64bit_extra + 1 : sumul_64bit_extra;

        case (mode)
            ALU_ADD: out = op1 + op2;
            ALU_SUB: out = op1 - op2;
            ALU_MUL: out = smul_64bit[31:0];
            ALU_DIV: out = (sop2 == 0) ? 'sd0 : sop1 / sop2;
            ALU_DIVU: out = (op2 == 0) ? 'sd0 : op1 / op2;
            ALU_XOR: out = op1 ^ op2;
            ALU_OR: out = op1 | op2;
            ALU_AND: out = op1 & op2;
            ALU_SLL: out = op1 << op2;
            ALU_SRL: out = op1 >> op2;
            ALU_SRA: out = sop1 >>> sop2;
            ALU_SLT: out = (sop1 < sop2) ? 32'd1 : 32'd0;
            ALU_SLTU: out = (op1 < op2) ? 32'd1 : 32'd0;
            ALU_REM: out = sop1 % sop2;
            ALU_REMU: out = op1 % op2;
            ALU_MULH: out = smul_64bit[63:32];
            ALU_MULHSU: out = sumul_64bit[63:32];
            ALU_MULHU: out = mul_64bit[63:32];
            default: out = '0;
        endcase
    end

    assign div_by_zero = (op2 == 0) & (mode == ALU_DIV || mode == ALU_DIVU
        || mode == ALU_REM || mode == ALU_REMU);

endmodule : alu

