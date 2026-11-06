import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock


async def reset(dut):
    c = Clock(dut.clk, 10, "ns")
    c.start()

    dut.rstN.value = 1
    dut.rs1_idx.value = 0
    dut.rs2_idx.value = 0
    dut.rd_idx.value = 0

    await RisingEdge(dut.clk)

    dut.rstN.value = 0
    await RisingEdge(dut.clk)

    dut.rstN.value = 1


@cocotb.test
async def test_reset(dut):
    await reset(dut)

    assert dut.rs1.value == 0
    assert dut.rs2.value == 0

    for i in range(1, 32):
        dut.rs1_idx.value = i
        dut.rs2_idx.value = i

        await RisingEdge(dut.clk)
        await Timer(1, "ns")
        assert dut.rs1.value == 0
        assert dut.rs2.value == 0

@cocotb.test
async def test_registered_outputs(dut):
    await reset(dut)

    dut.rs1_idx.value = 0
    dut.rs2_idx.value = 0

    dut.rd_idx.value = 1
    dut.rd.value = 10

    await RisingEdge(dut.clk)

    dut.rd_idx.value = 2
    dut.rd.value = 20

    await RisingEdge(dut.clk)

    assert dut.rs1.value == 0
    assert dut.rs2.value == 0

    dut.rs1_idx.value = 1
    dut.rs2_idx.value = 2

    # Value should not change before the rising edge of the clock
    await RisingEdge(dut.clk)
    assert dut.rs1.value == 0
    assert dut.rs2.value == 0

    # Only now the values should have changed
    await Timer(1, "ns")
    assert dut.rs1.value == 10
    assert dut.rs2.value == 20


@cocotb.test
async def test_rw_registers(dut):
    await reset(dut)

    # Check that writing to x0 has no effect
    dut.rs1_idx.value = 0
    dut.rd_idx.value = 0
    dut.rd.value = 0x5555_5555
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Reading and writing the same idx bypasses the value
    assert dut.rs1.value == 0x5555_5555
    dut.rd_idx.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Now, it should read "0", since x0 is not writable
    assert dut.rs1.value == 0

    for i in range(1, 32):
        dut.rs1_idx.value = i - 1
        dut.rs2_idx.value = i
        dut.rd_idx.value = i
        dut.rd.value = i + 7

        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)

        if i == 1:
            assert dut.rs1.value == 0
        else:
            assert dut.rs1.value == (i - 1) + 7

        assert dut.rs2.value == i + 7

    for i in range(32):
        dut.rs1_idx.value = i
        await RisingEdge(dut.clk)
        await FallingEdge(dut.clk)
        if i == 0:
            assert dut.rs1.value == 0
        else:
            assert dut.rs1.value == i + 7
