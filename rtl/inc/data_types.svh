`ifndef ALU_H_
`define ALU_H_

package data_types;

timeunit 1ns; timeprecision 1ns;

typedef enum logic [4:0] {
    ALU_ADD = 5'd0,
    ALU_SUB = 5'd1,
    ALU_MUL = 5'd2,
    ALU_DIV = 5'd3,
    ALU_XOR = 5'd4,
    ALU_OR  = 5'd5,
    ALU_AND = 5'd6,
    ALU_SLL = 5'd7,
    ALU_SRL = 5'd8,
    ALU_SRA = 5'd9,
    ALU_SLT = 5'd10,
    ALU_SLTU = 5'd11,
    ALU_REM = 5'd12,
    ALU_MULH = 5'd13,
    ALU_MULHSU = 5'd14,
    ALU_MULU = 5'd15,
    ALU_DIVU = 5'd16,
    ALU_REMU = 5'd17,
    ALU_MULHU = 5'd18
} alu_mode_t;

endpackage: data_types

`endif // ALU_H_
