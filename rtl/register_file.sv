
module register_file (
    input logic clk,
    input logic rstN,
    input logic [4:0] rs1_idx,
    input logic [4:0] rs2_idx,
    input logic [4:0] rd_idx,
    input logic [31:0] rd,
    input logic rd_we,
    output logic [31:0] rs1,
    output logic [31:0] rs2
);
    timeunit 1ns; timeprecision 1ps;

    // Hardware registers, x0 - x31
    logic [31:0] regx[32];

    // Zero constant
    assign regx[0] = '0;

    // Assign output registers
    assign rs1 = regx[rs1_idx];
    assign rs2 = regx[rs2_idx];

    always_ff @(posedge clk) begin
        if (!rstN) begin
            for (int i = 1; i < 32; i++) begin
                regx[i] <= '0;
            end
        end else begin
            // By default, refresh all registers
            for (int i = 1; i < 32; i++) begin
                regx[i] <= regx[i];
            end
            if (rd_we && rd_idx != 0) begin
                regx[rd_idx] <= rd;
            end
        end
    end

endmodule : register_file
