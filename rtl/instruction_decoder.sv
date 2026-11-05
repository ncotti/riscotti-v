`include "isa.svh"
`include "data_types.svh"

/// @brief Given a valid RV32IM instruction, decodes the instruction
/// and returns all required information to execute it in the next stage.
///
/// @param op RV32IM instruction.
/// @param op_valid Whether the `op` argument is a valid RV32IM instruction or not.
/// @param alu_mode ALU operation to be performed for this instruction.
/// @param rs1_idx Source 1 register index.
/// @param rs2_idx Source 2 register index.
/// @param rd_idx Destination register index.
/// @param imm Immediate value.
/// @param imm_enable Whether the second ALU operation should be the `imm` or
/// the `rs2`.
/// @param load_mode Indicates whether the instruction loads a value from
/// memory, or `LM_NONE`.
/// @param we Write enable. Each bit indicates whether the given byte should be
/// written into the memory. E.g.: `we = 0b0001` writes a byte, `we = 0b0011`
/// writes a half-word and `we = 0b1111` writes a word.
/// @param branch_mode Indicates whether the instruction is a branch for the
/// program counter, or `BM_NONE`.
module instruction_decoder
    import data_types::*;
    import isa::*;
(
    input logic [31:0] op,
    output logic op_valid,
    output alu_mode_t alu_mode,
    output logic [4:0] rs1_idx,
    output logic [4:0] rs2_idx,
    output logic [4:0] rd_idx,
    output logic [31:0] imm,
    output logic imm_enable,
    output load_mode_t load_mode,
    output logic [3:0] we,
    output branch_mode_t branch_mode,
    output logic pc_enable
);
    import isa::*;

    timeunit 1ns; timeprecision 1ns;

    opcode_t opcode;
    logic [Funct3Width-1:0] funct3;
    logic [Funct7Width-1:0] funct7;

    r_mode_t r_mode;
    ialu_mode_t ialu_mode;

    assign opcode = opcode_t'(op[6:0]);
    assign funct3 = op[14:12];
    assign funct7 = op[31:25];

    assign r_mode = r_mode_t'({funct7, funct3});
    assign ialu_mode = ialu_mode_t'(funct3);

    assign load_mode = (opcode == I_TYPE_LOAD) ? load_mode_t'(funct3) : LM_NONE;
    assign branch_mode = (opcode == B_TYPE) ? branch_mode_t'(funct3) : BM_NONE;

    always_comb begin
        op_valid = 1'b1;
        alu_mode = ALU_ADD;
        we = 4'b0000;

        case (opcode)
            R_TYPE: begin
                rs1_idx = op[19:15];
                rs2_idx = op[24:20];
                rd_idx = op[11:7];
                imm_enable = 0;
                pc_enable = 0;
                imm = '0;
                case (r_mode)
                    RM_ADD: alu_mode = ALU_ADD;
                    RM_SUB: alu_mode = ALU_SUB;
                    RM_XOR: alu_mode = ALU_XOR;
                    RM_OR: alu_mode = ALU_OR;
                    RM_AND: alu_mode = ALU_AND;
                    RM_SLL: alu_mode = ALU_SLL;
                    RM_SRL: alu_mode = ALU_SRL;
                    RM_SRA: alu_mode = ALU_SRA;
                    RM_SLT: alu_mode = ALU_SLT;
                    RM_SLTU: alu_mode = ALU_SLTU;
                    RM_MUL: alu_mode = ALU_MUL;
                    RM_MULH: alu_mode = ALU_MULH;
                    RM_MULHSU: alu_mode = ALU_MULHSU;
                    RM_MULHU: alu_mode = ALU_MULHU;
                    RM_DIV: alu_mode = ALU_DIV;
                    RM_DIVU: alu_mode = ALU_DIVU;
                    RM_REM: alu_mode = ALU_REM;
                    RM_REMU: alu_mode = ALU_REMU;
                    default: op_valid = 1'b0;
                endcase
            end
            I_TYPE_ALU: begin
                rs1_idx = op[19:15];
                rs2_idx = '0;
                rd_idx = op[11:7];
                imm_enable = 1;
                pc_enable = 0;
                imm = (ialu_mode != IALU_SLL && ialu_mode != IALU_SRX) ?
                    {20'b0, op[31:20]} : {27'b0, op[24:20]};

                // For SLL and SRX, funct7 must be exactly 0x00 or 0x20.
                op_valid = !((ialu_mode == IALU_SLL && funct7 != 0) ||
                    (ialu_mode == IALU_SRX && !(funct7 == 0 || funct7 == 'h20)));

                unique case (ialu_mode)
                    IALU_ADD: alu_mode = ALU_ADD;
                    IALU_SLL: alu_mode = ALU_SLL;
                    IALU_SLT: alu_mode = ALU_SLT;
                    IALU_SLTU: alu_mode = ALU_SLTU;
                    IALU_XOR: alu_mode = ALU_XOR;
                    IALU_SRX: alu_mode = (funct7 == 0) ? ALU_SRL : ALU_SRA;
                    IALU_OR: alu_mode = ALU_OR;
                    IALU_AND: alu_mode = ALU_AND;
                endcase
            end
            I_TYPE_LOAD: begin
                rs1_idx = op[19:15];
                rs2_idx = '0;
                rd_idx = op[11:7];
                imm_enable = 1;
                pc_enable = 0;
                imm = {20'b0, op[31:20]};
                alu_mode = ALU_ADD;

                // We are not using the `load_mode` variable here
                // because all combinations that are not part of the
                // LM_X enum, not only the `LM_NONE`, are invalid
                // instructions.
                case (load_mode_t'(funct3))
                    LM_B, LM_H, LM_W, LM_BU, LM_HU: op_valid = 1'b1;
                    default: op_valid = 1'b0;
                endcase
            end
            I_TYPE_JUMP: begin
                rs1_idx = op[19:15];
                rs2_idx = '0;
                rd_idx = op[11:7];
                imm_enable = 1;
                pc_enable = 1;
                imm = (funct3 != 3'h5) ? {20'b0, op[31:20]} : {27'b0, op[24:20]};
            end
            I_TYPE_ENV: begin
                rs1_idx = op[19:15];
                rs2_idx = '0;
                rd_idx = op[11:7];
                imm_enable = 1;
                pc_enable = 0;
                imm = (funct3 != 3'h5) ? {20'b0, op[31:20]} : {27'b0, op[24:20]};
            end
            S_TYPE: begin
                rs1_idx = op[19:15];
                rs2_idx = op[24:20];
                rd_idx = '0;
                imm_enable = 1;
                pc_enable = 0;
                imm = {20'b0, op[31:25], op[11:7]};
                alu_mode = ALU_ADD;

                // We are not using the `store_mode` variable here
                // because all combinations that are not part of the
                // SM_X enum, not only the `SM_NONE`, are invalid
                // instructions.
                case (funct3)
                    SM_B: begin
                        op_valid = 1'b1;
                        we = 4'b0001;
                    end
                    SM_H: begin
                        op_valid = 1'b1;
                        we = 4'b0011;
                    end
                    SM_W: begin
                        op_valid = 1'b1;
                        we = 4'b1111;
                    end
                    default: begin
                        op_valid = 1'b0;
                        we = 4'b0000;
                    end
                endcase
            end
            B_TYPE: begin
                rs1_idx = op[19:15];
                rs2_idx = op[24:20];
                rd_idx = '0;
                imm_enable = 1;
                pc_enable = 1;
                imm = {19'b0, op[31], op[7], op[30:25], op[11:8], 1'b0};
                alu_mode = ALU_ADD;

                // We are not using the `branch_mode` variable here
                // because all combinations that are not part of the
                // BM_X enum, not only the `SM_NONE`, are invalid
                // instructions.
                case (branch_mode_t'(funct3))
                    BM_EQ, BM_NE, BM_LT, BM_GE, BM_LTU, BM_GEU: op_valid = 1'b1;
                    default: op_valid = 1'b0;
                endcase
            end
            U_TYPE_LUI: begin
                rs1_idx = '0;
                rs2_idx = '0;
                rd_idx = op[11:7];
                imm_enable = 1;
                pc_enable = 0;
                imm = {op[31:12], 12'b0};
                alu_mode = ALU_ADD;
            end
            U_TYPE_AUIPC: begin
                rs1_idx = '0;
                rs2_idx = '0;
                rd_idx = op[11:7];
                imm_enable = 1;
                pc_enable = 1;
                imm = {op[31:12], 12'b0};
            end
            J_TYPE: begin
                rs1_idx = '0;
                rs2_idx = '0;
                rd_idx = op[11:7];
                pc_enable = 0;
                imm_enable = 1;
                imm = {11'b0, op[31], op[19:12], op[20], op[30:21], 1'b0};
            end
            FENCE_TYPE: begin
                rs1_idx = op[19:15];
                rs2_idx = '0;
                rd_idx = op[11:7];
                imm_enable = 0;
                pc_enable = 0;
                imm = '0;
            end

            default: begin
                rs1_idx = '0;
                rs2_idx = '0;
                rd_idx = '0;
                op_valid = 1'b0;
                imm_enable = 0;
                pc_enable = 0;
                imm = '0;
            end
        endcase
    end



endmodule : instruction_decoder
