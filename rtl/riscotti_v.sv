`include "data_types.svh"
`include "isa.svh"

module riscotti_v(
    input logic clk,
    input logic rstN,
    input logic [31:0] instruction,
    input logic [31:0] din,
    output logic [31:0] pc,
    output logic [31:0] dout,
    output logic we
);

import data_types::*;
import isa::*;

timeunit 1ns; timeprecision 1ns;

alu_mode_t alu_mode;
logic [4:0] rs1_idx, rs2_idx, rd_idx;
logic [31:0] imm;
logic valid_imm;

logic [31:0] alu_op1, alu_op2, alu_out;
logic [31:0] rs1, rs2, rd;
logic branch_enable;
branch_mode_t branch_mode;
store_mode_t store_mode;
load_mode_t load_mode;

decoder decoder_i (
    .op(instruction),
    .alu_mode(alu_mode),
    .rs1_idx(rs1_idx),
    .rs2_idx(rs2_idx),
    .rd_idx(rd_idx),
    .imm(imm),
    .valid_imm(valid_imm),
    .load_mode(load_mode),
    .store_mode(store_mode),
    .branch_mode(branch_mode),
    /* verilator lint_off PINCONNECTEMPTY */
    .valid_op()
);

brancher brancher_i (
    .branch_mode(branch_mode),
    .rs1(rs1),
    .rs2(rs2),
    .branch_enable(branch_enable)
);

register_file register_file_i (
    .clk(clk),
    .rstN(rstN),
    .rs1_idx(rs1_idx),
    .rs2_idx(rs2_idx),
    .rd_idx(rd_idx),
    .rd(rd),
    .rd_we(1'b1),
    .rs1(rs1),
    .rs2(rs2)
);

assign alu_op1 = (branch_mode != BM_NONE) ? pc : rs1;
assign alu_op2 = (valid_imm) ? imm : rs2;

always_comb begin
    case(store_mode)
        SM_B: dout = rs2 & 32'h0000_00FF;
        SM_H: dout = rs2 & 32'h0000_FFFF;
        SM_W: dout = rs2 & 32'hFFFF_FFFF;
        default: dout = alu_out;
    endcase
    we = (store_mode != SM_NONE);
end

always_comb begin
    case(load_mode)
        LM_B: rd = {{24{din[31]}},din[7:0]};
        LM_H: rd = {{16{din[31]}},din[15:0]};
        LM_W: rd = din;
        LM_BU: rd = {24'd0, din[7:0]};
        LM_HU: rd = {16'd0, din[15:0]};
        default: rd = alu_out;
    endcase
end

alu alu_i (
    .op1(alu_op1),
    .op2(alu_op2),
    .mode(alu_mode),
    .out(alu_out),
    /* verilator lint_off PINCONNECTEMPTY */
    .div_by_zero()
);

always_ff @(posedge clk) begin
    if (!rstN) begin
        pc <= '0;
    end else begin
        if (branch_enable) begin
            pc <= alu_out;
        end else begin
            pc <= pc + 4;
        end
    end
end

endmodule: riscotti_v
