module top #(
    string ROM_FILE = "tb/rom_hex/rom.hex",
    int ADDR_WIDTH = 10,
    int DATA_WIDTH = 32
) (
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

    rom_sync #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH_WORDS(ADDR_WIDTH),
        .ROM_FILE  (ROM_FILE)
    ) rom_i (
        .clk (clk),
        .raddr(rom_addr),
        .rdata(rom_data)
    );

    /* verilator lint_off PINCONNECTEMPTY */
    ram_simple_dual_port #(
        .DATA_WIDTH(DATA_WIDTH),
        .DATA_LANE_WIDTH(8),
        .ADDR_WIDTH_WORDS(ADDR_WIDTH)
    ) ram_i (
        .clk (clk),
        .raddr(dout[ADDR_WIDTH-1:0]),
        .waddr(),
        .we(),
        .wdata(),
        .rdata(ram_dout)
    );

    riscotti_v riscotti_v_i (
        .clk(clk),
        .rstN(rstN),
        .op_id(rom_data),
        .rdata_wb(ram_dout),
        .pc_if(pc),
        .wdata_mem(dout),
        /* verilator lint_off PINCONNECTEMPTY */
        .addr_mem(),
        /* verilator lint_off PINCONNECTEMPTY */
        .we_mem(),
        /* verilator lint_off PINCONNECTEMPTY */
        .load_mode_mem()
    );

endmodule : top
