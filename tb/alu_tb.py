import cocotb
from cocotb.triggers import Timer

from common.data_types import AluMode


@cocotb.test
async def test_addition(dut):
    dut.mode.value = AluMode.ADD

    # Two positive values
    dut.op1.value = 5
    dut.op2.value = 6
    await Timer(2)
    assert dut.out.value == 11

    # Two negative values
    dut.op1.value = -20
    dut.op2.value = -25
    await Timer(2)
    assert dut.out.value == -45

    # One positive, one negative
    dut.op1.value = -30
    dut.op2.value = 45
    await Timer(2)
    assert dut.out.value == 15

    # Addition positive overflow
    dut.op1.value = 0xFFFFFFFF
    dut.op2.value = 0x00000003
    await Timer(2)
    assert dut.out.value == 0x00000002


@cocotb.test
async def test_subtraction(dut):
    dut.mode.value = AluMode.SUB

    # Two positive values
    dut.op1.value = 5
    dut.op2.value = 6
    await Timer(2)
    assert dut.out.value == -1

    # Order matters, it is op1 - op2
    dut.op1.value = 6
    dut.op2.value = 5
    await Timer(2)
    assert dut.out.value == 1

    # Two negative values
    dut.op1.value = -20
    dut.op2.value = -25
    await Timer(2)
    assert dut.out.value == 5

    # One positive, one negative
    dut.op1.value = -30
    dut.op2.value = 45
    await Timer(2)
    assert dut.out.value == -75


@cocotb.test
async def test_mul(dut):
    dut.mode.value = AluMode.MUL

    # Two positive values
    dut.op1.value = 7
    dut.op2.value = 8
    await Timer(2)
    assert dut.out.value == 56

    # One positive, one negative
    dut.op1.value = -15
    dut.op2.value = 10
    await Timer(2)
    assert dut.out.value == -150

    # One negative, one positive
    dut.op1.value = 5
    dut.op2.value = -3
    await Timer(2)
    assert dut.out.value == -15

    # Two negative
    dut.op1.value = -2
    dut.op2.value = -4
    await Timer(2)
    assert dut.out.value == 8

    # Zero multiplication
    dut.op1.value = 0
    dut.op2.value = 5
    await Timer(2)
    assert dut.out.value == 0

    # Multiplication overflow
    dut.op1.value = 0x12345678
    dut.op2.value = 0xFFF
    await Timer(2)
    assert dut.out.value == 0x33332988


@cocotb.test
async def test_mulh(dut):
    dut.mode.value = AluMode.MULH

    # Two positives
    dut.op1.value = 0x0FFF_FFFF
    dut.op2.value = 0x0ABC_1234
    await Timer(2)
    assert dut.out.value == 0x00AB_C123

    # Two negatives
    # Expected result is 3 == 0x0000_0000_0000_0003
    dut.op1.value = 0xFFFF_FFFD  # -3
    dut.op2.value = 0xFFFF_FFFF  # -1
    await Timer(2)
    assert dut.out.value == 0x0000_0000  # Sign extension makes it all "0"

    # Negative and positive
    # Expected result is -2 = 0xFFFF_FFFF_FFFF_FFFE
    dut.op1.value = 0xFFFF_FFFF  # -1
    dut.op2.value = 0x0000_0002  # 2
    await Timer(2)
    assert dut.out.value == 0xFFFF_FFFF  # Sign extension makes it all "F"


@cocotb.test
async def test_mulhu(dut):
    dut.mode.value = AluMode.MULHU

    # Two positives
    dut.op1.value = 0x0FFF_FFFF
    dut.op2.value = 0x0ABC_1234
    await Timer(2)
    assert dut.out.value == 0x00AB_C123

    # Two negatives
    # If this was signed, the result would be 3 = 0x0000_0000_0000_0003
    # Unsigned result is 0xFFFF_FFFC_0000_0003
    dut.op1.value = 0xFFFF_FFFD  # -3
    dut.op2.value = 0xFFFF_FFFF  # -1
    await Timer(2)
    assert dut.out.value == 0xFFFFFFFC

    # Negative and positive
    # If this was signed, the result would be -4 = 0xFFFF_FFFF_FFFF_FFFC
    # Unsigned result is 0x0000_0003_FFFF_FFFC
    dut.op1.value = 0xFFFF_FFFF  # -1
    dut.op2.value = 0x0000_0004  # 4
    await Timer(2)
    assert dut.out.value == 0x0000_0003


@cocotb.test
async def test_mulhsu(dut):
    dut.mode.value = AluMode.MULHSU

    # Two positives
    dut.op1.value = 0x0FFF_FFFF
    dut.op2.value = 0x0ABC_1234
    await Timer(2)
    assert dut.out.value == 0x00AB_C123

    # First positive, second negative
    # Expected value should be 2 * 0xFFFF_FFFF = 0x0000_0001_FFFF_FFFE
    dut.op1.value = 0x0000_0002  # Should be treated as signed
    dut.op2.value = 0xFFFF_FFFF  # Should be treated as unsigned
    await Timer(2)
    assert dut.out.value == 0x0000_0001

    # First negative, second positive
    # Expected value should be -1 * 2 = -2 = 0xFFFF_FFFF_FFFF_FFFE
    dut.op1.value = 0xFFFF_FFFF  # Should be treated as signed
    dut.op2.value = 0x0000_0002  # Should be treated as unsigned
    await Timer(2)
    assert dut.out.value == 0xFFFF_FFFF

    # Both negative
    # Expected value should be -2 * 0xFFFF_FFFF = -0x0000_0001_FFFF_FFFE = 0xFFFF_FFFE_0000_0002
    dut.op1.value = 0xFFFF_FFFE
    dut.op2.value = 0xFFFF_FFFF
    await Timer(2)
    assert dut.out.value == 0xFFFF_FFFE


@cocotb.test
async def test_division(dut):
    dut.mode.value = AluMode.DIV

    # Two positive values
    dut.op1.value = 16
    dut.op2.value = 2
    await Timer(2)
    assert dut.out.value == 8

    # Two positive values, but not multiple
    dut.op1.value = 24
    dut.op2.value = 5
    await Timer(2)
    assert dut.out.value == 4

    # One positive, one negative
    dut.op1.value = -16
    dut.op2.value = 3
    await Timer(2)
    assert dut.out.value == -5

    # One negative, one positive
    dut.op1.value = 17
    dut.op2.value = -5
    await Timer(2)
    assert dut.out.value == -3

    # Two negative
    dut.op1.value = -24
    dut.op2.value = -3
    await Timer(2)
    assert dut.out.value == 8

    # Numerator is zero
    dut.op1.value = 0
    dut.op2.value = 5
    await Timer(2)
    assert dut.out.value == 0
    assert dut.div_by_zero.value == 0

    # Denominator is zero
    dut.op1.value = 20
    dut.op2.value = 0
    await Timer(2)
    assert dut.out.value == 0
    assert dut.div_by_zero.value == 1


@cocotb.test
async def test_divu(dut):
    dut.mode.value = AluMode.DIVU

    # Two positive values
    dut.op1.value = 16
    dut.op2.value = 2
    await Timer(2)
    assert dut.out.value == 8

    # Two positive values, but not multiple
    dut.op1.value = 24
    dut.op2.value = 5
    await Timer(2)
    assert dut.out.value == 4

    # One positive, one negative
    # If this was signed, the result would be -3 / 3 = -1 == 0xFFFFFFFF
    dut.op1.value = 0xFFFF_FFFC
    dut.op2.value = 3
    await Timer(2)
    assert dut.out.value == 0x55555554

    # One negative, one positive
    # If this was signed, the result would be 5 / - 5 = -1 == 0xFFFFFFFF
    dut.op1.value = 5
    dut.op2.value = 0xFFFF_FFFB
    await Timer(2)
    assert dut.out.value == 0

    # Two negative
    # If this was signed, the result would be -6 / -1 = 6 == 0x00000006
    dut.op1.value = 0xFFFF_FFFA
    dut.op2.value = 0xFFFF_FFFF
    await Timer(2)
    assert dut.out.value == 0

    # Numerator is zero
    dut.op1.value = 0
    dut.op2.value = 5
    await Timer(2)
    assert dut.out.value == 0
    assert dut.div_by_zero.value == 0

    # Denominator is zero
    dut.op1.value = 20
    dut.op2.value = 0
    await Timer(2)
    assert dut.out.value == 0
    assert dut.div_by_zero.value == 1


@cocotb.test
async def test_logic(dut):
    dut.mode.value = AluMode.XOR
    dut.op1.value = 0x11110000
    dut.op2.value = 0x10101010
    await Timer(2)
    assert dut.out.value == 0x01011010

    dut.mode.value = AluMode.OR
    dut.op1.value = 0x00001100
    dut.op2.value = 0x00000000
    await Timer(2)
    assert dut.out.value == 0x00001100

    dut.mode.value = AluMode.AND
    dut.op1.value = 0x01110100
    dut.op2.value = 0x11111111
    await Timer(2)
    assert dut.out.value == 0x01110100

    dut.mode.value = AluMode.SLL
    dut.op1.value = 0b00010100
    dut.op2.value = 3
    await Timer(2)
    assert dut.out.value == 0b10100000

    dut.op1.value = 0x00001000
    dut.op2.value = 35
    await Timer(2)
    assert dut.out.value == 0x00000000

    dut.mode.value = AluMode.SRL
    dut.op1.value = 0b11111111_11111111_11111111_11110100
    dut.op2.value = 2
    await Timer(2)
    assert dut.out.value == 0b00111111_11111111_11111111_11111101

    dut.mode.value = AluMode.SRA
    dut.op1.value = 0b10000000_00000000_00000000_11000100
    dut.op2.value = 1
    await Timer(2)
    assert dut.out.value == 0b11000000_00000000_00000000_01100010


@cocotb.test
async def test_set_less_than_unsigned(dut):
    dut.mode.value = AluMode.SLTU

    # op1 < op2
    dut.op1.value = 4
    dut.op2.value = 5
    await Timer(2)
    assert dut.out.value == 1

    # op1 == op2
    dut.op1.value = 10
    dut.op2.value = 10
    await Timer(2)
    assert dut.out.value == 0

    # op1 > op2
    dut.op1.value = 15
    dut.op2.value = 12
    await Timer(2)
    assert dut.out.value == 0

    # 32-bit wide number, op1 < op2
    # If it was signed, this operation would be 0 < -1
    dut.op1.value = 0x00000000
    dut.op2.value = 0xFFFFFFFF
    await Timer(2)
    assert dut.out.value == 1

    # 32-bit wide number, op1 > op2
    # If it was signed, this operation would be -1 > 0
    dut.op1.value = 0xFFFFFFFF
    dut.op2.value = 0x00000000
    await Timer(2)
    assert dut.out.value == 0


@cocotb.test
async def test_set_less_than_signed(dut):
    dut.mode.value = AluMode.SLT

    # op1 < op2
    dut.op1.value = -5
    dut.op2.value = -4
    await Timer(2)
    assert dut.out.value == 1

    # op1 == op2
    dut.op1.value = 10
    dut.op2.value = 10
    await Timer(2)
    assert dut.out.value == 0

    # op1 > op2
    dut.op1.value = 15
    dut.op2.value = -20
    await Timer(2)
    assert dut.out.value == 0

    # 32-bit wide number, op1 < op2
    # This operation is -1 < 0
    dut.op1.value = 0xFFFFFFFF
    dut.op2.value = 0x00000000
    await Timer(2)
    assert dut.out.value == 1

    # 32-bit wide number, op1 > op2
    # This operation is 0 < -1
    dut.op1.value = 0x00000000
    dut.op2.value = 0xFFFFFFFF
    await Timer(2)
    assert dut.out.value == 0


@cocotb.test
async def test_rem(dut):
    dut.mode.value = AluMode.REM

    dut.op1.value = -5
    dut.op2.value = 4
    await Timer(2)
    assert dut.out.value == -1

    dut.op1.value = -6
    dut.op2.value = 4
    await Timer(2)
    assert dut.out.value == -2

    dut.op1.value = -7
    dut.op2.value = 4
    await Timer(2)
    assert dut.out.value == -3

    dut.op1.value = -8
    dut.op2.value = 4
    await Timer(2)
    assert dut.out.value == 0

    dut.op1.value = 5
    dut.op2.value = -4
    await Timer(2)
    assert dut.out.value == 1

    dut.op1.value = 6
    dut.op2.value = -4
    await Timer(2)
    assert dut.out.value == 2

    dut.op1.value = 7
    dut.op2.value = -4
    await Timer(2)
    assert dut.out.value == 3

    dut.op1.value = 8
    dut.op2.value = -4
    await Timer(2)
    assert dut.out.value == 0

    dut.op1.value = -5
    dut.op2.value = -4
    await Timer(2)
    assert dut.out.value == -1

    dut.op1.value = -6
    dut.op2.value = -4
    await Timer(2)
    assert dut.out.value == -2

    dut.op1.value = -7
    dut.op2.value = -4
    await Timer(2)
    assert dut.out.value == -3

    dut.op1.value = -8
    dut.op2.value = -4
    await Timer(2)
    assert dut.out.value == 0


@cocotb.test
async def test_remu(dut):
    dut.mode.value = AluMode.REMU

    dut.op1.value = 5
    dut.op2.value = 4
    await Timer(2)
    assert dut.out.value == 1

    dut.op1.value = 6
    dut.op2.value = 4
    await Timer(2)
    assert dut.out.value == 2

    dut.op1.value = 7
    dut.op2.value = 4
    await Timer(2)
    assert dut.out.value == 3

    dut.op1.value = 8
    dut.op2.value = 4
    await Timer(2)
    assert dut.out.value == 0

    dut.op1.value = 0
    dut.op2.value = 4
    await Timer(2)
    assert dut.out.value == 0


@cocotb.test
async def test_invalid_mode(dut):
    dut.mode.value = AluMode.INVALID
    dut.op1.value = 1
    dut.op2.value = 2
    await Timer(2)
    assert dut.out.value == 0
