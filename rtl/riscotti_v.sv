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
    input logic [31:0] op_id,
    input logic [31:0] rdata_wb,
    output logic [31:0] pc_if,
    output logic [31:0] wdata_mem,
    output logic [31:0] addr_mem,
    output store_mode_t store_mode_mem,
    output load_mode_t load_mode_mem
);

    import data_types::*;
    import isa::*;

    timeunit 1ns; timeprecision 1ns;

    logic branch_enable_ex, branch_enable_mem;
    logic [31:0] branch_addr_ex, branch_addr_mem;

    logic [4:0] rs1_idx_id, rs2_idx_id;
    /* verilator lint_off UNUSEDSIGNAL */ /* verilator lint_off UNDRIVEN */
    logic [4:0] rd_idx_id, rd_idx_wb;
    logic [31:0] imm_id, imm_ex;
    logic imm_enable_id, imm_enable_ex;
    load_mode_t load_mode_id, load_mode_ex, load_mode_wb;
    store_mode_t store_mode_id, store_mode_ex;
    branch_mode_t branch_mode_id, branch_mode_ex;

    logic [31:0] pc_id, pc_ex;

    logic [31:0] rs1_ex, rs2_ex, rs2_mem;
    logic [31:0] rd_wb;

    alu_mode_t alu_mode_id, alu_mode_ex;
    logic [31:0] alu_op2_ex;
    logic [31:0] alu_out_ex, alu_out_mem, alu_out_wb;

    //-------------------------------------------------------------------------
    // IF
    //-------------------------------------------------------------------------
    pc_selector pc_selector_i (
        .clk(clk),
        .rstN(rstN),
        .branch_enable(branch_enable_mem),
        .branch_addr(branch_addr_mem),
        .pc(pc_if)
    );

    //-------------------------------------------------------------------------
    // ID
    //-------------------------------------------------------------------------
    // Register signals from IF to ID
    always_ff @(posedge clk) begin
        if (!rstN) begin
            pc_id <= '0;
        end else begin
            pc_id <= pc_if;
        end
    end

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
        .store_mode(store_mode_id),
        .branch_mode(branch_mode_id)
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
            store_mode_ex <= SM_NONE;
        end else begin
            pc_ex <= pc_id;
            branch_mode_ex <= branch_mode_id;
            imm_ex <= imm_id;
            imm_enable_ex <= imm_enable_id;
            alu_mode_ex <= alu_mode_id;
            load_mode_ex <= load_mode_id;
            store_mode_ex <= store_mode_id;
        end
    end

    assign alu_op2_ex = (imm_enable_ex) ? imm_ex : rs2_ex;
    assign branch_addr_ex = pc_ex + imm_ex;

    alu alu_i (
        .op1(rs1_ex),
        .op2(alu_op2_ex),
        .mode(alu_mode_ex),
        .out(alu_out_ex),
        /* verilator lint_off PINCONNECTEMPTY */
        .div_by_zero()
    );

    brancher brancher_i (
        .branch_mode(branch_mode_ex),
        .rs1(rs1_ex),
        .rs2(rs2_ex),
        .branch_enable(branch_enable_ex)
    );

    //-------------------------------------------------------------------------
    // MEM
    //-------------------------------------------------------------------------
    // Register signals from EX to MEM
    always_ff @(posedge clk) begin
        if (!rstN) begin
            branch_addr_mem <= '0;
            branch_enable_mem <= '0;
            alu_out_mem <= '0;
            rs2_mem <= '0;
            load_mode_mem <= LM_NONE;
            store_mode_mem <= SM_NONE;
        end else begin
            branch_addr_mem <= branch_addr_ex;
            branch_enable_mem <= branch_enable_ex;
            alu_out_mem <= alu_out_ex;
            rs2_mem <= rs2_ex;
            load_mode_mem <= load_mode_ex;
            store_mode_mem <= store_mode_ex;
        end
    end

    assign addr_mem = alu_out_mem;
    assign wdata_mem = rs2_mem;

    //-------------------------------------------------------------------------
    // WB
    //-------------------------------------------------------------------------
    always_ff @(posedge clk) begin
        if (!rstN) begin
            load_mode_wb <= LM_NONE;
            alu_out_wb <= '0;
        end else begin
            load_mode_wb <= load_mode_mem;
            alu_out_wb <= alu_out_mem;
        end
    end

    assign rd_wb = (load_mode_wb == LM_NONE) ? alu_out_wb : rdata_wb;

endmodule : riscotti_v
