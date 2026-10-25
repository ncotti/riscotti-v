`include "isa.svh"
`include "data_types.svh"

module decoder
import data_types::*;
import isa::*;
(
    input logic [31:0] op,
    output alu_mode_t alu_mode,
    output logic [4:0] rs1_idx,
    output logic [4:0] rs2_idx,
    output logic [4:0] rd_idx,
    output logic [31:0] imm,
    output logic valid_imm,
    output logic valid_op
);
    import isa::*;

    timeunit 1ns; timeprecision 1ns;

    logic [OP_WIDTH-1:0] op_code;
    opcode_t opcode;
    logic [FUNCT3_WIDTH-1:0] funct3;
    logic [FUNCT7_WIDTH-1:0] funct7;

    assign opcode = opcode_t'(op[6:0]);
    assign funct3 = op[14:12];
    assign funct7 = op[31:25];

    assign op_code = {funct7, funct3, opcode};

    always_comb begin
        valid_op = 1'b1;

        case (opcode)
            R_TYPE: begin
                rs1_idx = op[19:15];
                rs2_idx = op[24:20];
                rd_idx = op[11:7];
                valid_imm = 0;
                imm = '0;
            end
            I_TYPE1, I_TYPE2, I_TYPE3, I_TYPE4: begin
                rs1_idx = op[19:15];
                rs2_idx = '0;
                rd_idx = op[11:7];
                valid_imm = 1;
                imm = (funct3 != 3'h5) ? {20'b0, op[31:20]} : {27'b0, op[24:20]};
            end
            S_TYPE: begin
                rs1_idx = op[19:15];
                rs2_idx = op[24:20];
                rd_idx = '0;
                valid_imm = 1;
                imm = {20'b0, op[31:25], op[11:7]};
            end
            B_TYPE: begin
                rs1_idx = op[19:15];
                rs2_idx = op[24:20];
                rd_idx = '0;
                valid_imm = 1;
                imm = {19'b0, op[31], op[7], op[30:25], op[11:8], 1'b0};
            end
            U_TYPE1, U_TYPE2: begin
                rs1_idx = '0;
                rs2_idx = '0;
                rd_idx = op[11:7];
                valid_imm = 1;
                imm = {op[31:12], 12'b0};
            end
            J_TYPE: begin
                rs1_idx = '0;
                rs2_idx = '0;
                rd_idx = op[11:7];
                valid_imm = 1;
                imm = {11'b0, op[31], op[19:12], op[20], op[30:21], 1'b0};
            end
            FENCE: begin
                rs1_idx = op[19:15];
                rs2_idx = '0;
                rd_idx = op[11:7];
                valid_imm = 0;
                imm = '0;
            end

            default: begin
                rs1_idx = '0;
                rs2_idx = '0;
                rd_idx = '0;
                valid_op = 1'b0;
            end
        endcase

        alu_mode = ALU_ADD;

        case (op_code)
            OP_ADD, OP_ADDI, OP_LB, OP_LH, OP_LW, OP_LBU, OP_LHU, OP_SB, OP_SH, OP_SW, OP_BEQ, OP_BNE, OP_BLT, OP_BGE, OP_BLTU, OP_BGEU: alu_mode = ALU_ADD;
            OP_SUB: alu_mode = ALU_SUB;
            OP_XOR, OP_XORI: alu_mode = ALU_XOR;
            OP_OR, OP_ORI: alu_mode = ALU_OR;
            OP_AND, OP_ANDI: alu_mode = ALU_AND;
            OP_SLL, OP_SLLI: alu_mode = ALU_SLL;
            OP_SRL, OP_SRLI: alu_mode = ALU_SRL;
            OP_SRA, OP_SRAI: alu_mode = ALU_SRA;
            OP_SLT, OP_SLTI: alu_mode = ALU_SLT;
            OP_SLTU, OP_SLTIU: alu_mode = ALU_SLTU;
            OP_MUL: alu_mode = ALU_MUL;
            OP_MULH: alu_mode = ALU_MULH;
            OP_MULHSU: alu_mode = ALU_MULHSU;
            OP_MULHU: alu_mode = ALU_MULHU;
            OP_DIV: alu_mode = ALU_DIV;
            OP_DIVU: alu_mode = ALU_DIVU;
            OP_REM: alu_mode = ALU_REM;
            OP_REMU: alu_mode = ALU_REMU;
            default: valid_op = 1'b0;
        endcase
    end



endmodule : decoder
