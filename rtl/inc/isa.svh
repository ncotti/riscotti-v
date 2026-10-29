`ifndef ISA_H_
`define ISA_H_

package isa;

    timeunit 1ns; timeprecision 1ns;

    localparam int OpcodeWidth = 7;
    localparam int Funct3Width = 3;
    localparam int Funct7Width = 7;
    localparam int OpWidth = OpcodeWidth + Funct3Width + Funct7Width;

    typedef enum logic [OpcodeWidth-1:0] {
        R_TYPE  = 7'b0110011,
        I_TYPE1 = 7'b0010011,
        I_TYPE2 = 7'b0000011,
        I_TYPE3 = 7'b1100111,
        I_TYPE4 = 7'b1110011,
        S_TYPE  = 7'b0100011,
        B_TYPE  = 7'b1100011,
        U_TYPE1 = 7'b0110111,
        U_TYPE2 = 7'b0010111,
        J_TYPE  = 7'b1101111,
        FENCE   = 7'b0001111
    } opcode_t;

    typedef enum logic [Funct3Width-1:0] {
        BM_EQ   = 3'h0,
        BM_NE   = 3'h1,
        BM_NONE = 3'h2,
        BM_LT   = 3'h4,
        BM_GE   = 3'h5,
        BM_LTU  = 3'h6,
        BM_GEU  = 3'h7
    } branch_mode_t;

    typedef enum logic [1:0] {
        SM_B = 2'h0,
        SM_H = 2'h1,
        SM_W = 2'h2,
        SM_NONE = 2'h3
    } store_mode_t;

    typedef enum logic [Funct3Width-1:0] {
        LM_B = 3'h0,
        LM_H = 3'h1,
        LM_W = 3'h2,
        LM_BU = 3'h4,
        LM_HU = 3'h5,
        LM_NONE = 3'h7
    } load_mode_t;

    typedef enum logic [Funct7Width + Funct3Width - 1:0] {
        RM_ADD  = {Funct7Width'(8'h00), Funct3Width'(4'h0)},
        RM_SUB  = {Funct7Width'(8'h20), Funct3Width'(4'h0)},
        RM_XOR  = {Funct7Width'(8'h00), Funct3Width'(4'h4)},
        RM_OR   = {Funct7Width'(8'h00), Funct3Width'(4'h6)},
        RM_AND  = {Funct7Width'(8'h00), Funct3Width'(4'h7)},
        RM_SLL  = {Funct7Width'(8'h00), Funct3Width'(4'h1)},
        RM_SRL  = {Funct7Width'(8'h00), Funct3Width'(4'h5)},
        RM_SRA  = {Funct7Width'(8'h20), Funct3Width'(4'h5)},
        RM_SLT  = {Funct7Width'(8'h00), Funct3Width'(4'h2)},
        RM_SLTU = {Funct7Width'(8'h00), Funct3Width'(4'h3)},

        RM_MUL = {Funct7Width'(8'h01), Funct3Width'(4'h0)},
        RM_MULH = {Funct7Width'(8'h01), Funct3Width'(4'h1)},
        RM_MULHSU = {Funct7Width'(8'h01), Funct3Width'(4'h2)},
        RM_MULHU = {Funct7Width'(8'h01), Funct3Width'(4'h3)},
        RM_DIV = {Funct7Width'(8'h01), Funct3Width'(4'h4)},
        RM_DIVU = {Funct7Width'(8'h01), Funct3Width'(4'h5)},
        RM_REM = {Funct7Width'(8'h01), Funct3Width'(4'h6)},
        RM_REMU = {Funct7Width'(8'h01), Funct3Width'(4'h7)}
    } r_mode_t;

    typedef enum logic [OpWidth-1:0] {
        OP_ADDI  = {Funct7Width'(8'h00), Funct3Width'(4'h0), I_TYPE1},
        OP_XORI  = {Funct7Width'(8'h00), Funct3Width'(4'h4), I_TYPE1},
        OP_ORI   = {Funct7Width'(8'h00), Funct3Width'(4'h6), I_TYPE1},
        OP_ANDI  = {Funct7Width'(8'h00), Funct3Width'(4'h7), I_TYPE1},
        OP_SLLI  = {Funct7Width'(8'h00), Funct3Width'(4'h1), I_TYPE1},
        OP_SRLI  = {Funct7Width'(8'h00), Funct3Width'(4'h5), I_TYPE1},
        OP_SRAI  = {Funct7Width'(8'h20), Funct3Width'(4'h5), I_TYPE1},
        OP_SLTI  = {Funct7Width'(8'h00), Funct3Width'(4'h2), I_TYPE1},
        OP_SLTIU = {Funct7Width'(8'h00), Funct3Width'(4'h3), I_TYPE1},

        OP_LB  = {Funct7Width'(8'h00), Funct3Width'(4'h0), I_TYPE2},
        OP_LH  = {Funct7Width'(8'h00), Funct3Width'(4'h1), I_TYPE2},
        OP_LW  = {Funct7Width'(8'h00), Funct3Width'(4'h2), I_TYPE2},
        OP_LBU = {Funct7Width'(8'h00), Funct3Width'(4'h4), I_TYPE2},
        OP_LHU = {Funct7Width'(8'h00), Funct3Width'(4'h5), I_TYPE2},

        OP_SB = {Funct7Width'(8'h00), Funct3Width'(SM_B), S_TYPE},
        OP_SH = {Funct7Width'(8'h00), Funct3Width'(SM_H), S_TYPE},
        OP_SW = {Funct7Width'(8'h00), Funct3Width'(SM_W), S_TYPE},

        OP_BEQ  = {Funct7Width'(8'h00), BM_EQ, B_TYPE},
        OP_BNE  = {Funct7Width'(8'h00), BM_NE, B_TYPE},
        OP_BLT  = {Funct7Width'(8'h00), BM_LT, B_TYPE},
        OP_BGE  = {Funct7Width'(8'h00), BM_GE, B_TYPE},
        OP_BLTU = {Funct7Width'(8'h00), BM_LTU, B_TYPE},
        OP_BGEU = {Funct7Width'(8'h00), BM_GEU, B_TYPE},

        OP_JAL  = {Funct7Width'(8'h00), Funct3Width'(4'h0), J_TYPE},
        OP_JALR = {Funct7Width'(8'h00), Funct3Width'(4'h0), I_TYPE3},

        OP_LUI   = {Funct7Width'(8'h00), Funct3Width'(4'h0), U_TYPE1},
        OP_AUIPC = {Funct7Width'(8'h00), Funct3Width'(4'h0), U_TYPE2},

        OP_ECALL  = {Funct7Width'(8'h00), Funct3Width'(4'h0), I_TYPE4},
        OP_EBREAK = {Funct7Width'(8'h01), Funct3Width'(4'h0), I_TYPE4},
        OP_FENCE  = {Funct7Width'(8'h00), Funct3Width'(4'h0), FENCE}
    } op_t;

endpackage : isa


`endif  // ISA_H_
