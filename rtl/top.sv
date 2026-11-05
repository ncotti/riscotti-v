module top #(
    string ROM_FILE = "tb/rom.hex",
    int ADDR_WIDTH_WORDS = 10,
    int DATA_WIDTH = 32
) (
    input logic clk,
    input logic rstN
);

    timeunit 1ns; timeprecision 1ns;


    logic [31:0] op;
    logic [31:0] rdata;
    // Only using as much bits as the ROM ADDRESS.
    /* verilator lint_off UNUSEDSIGNAL */
    logic [31:0] pc;
    logic [31:0] wdata;
    // Only using as much bits as the RAM ADDRESS.
    /* verilator lint_off UNUSEDSIGNAL */
    logic [31:0] addr;
    logic [3:0] we;

    logic [ADDR_WIDTH_WORDS-1:0] rom_raddr;
    assign rom_raddr = pc[ADDR_WIDTH_WORDS+1:2];

    rom_sync #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH_WORDS(ADDR_WIDTH_WORDS),
        .ROM_FILE  (ROM_FILE)
    ) rom_i (
        .clk (clk),
        .raddr(rom_raddr),
        .rdata(op)
    );

    logic [ADDR_WIDTH_WORDS-1:0] ram_addr;
    assign ram_addr = addr[ADDR_WIDTH_WORDS+1:2];

    ram_single_port #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_LANE_WIDTH(8),
        .ADDR_WIDTH_WORDS(ADDR_WIDTH_WORDS)
    ) ram_i (
        .clk (clk),
        .addr(addr[ADDR_WIDTH_WORDS+1:2]),
        .we(we),
        .wdata(wdata),
        .rdata(rdata)
    );

    riscotti_v riscotti_v_i (
        .clk(clk),
        .rstN(rstN),
        .op(op),
        .rdata(rdata),
        .pc(pc),
        .wdata(wdata),
        .addr(addr),
        .we(we)
    );

endmodule : top
