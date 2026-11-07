`include "data_types.svh"
`include "isa.svh"

/// @brief RISC-V 5-stage pipelined processor.
/// 1. IF: Instruction fetch. Read instruction from memory.
/// 2. ID: Instruction decode. Decode read instruction.
/// 3. EX: Execute. Execute decoded instruction.
/// 4. MEM: Memory access. Load or store a value from or to memory.
/// 5. WB: Write back. Update register file.
///
/// All variables have as a suffix the name of the stage they where
/// generated.
///
/// @param clk Clock signal.
/// @param rstN Negative asserted synchronous reset.
/// @param op RV32IM instruction.
/// @param din Data read from memory in "load" instructions.
/// @param pc_if Program counter value in the IF stage.
/// @param dout Data to be stored in memory from "store" instructions.
/// @param addr Address to be read or written from memory.
/// @param we Write enable. Whether the memory address should be written or read.
module riscotti_v (
    input logic clk,
    input logic rstN,
    input logic [31:0] op,
    input logic [31:0] rdata,
    output logic [31:0] pc,
    output logic [31:0] wdata,
    output logic [31:0] addr,
    output logic [3:0] we
);
    import data_types::*;
    import isa::*;

    timeunit 1ns; timeprecision 1ns;

    logic [31:0] pc_if, pc_id, pc_ex;
    logic [31:0] pc_jump_ex, pc_jump_mem;
    logic pc_enable_id, pc_enable_ex;
    logic [31:0] op_id, op_ex;
    logic [4:0] rs1_idx_id, rs1_idx_ex;
    logic [4:0] rs2_idx_id, rs2_idx_ex;
    branch_mode_t branch_mode_id, branch_mode_ex, branch_mode_valid_ex;
    logic [31:0] imm_id, imm_ex;
    logic imm_enable_id, imm_enable_ex;
    alu_mode_t alu_mode_id, alu_mode_ex;
    load_mode_t load_mode_id, load_mode_ex, load_mode_mem, load_mode_wb;
    logic [3:0] we_id, we_ex, we_valid_ex, we_mem;
    logic [4:0] rd_idx_id, rd_idx_ex, rd_idx_valid_ex, rd_idx_mem, rd_idx_wb;
    logic [31:0] rs1_ex;
    logic [31:0] rs2_ex;
    logic [31:0] rs2_ok_ex, rs2_ok_mem;
    logic [31:0] alu_op1_ex;
    logic [31:0] alu_op2_ex;
    logic branch_enable_ex, branch_enable_mem;
    logic [31:0] alu_out_ex, alu_out_mem;
    logic [31:0] rd_wb;
    logic [31:0] rdata_wb;
    logic [31:0] wdata_mem;
    logic [31:0] addr_mem;
    logic [31:0] alu_out_mux_mem, alu_out_mux_wb;
    logic rs1_forward_ex;
    logic rs2_forward_ex;
    logic [31:0] rs1_forward_value_ex;
    logic [31:0] rs2_forward_value_ex;
    logic pc_stall_ex;
    logic memcpy_ex, memcpy_mem;

    // Rename input signals with their pipeline-stage names
    assign rdata_wb = rdata;
    assign pc = pc_if;
    assign wdata = wdata_mem;
    assign addr = addr_mem;
    assign we = we_mem;

    //-------------------------------------------------------------------------
    // IF: Instruction Fetch
    //-------------------------------------------------------------------------
    pc_selector pc_selector_i (
        .clk(clk),
        .rstN(rstN),
        .branch_enable(branch_enable_mem),
        .pc_stall(pc_stall_ex),
        .branch_addr(alu_out_mem),
        .pc(pc_if)
    );

    //-------------------------------------------------------------------------
    // ID: Instruction Decode
    //-------------------------------------------------------------------------
    // Register signals from IF to ID
    always_ff @(posedge clk) begin
        if (!rstN) begin
            pc_id <= '0;
        end else begin
            pc_id <= pc_if;
        end
    end

    assign op_id = (pc_stall_ex) ? op_ex : (branch_enable_mem) ? RiscvNop : op;

    // TODO valid_op as an exception
    instruction_decoder instruction_decoder_i (
        .op(op_id),
        /* verilator lint_off PINCONNECTEMPTY */
        .op_valid(),
        .alu_mode(alu_mode_id),
        .rs1_idx(rs1_idx_id),
        .rs2_idx(rs2_idx_id),
        .rd_idx(rd_idx_id),
        .imm(imm_id),
        .imm_enable(imm_enable_id),
        .load_mode(load_mode_id),
        .we(we_id),
        .branch_mode(branch_mode_id),
        .pc_enable(pc_enable_id)
    );

    register_file register_file_i (
        .clk(clk),
        .rstN(rstN),
        .rs1_idx(rs1_idx_id),
        .rs2_idx(rs2_idx_id),
        .rd_idx(rd_idx_wb),
        .rd(rd_wb),
        .rs1(rs1_ex),
        .rs2(rs2_ex)
    );

    //-------------------------------------------------------------------------
    // EX
    //-------------------------------------------------------------------------
    // Register signals from ID to EX
    always_ff @(posedge clk) begin
        if (!rstN) begin
            pc_ex <= '0;
            branch_mode_ex <= BM_NONE;
            imm_ex <= '0;
            imm_enable_ex <= '0;
            alu_mode_ex <= ALU_ADD;
            load_mode_ex <= LM_NONE;
            we_ex <= 4'b0000;
            rd_idx_ex <= '0;
            pc_enable_ex <= 1'b0;
            rs1_idx_ex <= '0;
            rs2_idx_ex <= '0;
            op_ex <= '0;
        end else begin
            pc_ex <= pc_id;
            branch_mode_ex <= branch_mode_id;
            imm_ex <= imm_id;
            imm_enable_ex <= imm_enable_id;
            alu_mode_ex <= alu_mode_id;
            load_mode_ex <= load_mode_id;
            we_ex <= we_id;
            rd_idx_ex <= rd_idx_id;
            pc_enable_ex <= pc_enable_id;
            rs1_idx_ex <= rs1_idx_id;
            rs2_idx_ex <= rs2_idx_id;
            op_ex <= op_id;
        end
    end

    assign alu_op1_ex = (pc_enable_ex) ? pc_ex :
        (rs1_forward_ex) ? rs1_forward_value_ex : rs1_ex;
    assign alu_op2_ex = (imm_enable_ex) ? imm_ex : rs2_ok_ex;
    assign rs2_ok_ex = (rs2_forward_ex) ? rs2_forward_value_ex : rs2_ex;

    // TODO remove div_by_zero, maybe?
    alu alu_i (
        .op1(alu_op1_ex),
        .op2(alu_op2_ex),
        .mode(alu_mode_ex),
        .out(alu_out_ex),
        /* verilator lint_off PINCONNECTEMPTY */
        .div_by_zero()
    );

    brancher brancher_i (
        .branch_mode(branch_mode_valid_ex),
        .rs1(rs1_ex),
        .rs2(rs2_ex),
        .branch_enable(branch_enable_ex)
    );

    data_hazard data_hazard_i (
        .rs1_idx_ex(rs1_idx_ex),
        .rs2_idx_ex(rs2_idx_ex),
        .rd_idx_mem(rd_idx_mem),
        .rd_idx_wb(rd_idx_wb),
        .load_mode(load_mode_mem),
        .we_in(we_ex),
        .rd_idx_in(rd_idx_ex),
        .branch_mode_in(branch_mode_ex),
        .branch_enable_mem(branch_enable_mem),
        .alu_out(alu_out_mem),
        .rd(rd_wb),
        .rs1_forward(rs1_forward_ex),
        .rs2_forward(rs2_forward_ex),
        .rs1_forward_value(rs1_forward_value_ex),
        .rs2_forward_value(rs2_forward_value_ex),
        .pc_stall(pc_stall_ex),
        .we_out(we_valid_ex),
        .rd_idx_out(rd_idx_valid_ex),
        .branch_mode_out(branch_mode_valid_ex),
        .memcpy(memcpy_ex)
    );

    assign pc_jump_ex = pc_ex + 4;

    //-------------------------------------------------------------------------
    // MEM
    //-------------------------------------------------------------------------
    // Register signals from EX to MEM
    always_ff @(posedge clk) begin
        if (!rstN) begin
            branch_enable_mem <= '0;
            alu_out_mem <= '0;
            rs2_ok_mem <= '0;
            load_mode_mem <= LM_NONE;
            we_mem <= 4'b0000;
            rd_idx_mem <= '0;
            pc_jump_mem <= '0;
            memcpy_mem <= '0;
        end else begin
            branch_enable_mem <= branch_enable_ex;
            alu_out_mem <= alu_out_ex;
            rs2_ok_mem <= rs2_ok_ex;
            load_mode_mem <= load_mode_ex;
            we_mem <= we_valid_ex;
            rd_idx_mem <= rd_idx_valid_ex;
            pc_jump_mem <= pc_jump_ex;
            memcpy_mem <= memcpy_ex;
        end
    end

    assign alu_out_mux_mem = (branch_enable_mem) ? pc_jump_mem : alu_out_mem;
    assign addr_mem = alu_out_mux_mem;
    assign wdata_mem = (memcpy_mem) ? rd_wb : rs2_ok_mem;

    //-------------------------------------------------------------------------
    // WB
    //-------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rstN) begin
            load_mode_wb <= LM_NONE;
            alu_out_mux_wb <= '0;
            rd_idx_wb <= '0;
        end else begin
            load_mode_wb <= load_mode_mem;
            alu_out_mux_wb <= alu_out_mux_mem;
            rd_idx_wb <= rd_idx_mem;
        end
    end

    always_comb begin
        case (load_mode_wb)
            LM_B: rd_wb = {{24{rdata_wb[7]}}, rdata_wb[7:0]};
            LM_H: rd_wb = {{16{rdata_wb[15]}}, rdata_wb[15:0]};
            LM_W: rd_wb = rdata_wb;
            LM_BU: rd_wb = {24'd0, rdata_wb[7:0]};
            LM_HU: rd_wb = {16'd0, rdata_wb[15:0]};
            default: rd_wb = alu_out_mux_wb;
        endcase
    end

endmodule : riscotti_v
