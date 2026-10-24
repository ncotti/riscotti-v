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
            ADD: out = op1 + op2;
            SUB: out = op1 - op2;
            MUL: out = op1 * op2;
            DIV: out = (op2 == 0) ? 'sd0 : op1 / op2;
            XOR: out = op1 ^ op2;
            OR: out = op1 | op2;
            AND: out = op1 & op2;
            SLL: out = op1 << op2;
            SRL: out = op1 >> op2;
            SRA: out = op1 >>> op2;
            default: out = '0;
        endcase
    end

    assign div_by_zero = (op2 == 0) & (mode == DIV);

endmodule : alu

