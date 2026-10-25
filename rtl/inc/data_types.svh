`ifndef ALU_H_
`define ALU_H_

package data_types;

timeunit 1ns; timeprecision 1ns;

typedef enum logic [3:0] {
    ALU_ADD = 4'b0000,
    ALU_SUB = 4'b0001,
    ALU_MUL = 4'b0010,
    ALU_DIV = 4'b0011,
    ALU_XOR = 4'b0100,
    ALU_OR  = 4'b0101,
    ALU_AND = 4'b0110,
    ALU_SLL = 4'b0111,
    ALU_SRL = 4'b1000,
    ALU_SRA = 4'b1001,
    ALU_SLT = 4'b1010,
    ALU_SLTU = 4'b1011,
    ALU_REM = 4'b1100
} alu_mode_t;

endpackage: data_types

`endif // ALU_H_
