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
    output load_mode_t load_mode,
    output store_mode_t store_mode,
    output branch_mode_t branch_mode,
    output logic valid_op
);
    import isa::*;

    timeunit 1ns; timeprecision 1ns;

    opcode_t opcode;
    logic [Funct3Width-1:0] funct3;
    logic [Funct7Width-1:0] funct7;

    r_mode_t r_mode;

    assign opcode = opcode_t'(op[6:0]);
    assign funct3 = op[14:12];
    assign funct7 = op[31:25];


    assign r_mode = r_mode_t'({funct7, funct3});

    assign load_mode = (opcode == I_TYPE2) ? load_mode_t'(funct3) : LM_NONE;
    assign store_mode = (opcode == S_TYPE) ? store_mode_t'(funct3[1:0]) : SM_NONE;
    assign branch_mode = (opcode == B_TYPE) ? branch_mode_t'(funct3) : BM_NONE;

    always_comb begin
        valid_op = 1'b1;
        alu_mode = ALU_ADD;

        case (opcode)
            R_TYPE: begin
                rs1_idx = op[19:15];
                rs2_idx = op[24:20];
                rd_idx = op[11:7];
                valid_imm = 0;
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
                    default: valid_op = 1'b0;
                endcase
            end
            I_TYPE1: begin
                rs1_idx = op[19:15];
                rs2_idx = '0;
                rd_idx = op[11:7];
                valid_imm = 1;
                imm = (funct3 != 3'h5) ? {20'b0, op[31:20]} : {27'b0, op[24:20]};
                if ((funct3 == 3'h1 && funct7 != 0) ||
                    (funct3 == 3'h5 && !(funct7 == 0 || funct7 == 'h20))) begin
                    valid_op = 1'b0;
                end

                unique case (funct3)
                    3'h0: alu_mode = ALU_ADD;
                    3'h1: alu_mode = ALU_SLL;
                    3'h2: alu_mode = ALU_SLT;
                    3'h3: alu_mode = ALU_SLTU;
                    3'h4: alu_mode = ALU_XOR;
                    3'h5: alu_mode = (funct7 == 0) ? ALU_SRL : ALU_SRA;
                    3'h6: alu_mode = ALU_OR;
                    3'h7: alu_mode = ALU_AND;
                endcase
            end
            I_TYPE2: begin
                rs1_idx = op[19:15];
                rs2_idx = '0;
                rd_idx = op[11:7];
                valid_imm = 1;
                imm = {20'b0, op[31:20]};
                alu_mode = ALU_ADD;
                case (load_mode_t'(funct3))
                    LM_B, LM_H, LM_W, LM_BU, LM_HU: valid_op = 1'b1;
                    default: valid_op = 1'b0;
                endcase
            end
            I_TYPE3: begin
                rs1_idx = op[19:15];
                rs2_idx = '0;
                rd_idx = op[11:7];
                valid_imm = 1;
                imm = (funct3 != 3'h5) ? {20'b0, op[31:20]} : {27'b0, op[24:20]};
            end
            I_TYPE4: begin
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
                alu_mode = ALU_ADD;

                // TODO, this is wrong. Use full size. (a value of 1 in the third bit would be an error)
                case (store_mode_t'(funct3[1:0]))
                    SM_B, SM_H, SM_W: valid_op = 1'b1;
                    default: valid_op = 1'b0;
                endcase
            end
            B_TYPE: begin
                rs1_idx = op[19:15];
                rs2_idx = op[24:20];
                rd_idx = '0;
                valid_imm = 1;
                imm = {19'b0, op[31], op[7], op[30:25], op[11:8], 1'b0};
                alu_mode = ALU_ADD;
                case (branch_mode_t'(funct3))
                    BM_EQ, BM_NE, BM_LT, BM_GE, BM_LTU, BM_GEU: valid_op = 1'b1;
                    default: valid_op = 1'b0;
                endcase
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
                valid_imm = 0;
                imm = '0;
            end
        endcase
    end



endmodule : decoder
