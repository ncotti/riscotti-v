
/// @brief Updates the program counter (PC).
///
/// The program counter holds the memory byte-address of the instruction
/// to be fetched from ROM.
///
/// @param clk Clock signal.
/// @param rstN Negative asserted reset signal.
/// @param branch_enable When "1", the program counter will be set to
/// "branch_addr".
/// @param branch_addr When "branch_enable == 1", the program counter will
/// be set to this value in the next clock cycle.
/// @param pc Program counter (byte-address).
module pc_selector(
    input logic clk,
    input logic rstN,
    input logic branch_enable,
    input logic [31:0] branch_addr,
    output logic [31:0] pc
);

    timeunit 1ns; timeprecision 1ns;

always_ff @(posedge clk) begin
    if (!rstN) begin
        pc <= '0;
    end else begin
        if (branch_enable) begin
            pc <= branch_addr;
        end else begin
            pc <= pc + 4;
        end
    end
end

endmodule: pc_selector
