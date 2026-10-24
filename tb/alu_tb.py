import cocotb
from cocotb.triggers import Timer

from common.data_types import AluMode

@cocotb.test
async def test_addition(dut):
    dut.mode.value = AluMode.ADD

    # Two positive values
    dut.op1.value = 5
    dut.op2.value = 6
    await Timer(1)
    assert dut.out.value == 11

    # Two negative values
    dut.op1.value = -20
    dut.op2.value = -25
    await Timer(1)
    assert dut.out.value == -45

    # One positive, one negative
    dut.op1.value = -30
    dut.op2.value = 45
    await Timer(1)
    assert dut.out.value == 15

    # Addition positive overflow
    dut.op1.value = 0xFFFFFFFF
    dut.op2.value = 0x00000003
    await Timer(1)
    assert dut.out.value == 0x00000002

@cocotb.test
async def test_subtraction(dut):
    dut.mode.value = AluMode.SUB

    # Two positive values
    dut.op1.value = 5
    dut.op2.value = 6
    await Timer(1)
    assert dut.out.value == -1

    # Order matters, it is op1 - op2
    dut.op1.value = 6
    dut.op2.value = 5
    await Timer(1)
    assert dut.out.value == 1

    # Two negative values
    dut.op1.value = -20
    dut.op2.value = -25
    await Timer(1)
    assert dut.out.value == 5

    # One positive, one negative
    dut.op1.value = -30
    dut.op2.value = 45
    await Timer(1)
    assert dut.out.value == -75

@cocotb.test
async def test_mul(dut):
    dut.mode.value = AluMode.MUL

    # Two positive values
    dut.op1.value = 7
    dut.op2.value = 8
    await Timer(1)
    assert dut.out.value == 56

    # One positive, one negative
    dut.op1.value = -15
    dut.op2.value = 10
    await Timer(1)
    assert dut.out.value == -150

    # One negative, one positive
    dut.op1.value = 5
    dut.op2.value = -3
    await Timer(1)
    assert dut.out.value == -15

    # Two negative
    dut.op1.value = -2
    dut.op2.value = -4
    await Timer(1)
    assert dut.out.value == 8

    # Zero multiplication
    dut.op1.value = 0
    dut.op2.value = 5
    await Timer(1)
    assert dut.out.value == 0

    # Multiplication overflow
    dut.op1.value = 0x12345678
    dut.op2.value = 0xFFF
    await Timer(1)
    assert dut.out.value == 0x33332988

@cocotb.test
async def test_division(dut):
    dut.mode.value = AluMode.DIV

    # Two positive values
    dut.op1.value = 16
    dut.op2.value = 2
    await Timer(1)
    assert dut.out.value == 8

    # Two positive values, but not multiple
    dut.op1.value = 24
    dut.op2.value = 5
    await Timer(1)
    assert dut.out.value == 4

    # One positive, one negative
    dut.op1.value = -16
    dut.op2.value = 3
    await Timer(1)
    assert dut.out.value == -5

    # One negative, one positive
    dut.op1.value = 17
    dut.op2.value = -5
    await Timer(1)
    assert dut.out.value == -3

    # Two negative
    dut.op1.value = -24
    dut.op2.value = -3
    await Timer(1)
    assert dut.out.value == 8

    # Numerator is zero
    dut.op1.value = 0
    dut.op2.value = 5
    await Timer(1)
    assert dut.out.value == 0
    assert dut.div_by_zero.value == 0

    # Denominator is zero
    dut.op1.value = 20
    dut.op2.value = 0
    await Timer(1)
    assert dut.out.value == 0
    assert dut.div_by_zero.value == 1


@cocotb.test
async def test_logic(dut):
    dut.mode.value = AluMode.XOR
    dut.op1.value = 0x11110000
    dut.op2.value = 0x10101010
    await Timer(1)
    assert dut.out.value == 0x01011010

    dut.mode.value = AluMode.OR
    dut.op1.value = 0x00001100
    dut.op2.value = 0x00000000
    await Timer(1)
    assert dut.out.value == 0x00001100

    dut.mode.value = AluMode.AND
    dut.op1.value = 0x01110100
    dut.op2.value = 0x11111111
    await Timer(1)
    assert dut.out.value == 0x01110100

    dut.mode.value = AluMode.SLL
    dut.op1.value = 0b00010100
    dut.op2.value = 3
    await Timer(1)
    assert dut.out.value == 0b10100000

    dut.op1.value = 0x00001000
    dut.op2.value = 35
    await Timer(1)
    assert dut.out.value == 0x00000000

    dut.mode.value = AluMode.SRL
    dut.op1.value = 0b11111111_11111111_11111111_11110100
    dut.op2.value = 2
    await Timer(1)
    assert dut.out.value == 0b00111111_11111111_11111111_11111101

    dut.mode.value = AluMode.SRA
    dut.op1.value = 0b10000000_00000000_00000000_11000100
    dut.op2.value = 1
    await Timer(1)
    assert dut.out.value == 0b11000000_00000000_00000000_01100010


@cocotb.test
async def test_invalid_mode(dut):
    dut.mode.value = AluMode.INVALID
    dut.op1.value = 1
    dut.op2.value = 2
    await Timer(1)
    assert dut.out.value == 0
