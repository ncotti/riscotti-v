`include "isa.svh"

/// @brief Decides whether a branch instruction should "branch", i.e., update
/// the program counter to a new arbitrary address, provided by the
/// instruction.
///
/// @param branch_mode Type of branch operation requested.
/// @param rs1 Source register 1.
/// @param rs2 Source register 2.
/// @param branch_enable Whether the branch condition is met or not.
module brancher
    import isa::*;
(
    input branch_mode_t branch_mode,
    input logic [31:0] rs1,
    input logic [31:0] rs2,
    output logic branch_enable
);

    timeunit 1ns; timeprecision 1ns;

    always_comb begin
        case (branch_mode)
            BM_EQ:   branch_enable = rs1 == rs2;
            BM_NE:   branch_enable = rs1 != rs2;
            BM_LT:   branch_enable = rs1 < rs2;
            BM_GE:   branch_enable = rs1 >= rs2;
            BM_LTU:  branch_enable = unsigned'(rs1) < unsigned'(rs2);
            BM_GEU:  branch_enable = unsigned'(rs1) >= unsigned'(rs2);
            BM_JUMP: branch_enable = 1'b1;
            default: branch_enable = 1'b0;
        endcase
    end

endmodule : brancher
