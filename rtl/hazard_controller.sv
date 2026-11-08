/// @brief
///
/// @param rs1_idx_ex Register source 1's index. It is used to determine
/// whether the current instruction being executed uses a register that is
/// the destination of a future instruction in the pipeline.
/// @param rs2_idx_ex Register source 2's index. Same as `rs1_idx_ex`.
/// @param rd_idx_ex Register destination for the currently executed
/// instruction. This value is not used for detecting hazards, but rather to
/// set the value of `rd_idx_ok_ex`.
/// @param rd_idx_mem Register destination for the instruction in the MEM stage.
/// If any rs_EX matches the rd_MEM, a data hazard is detected.
/// @param rd_idx_wb Register destination for the instruction in the WB stage.
/// If any rs_EX matches the rd_WB, this means that the pipeline was previously
/// stalled, and this is a memory hazard.
/// @param alu_out_mem ALU's output. One of the possible values for the
/// forwarded source registers.
/// @param rd_wb Destination register. One of the possible values for the
/// forwarded source registers.
/// @param load_mode_mem Helps detect a "memcpy" condition. A "memcpy" happens
/// when there is a load in "MEM" and a store in "EX".
/// @param we_ex Write enable. This value is used for detecting a "memcpy"
/// condition, as well as to set the value of the `we_ok_ex` output.
/// @param branch_mode_ex Only used to set the `branch_mode_ok_ex` output.
/// @param branch_enable_mem Used to detect a control hazard. When a branch
/// is detected, all control signals should be set to zero.
/// @param rs1_fe RS1 forward enable. The value of the "rs1" operator in the
/// EX stage of the pipeline must be replaced with `rs1_forward` value.
/// @param rs2_fe RS2 forward enable. The value of the "rs2" operator in the
/// EX stage of the pipeline must be replaced with `rs2_forward` value.
/// @param rs1_forward Value to replace the `rs1` operator in the EX stage.
/// @param rs2_forward Value to replace the `rs2` operator in the EX stage.
/// @param pc_stall If asserted, then the PC must be "stalled", i.e., its
/// value should not be incremented in the next cycle.
/// @param we_ok_ex Write enable control signal. If a branch or a
/// pipeline stall is needed, it will be forcefully set to zero, to mimic a
/// "NOP" instruction.
/// @param rd_idx_ok_ex Register destination index control signal. If a branch or a
/// pipeline stall is needed, it will be forcefully set to zero, to mimic a
/// "NOP" instruction.
/// @param  branch_mode_ok_ex Branch mode control signal. If a branch or a
/// pipeline stall is needed, it will be forcefully set to zero, to mimic a
/// "NOP" instruction.
/// @param memcpy Whether a "memcpy" hazard was detected.
module hazard_controller
    import isa::*;
(
    input logic [4:0] rs1_idx_ex,
    input logic [4:0] rs2_idx_ex,
    input logic [4:0] rd_idx_ex,
    input logic [4:0] rd_idx_mem,
    input logic [4:0] rd_idx_wb,
    input logic [31:0] alu_out_mem,
    input logic [31:0] rd_wb,
    input load_mode_t load_mode_mem,
    input logic [3:0] we_ex,
    input branch_mode_t branch_mode_ex,
    input logic branch_enable_mem,
    output logic rs1_fe,
    output logic rs2_fe,
    output logic [31:0] rs1_forward,
    output logic [31:0] rs2_forward,
    output logic pc_stall,
    output logic [3:0] we_ok_ex,
    output logic [4:0] rd_idx_ok_ex,
    output branch_mode_t branch_mode_ok_ex,
    output logic memcpy
);

    timeunit 1ns; timeprecision 1ns;

    assign rs1_fe = (rs1_idx_ex != '0) &&
        ((rs1_idx_ex == rd_idx_mem && load_mode_mem == LM_NONE) || (rs1_idx_ex == rd_idx_wb));
    assign rs2_fe = (rs2_idx_ex != '0) &&
        ((rs2_idx_ex == rd_idx_mem && load_mode_mem == LM_NONE) || (rs2_idx_ex == rd_idx_wb));

    assign rs1_forward = (rs1_idx_ex == rd_idx_mem) ? alu_out_mem : rd_wb;
    assign rs2_forward = (rs2_idx_ex == rd_idx_mem) ? alu_out_mem : rd_wb;

    assign pc_stall = (load_mode_mem != LM_NONE) &&
        (~memcpy) &&
        ((rs1_idx_ex == rd_idx_mem) || (rs2_idx_ex == rd_idx_mem));

    assign memcpy = (load_mode_mem != LM_NONE) && (we_ex != '0) &&
        (rs2_idx_ex == rd_idx_mem) &&
        (rs1_idx_ex != rd_idx_mem);

    // If pc_stall, then the current instruction will be made redundant, i.e.,
    // any write to memory, to register or branch instruction will be rendered
    // useless.
    assign we_ok_ex = (pc_stall | branch_enable_mem) ? '0 : we_ex;
    assign rd_idx_ok_ex = (pc_stall | branch_enable_mem) ? '0 : rd_idx_ex;
    assign branch_mode_ok_ex = (pc_stall | branch_enable_mem) ? BM_NONE : branch_mode_ex;

endmodule: hazard_controller
