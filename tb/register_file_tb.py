import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock

async def reset(dut):
    c = Clock(dut.clk, 2)
    c.start()

    dut.rstN.value = 1
    dut.rs1_idx.value = 0
    dut.rs2_idx.value = 0
    dut.rd_idx.value = 0
    dut.rd_we.value = 0

    await RisingEdge(dut.clk)

    dut.rstN.value = 0
    await RisingEdge(dut.clk)

    dut.rstN.value = 1


@cocotb.test
async def test_reset(dut):
    await reset(dut)

    assert dut.rs1.value == 0
    assert dut.rs2.value == 0

    for i in range(1,32):
        dut.rs1_idx.value = i
        dut.rs2_idx.value = i

        await RisingEdge(dut.clk)
        assert dut.rs1.value == 0
        assert dut.rs2.value == 0

@cocotb.test
async def test_rw_registers(dut):
    await reset(dut)

    # Enable writing to the register
    dut.rd_we.value = 1

    # Check that writing to x0 has no effect
    dut.rs1_idx.value = 0
    dut.rd_idx.value = 0
    dut.rd.value = 0x5555_5555
    await RisingEdge(dut.clk)
    assert dut.rs1.value == 0
    await RisingEdge(dut.clk)
    assert dut.rs1.value == 0

    for i in range(1,32):
        dut.rs1_idx.value = i - 1
        dut.rs2_idx.value = i
        dut.rd_idx.value = i
        dut.rd.value = i + 7

        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)

        if (i == 1):
            assert dut.rs1.value == 0
        else:
            assert dut.rs1.value == (i - 1) + 7
        assert dut.rs2.value == i + 7


    for i in range(32):
        dut.rs1_idx.value = i
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        if (i == 0):
            assert dut.rs1.value == 0
        else:
            assert dut.rs1.value == i + 7

