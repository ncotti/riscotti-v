module data_hazard
    import isa::*;
(
    input logic [4:0] rs1_idx_ex,
    input logic [4:0] rs2_idx_ex,
    input logic [4:0] rd_idx_ex,
    input logic [4:0] rd_idx_mem,
    input logic [4:0] rd_idx_wb,
    input logic [31:0] alu_out,
    input logic [31:0] rd,
    input load_mode_t load_mode,
    input logic [3:0] we_in,
    input branch_mode_t branch_mode_in,
    input logic branch_enable_mem,
    output logic rs1_fe,
    output logic rs2_fe,
    output logic [31:0] rs1_forward,
    output logic [31:0] rs2_forward,
    output logic pc_stall,
    output logic [3:0] we_out,
    output logic [4:0] rd_idx_out,
    output branch_mode_t branch_mode_out,
    output logic memcpy
);

    timeunit 1ns; timeprecision 1ns;

    assign rs1_fe = (rs1_idx_ex != '0) &&
        ((rs1_idx_ex == rd_idx_mem && load_mode == LM_NONE) || (rs1_idx_ex == rd_idx_wb));
    assign rs2_fe = (rs2_idx_ex != '0) &&
        ((rs2_idx_ex == rd_idx_mem && load_mode == LM_NONE) || (rs2_idx_ex == rd_idx_wb));

    assign rs1_forward = (rs1_idx_ex == rd_idx_mem) ? alu_out : rd;
    assign rs2_forward = (rs2_idx_ex == rd_idx_mem) ? alu_out : rd;

    assign pc_stall = (load_mode != LM_NONE) &&
        (~memcpy) &&
        ((rs1_idx_ex == rd_idx_mem) || (rs2_idx_ex == rd_idx_mem));

    assign memcpy = (load_mode != LM_NONE) && (we_in != '0) &&
        (rs2_idx_ex == rd_idx_mem) &&
        (rs1_idx_ex != rd_idx_mem);

    // If pc_stall, then the current instruction will be made redundant, i.e.,
    // any write to memory, to register or branch instruction will be rendered
    // useless.
    assign we_out = (pc_stall | branch_enable_mem) ? '0 : we_in;
    assign rd_idx_out = (pc_stall | branch_enable_mem) ? '0 : rd_idx_ex;
    assign branch_mode_out = (pc_stall | branch_enable_mem) ? BM_NONE : branch_mode_in;

endmodule: data_hazard
