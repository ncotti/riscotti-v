module rom #(
    int DATA_WIDTH = 32,
    int ADDR_WIDTH = 10,
    string ROM_FILE = "rom.hex"
) (
    input logic clk,
    input logic [ADDR_WIDTH-1:0] addr,
    output logic [DATA_WIDTH-1:0] dout
);

    timeunit 1ns; timeprecision 1ns;

    localparam int RomSize = 2 ** ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] rom_mem[RomSize];

    initial begin
        $readmemh(ROM_FILE, rom_mem);
    end

    always_ff @(posedge clk) begin
        dout <= rom_mem[addr];
    end

endmodule : rom
