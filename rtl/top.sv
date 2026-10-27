module top #(
    string ROM_FILE = "tb/rom_hex/rom.hex",
    int ADDR_WIDTH = 12,
    int DATA_WIDTH = 32
)(
    input logic clk,
    input logic rstN
);

timeunit 1ns; timeprecision 1ns;


logic [DATA_WIDTH-1:0] rom_data;

/* verilator lint_off UNUSEDSIGNAL */
logic [DATA_WIDTH-1:0] pc;

logic ram_we;
logic [DATA_WIDTH-1:0] dout, ram_dout;
logic [ADDR_WIDTH-1:0] rom_addr;

assign rom_addr = pc[ADDR_WIDTH+1:2];

rom #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ROM_FILE(ROM_FILE)
) rom_i (
    .clk(clk),
    .addr(rom_addr),
    .dout(rom_data)
);

ram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) ram_i (
    .clk(clk),
    .addr(dout[ADDR_WIDTH-1:0]),
    .we(ram_we),
    .din(dout),
    .dout(ram_dout)
);

riscotti_v riscotti_v_i(
    .clk(clk),
    .rstN(rstN),
    .instruction(rom_data),
    .din(ram_dout),
    .pc(pc),
    .dout(dout),
    .we(ram_we)
);

endmodule: top
