module data_hazard
    import isa::*;
(
    input logic [4:0] rs1_idx_ex,
    input logic [4:0] rs2_idx_ex,
    input logic [4:0] rd_idx_mem,
    input logic [4:0] rd_idx_wb,
    input logic [31:0] alu_out,
    input logic [31:0] rd,
    input load_mode_t load_mode,
    output logic rs1_forward,
    output logic rs2_forward,
    output logic [31:0] rs1_forward_value,
    output logic [31:0] rs2_forward_value,
    output logic pc_stall
);

    timeunit 1ns; timeprecision 1ns;

    assign rs1_forward = (rs1_idx_ex != '0) &&
        ((rs1_idx_ex == rd_idx_mem && load_mode == LM_NONE) || (rs1_idx_ex == rd_idx_wb));
    assign rs2_forward = (rs2_idx_ex != '0) &&
        ((rs2_idx_ex == rd_idx_mem && load_mode == LM_NONE) || (rs2_idx_ex == rd_idx_wb));

    assign rs1_forward_value = (rs1_idx_ex == rd_idx_mem) ? alu_out : rd;
    assign rs2_forward_value = (rs2_idx_ex == rd_idx_mem) ? alu_out : rd;

    assign pc_stall = (load_mode != LM_NONE) &&
        ((rs1_idx_ex == rd_idx_mem) || (rs2_idx_ex == rd_idx_mem));

endmodule: data_hazard
