import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock


async def reset(dut):
    c = Clock(dut.clk, 2)
    c.start()

    dut.rstN.value = 1
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    dut.rstN.value = 0
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    dut.rstN.value = 1
    await RisingEdge(dut.clk)


@cocotb.test(timeout_time=100, timeout_unit="step")
async def test_imm_math_instructions(dut):
    await reset(dut)

    expected_values = [0x55, 0xFB, 0x16, 0x08, 0x50, 0x06, 0x03, 0x01, 0x00]

    while (dut.dout.value != 0xFF):
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)

    for value in expected_values:
        assert dut.dout.value == value
        await RisingEdge(dut.clk)
