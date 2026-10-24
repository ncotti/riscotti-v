`ifndef ALU_H_
`define ALU_H_

package data_types;

timeunit 1ns; timeprecision 1ns;

typedef enum logic [3:0] {
    ADD = 4'b0000,
    SUB = 4'b0001,
    MUL = 4'b0010,
    DIV = 4'b0011,
    XOR = 4'b0100,
    OR  = 4'b0101,
    AND = 4'b0110,
    SLL = 4'b0111,
    SRL = 4'b1000,
    SRA = 4'b1001
} alu_mode_t;

endpackage: data_types

`endif // ALU_H_
