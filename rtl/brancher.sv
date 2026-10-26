`include "isa.svh"

module brancher
import isa::*;
(
    input branch_mode_t branch_mode,
    input logic [31:0] rs1,
    input logic [31:0] rs2,
    output logic branch_enable
);

timeunit 1ns; timeprecision 1ns;

logic rs_eq, rs_ne, rs_lt, rs_ge, rs_ltu, rs_geu;

assign rs_eq = rs1 == rs2;
assign rs_ne = rs1 != rs2;
assign rs_lt = rs1 < rs2;
assign rs_ge = rs1 >= rs2;
assign rs_ltu = unsigned'(rs1) < unsigned'(rs2);
assign rs_geu = unsigned'(rs1) >= unsigned'(rs2);

always_comb begin
    case(branch_mode)
    BM_EQ: branch_enable = rs_eq;
    BM_NE: branch_enable = rs_ne;
    BM_LT: branch_enable = rs_lt;
    BM_GE: branch_enable = rs_ge;
    BM_LTU: branch_enable = rs_ltu;
    BM_GEU: branch_enable = rs_geu;
    default: branch_enable = '0;
    endcase
end

endmodule: brancher
