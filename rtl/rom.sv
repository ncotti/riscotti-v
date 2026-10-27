module rom #(
    int DATA_WIDTH,
    int ADDR_WIDTH,
    string ROM_FILE
)(
    input logic clk,
    input logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] dout
);

    timeunit 1ns; timeprecision 1ns;

    localparam int ROM_SIZE = 2 ** ADDR_WIDTH;

logic [DATA_WIDTH-1:0] rom_mem [ROM_SIZE];

initial begin
    $readmemh(ROM_FILE, rom_mem);
end

always_ff @(posedge clk) begin
    dout <= rom_mem[addr];
end

endmodule: rom
