module ram #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 10
) (
    input logic clk,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic we,
    input logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

    timeunit 1ns; timeprecision 1ns;

    localparam int RamSize = 2 ** ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] ram_mem[RamSize];

    always_ff @(posedge clk) begin
        dout <= ram_mem[addr];

        if (we) begin
            ram_mem[addr] <= din;
        end
    end

endmodule : ram
