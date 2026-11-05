
/// @brief Holds the 32 registers (x0-x31).
///
/// @param clk Clock signal.
/// @param rstN Negative asserted synchronous reset.
/// @param rs1_idx Source register index 1. Its value will be retrieved in
/// the next clock cycle by the `rs1` output.
/// the next clock cycle.
/// @param rs2_idx Source register index 2. Its value will be retrieved in
/// the next clock cycle by the `rs2` output.
/// @param rd_idx Destination register index. The value of this register will
/// be updated to `rd` in the next clock cycle. If no register wants to be
/// updated, pointing to the `x0` register does nothing.
/// @param rd Value to update the `rd_idx` register.
/// @param rs1 Value pointed by the `rs1_idx` in the prev. clock cycle.
/// @param rs2 Value pointer by the `rs2_idx` in the prev . clock cycle.
module register_file (
    input logic clk,
    input logic rstN,
    input logic [4:0] rs1_idx,
    input logic [4:0] rs2_idx,
    input logic [4:0] rd_idx,
    input logic [31:0] rd,
    output logic [31:0] rs1,
    output logic [31:0] rs2
);
    timeunit 1ns; timeprecision 1ps;

    // Hardware registers, x0 - x31
    logic [31:0] regx[32];

    // Zero constant
    assign regx[0] = '0;

    always_ff @(posedge clk) begin
        if (!rstN) begin
            for (int i = 1; i < 32; i++) begin
                regx[i] <= '0;
            end
            rs1 <= regx[0];
            rs2 <= regx[0];
        end else begin
            // By default, refresh all registers
            for (int i = 1; i < 32; i++) begin
                regx[i] <= regx[i];
            end
            if (rd_idx != 0) begin
                regx[rd_idx] <= rd;
            end

            rs1 <= regx[rs1_idx];
            rs2 <= regx[rs2_idx];
        end
    end

endmodule : register_file
