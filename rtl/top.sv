module top;

timeunit 1ns; timeprecision 1ns;

localparam int ADDR_WIDTH = 12;
localparam int DATA_WIDTH = 32;
localparam string ROM_FILE = "rom.hex";

logic clk;
logic rstN;

logic [DATA_WIDTH-1:0] rom_data;
logic [DATA_WIDTH-1:0] pc;

logic ram_we;
logic [DATA_WIDTH-1:0] ram_din, ram_dout;

rom #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH),
    .ROM_FILE(ROM_FILE)
) rom_i (
    .clk(clk),
    .addr(pc),
    .dout(rom_data)
);

ram #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
) ram_i (
    .clk(clk),
    .addr(ram_din[ADDR_WIDTH-1:0]),
    .we(ram_we),
    .din(ram_din),
    .dout(ram_dout)
);

riscotti_v riscotti_v_i(
    .clk(clk),
    .rstN(rstN),
    .instruction(rom_data),
    .din(ram_dout),
    .pc(pc),
    .dout(ram_din),
    .we(ram_we)
);

endmodule: top
