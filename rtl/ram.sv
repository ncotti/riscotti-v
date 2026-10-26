module ram #(
    int DATA_WIDTH,
    int ADDR_WIDTH
)(
    input logic clk,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic we,
    input logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

    timeunit 1ns; timeprecision 1ns;

    localparam int RAM_SIZE = $pow2(ADDR_WIDTH);

logic [DATA_WIDTH-1:0] ram_mem [RAM_SIZE];

always_ff @(posedge clk) begin
    dout <= ram_mem[addr];

    if (we) begin
        ram_mem[addr] <= din;
    end
end

endmodule: ram
