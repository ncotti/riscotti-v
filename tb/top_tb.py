import cocotb
from cocotb.triggers import Timer, RisingEdge, FallingEdge
from cocotb.clock import Clock


async def reset(dut):
    c = Clock(dut.clk, 10, "ns")
    c.start()

    dut.rstN.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    dut.rstN.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    dut.rstN.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, "ns")


async def sync_and_check(dut, expected_values:list):
    while dut.dout.value != 0x7FF:
        await RisingEdge(dut.clk)

    await RisingEdge(dut.clk)

    for value in expected_values:
        assert dut.dout.value == value
        await RisingEdge(dut.clk)


async def check_imm_math(dut):
    cocotb.log.info("Checking immediate math instructions")
    expected_values = [0x55, 0xFB, 0x16, 0x08, 0x50, 0x06, 0x03, 0x01, 0x00]

    await sync_and_check(dut, expected_values)

async def check_register_math(dut):
    cocotb.log.info("Checking register math instructions")
    expected_values = [
        31+30,
        29-28,
        27 ^ 26,
        25|24,
        23 & 22,
        21 * 20,
        0,
        0,
        0,
        1,
        1,
        1,
        1,
        5 << 4,
        3 >> 2,
        1 >> 0,
        1,
        0]

    await sync_and_check(dut, expected_values)


async def check_upper_load(dut):
    cocotb.log.info("Checking upper load instructions")
    # The second value depends on the program counter,
    # which may change if the assembly code changes.
    read_pc1_address = 0x17C - 4
    expected_values = [
        0xABC0_0000,
        0xDEF0_0000 | read_pc1_address,
    ]

    await sync_and_check(dut, expected_values)


async def check_branch(dut):
    cocotb.log.info("Checking branch instructions")
    # On each successful branch, the returned value should
    # be the address the code branched into, which is always
    # two instructions ahead (8-bytes).

    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    read_pc2_address = 0x18C -4
    expected_values = [
        read_pc2_address + 16*1,
        read_pc2_address + 16*2,
        read_pc2_address + 16*3,
        read_pc2_address + 16*4,
        read_pc2_address + 16*5,
        read_pc2_address + 16*6,
        # Now, all branches should fail, and they point to
        # to the "read_pc2_address" location
        read_pc2_address,
        read_pc2_address,
        read_pc2_address,
        read_pc2_address,
        read_pc2_address,
        read_pc2_address,
    ]

    await sync_and_check(dut, expected_values)


async def check_load(dut):
    expected_values = [
        0xFFFF_FF81,
        0xFFFF_8002,
        0x8000_0003,
        0x0000_0081,
        0x0000_8002,
    ]

    await sync_and_check(dut, expected_values)


@cocotb.test(timeout_time=100, timeout_unit="us")
async def test_instructions(dut):
    await reset(dut)

    await check_imm_math(dut)

    await check_register_math(dut)

    await check_branch(dut)

    #await check_load(dut)
