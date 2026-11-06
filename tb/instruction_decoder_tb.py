import cocotb
from cocotb.triggers import Timer

from common.riscv_instructions import *
from common.data_types import *


@cocotb.test
async def test_r_instructions(dut):
    riscv_instructions = [
        riscv_add,
        riscv_sub,
        riscv_xor,
        riscv_or,
        riscv_and,
        riscv_sll,
        riscv_srl,
        riscv_sra,
        riscv_slt,
        riscv_sltu,
    ]

    expected_alu_modes = [
        AluMode.ADD,
        AluMode.SUB,
        AluMode.XOR,
        AluMode.OR,
        AluMode.AND,
        AluMode.SLL,
        AluMode.SRL,
        AluMode.SRA,
        AluMode.SLT,
        AluMode.SLTU,
    ]

    index = 0
    for instruction, expected_alu_mode in zip(
        riscv_instructions, expected_alu_modes
    ):
        index = index + 1
        dut.op.value = instruction(index, index + 1, index + 2)

        await Timer(1)
        assert dut.alu_mode.value == expected_alu_mode
        assert dut.rd_idx.value == index
        assert dut.rs1_idx.value == index + 1
        assert dut.rs2_idx.value == index + 2
        assert dut.imm.value == 0
        assert dut.imm_enable.value == 0
        assert dut.op_valid.value == 1
        assert dut.we.value == 0
        assert dut.load_mode.value == LoadMode.LM_NONE
        assert dut.branch_mode.value == BranchMode.BM_NONE
        assert dut.pc_enable.value == 0


@cocotb.test
async def test_m_extension_instructions(dut):
    riscv_instructions = [
        riscv_mul,
        riscv_mulh,
        riscv_mulhsu,
        riscv_mulhu,
        riscv_div,
        riscv_divu,
        riscv_rem,
        riscv_remu,
    ]

    expected_alu_modes = [
        AluMode.MUL,
        AluMode.MULH,
        AluMode.MULHSU,
        AluMode.MULHU,
        AluMode.DIV,
        AluMode.DIVU,
        AluMode.REM,
        AluMode.REMU,
    ]

    index = 0
    for instruction, expected_alu_mode in zip(
        riscv_instructions, expected_alu_modes
    ):
        index = index + 1
        dut.op.value = instruction(index, index + 1, index + 2)

        await Timer(1)
        assert dut.alu_mode.value == expected_alu_mode
        assert dut.rd_idx.value == index
        assert dut.rs1_idx.value == index + 1
        assert dut.rs2_idx.value == index + 2
        assert dut.imm.value == 0
        assert dut.imm_enable.value == 0
        assert dut.op_valid.value == 1
        assert dut.we.value == 0
        assert dut.load_mode.value == LoadMode.LM_NONE
        assert dut.branch_mode.value == BranchMode.BM_NONE
        assert dut.pc_enable.value == 0


@cocotb.test
async def test_i_alu_instructions(dut):
    riscv_instructions = [
        riscv_addi,
        riscv_xori,
        riscv_ori,
        riscv_andi,
        riscv_slli,
        riscv_srli,
        riscv_srai,
        riscv_slti,
        riscv_sltiu,
    ]

    expected_alu_modes = [
        AluMode.ADD,
        AluMode.XOR,
        AluMode.OR,
        AluMode.AND,
        AluMode.SLL,
        AluMode.SRL,
        AluMode.SRA,
        AluMode.SLT,
        AluMode.SLTU,
    ]

    index = 0
    for instruction, expected_alu_mode in zip(
        riscv_instructions, expected_alu_modes
    ):
        index = index + 1
        dut.op.value = instruction(index, index + 1, index + 2)

        await Timer(1)
        assert dut.alu_mode.value == expected_alu_mode
        assert dut.rd_idx.value == index
        assert dut.rs1_idx.value == index + 1
        assert dut.rs2_idx.value == 0
        assert dut.imm.value == index + 2
        assert dut.imm_enable.value == 1
        assert dut.op_valid.value == 1
        assert dut.we.value == 0
        assert dut.load_mode.value == LoadMode.LM_NONE
        assert dut.branch_mode.value == BranchMode.BM_NONE
        assert dut.pc_enable.value == 0


@cocotb.test
async def test_load_instructions(dut):
    riscv_instructions = [
        riscv_lb,
        riscv_lh,
        riscv_lw,
        riscv_lbu,
        riscv_lhu,
    ]

    expected_load_mode = [
        LoadMode.LM_B,
        LoadMode.LM_H,
        LoadMode.LM_W,
        LoadMode.LM_BU,
        LoadMode.LM_HU
    ]

    index = 0
    for (instruction, load_mode) in zip(riscv_instructions, expected_load_mode):
        index = index + 1
        dut.op.value = instruction(index, index + 1, index + 2)

        await Timer(1)
        assert dut.alu_mode.value == AluMode.ADD
        assert dut.rd_idx.value == index
        assert dut.rs1_idx.value == index + 1
        assert dut.rs2_idx.value == 0
        assert dut.imm.value == index + 2
        assert dut.imm_enable.value == 1
        assert dut.op_valid.value == 1
        assert dut.we.value == 0
        assert dut.load_mode.value == load_mode
        assert dut.branch_mode.value == BranchMode.BM_NONE
        assert dut.pc_enable.value == 0


@cocotb.test
async def test_store_instructions(dut):
    riscv_instructions = [
        riscv_sb,
        riscv_sh,
        riscv_sw,
    ]

    expected_we = [
        0b0001,
        0b0011,
        0b1111
    ]

    index = 0
    for (instruction, we) in zip(riscv_instructions, expected_we):
        index = index + 1
        dut.op.value = instruction(index, index + 1, index + 2)

        await Timer(1)
        assert dut.alu_mode.value == AluMode.ADD
        assert dut.rd_idx.value == 0
        assert dut.rs1_idx.value == index + 1
        assert dut.rs2_idx.value == index
        assert dut.imm.value == index + 2
        assert dut.imm_enable.value == 1
        assert dut.op_valid.value == 1
        assert dut.we.value == we
        assert dut.load_mode.value == LoadMode.LM_NONE
        assert dut.branch_mode.value == BranchMode.BM_NONE
        assert dut.pc_enable.value == 0

@cocotb.test
async def test_branch_instructions(dut):
    riscv_instructions = [
        riscv_beq,
        riscv_bne,
        riscv_blt,
        riscv_bge,
        riscv_bltu,
        riscv_bgeu,
    ]

    expected_branches = [
        BranchMode.BM_EQ,
        BranchMode.BM_NE,
        BranchMode.BM_LT,
        BranchMode.BM_GE,
        BranchMode.BM_LTU,
        BranchMode.BM_GEU
    ]

    index = 0
    for (instruction, branch_mode) in zip(riscv_instructions, expected_branches):
        index = index + 1

        # Note, offset can only be even
        dut.op.value = instruction(index, index + 1, index + 2 + (index % 2))

        await Timer(1)
        assert dut.alu_mode.value == AluMode.ADD
        assert dut.rd_idx.value == 0
        assert dut.rs1_idx.value == index
        assert dut.rs2_idx.value == index + 1
        assert dut.imm.value == (index + 2 + (index % 2))
        assert dut.imm_enable.value == 1
        assert dut.op_valid.value == 1
        assert dut.we.value == 0
        assert dut.load_mode.value == LoadMode.LM_NONE
        assert dut.branch_mode.value == branch_mode
        assert dut.pc_enable.value == 1


@cocotb.test
async def test_jump_instructions(dut):
    dut.op.value = riscv_jal(1, 0xABC)

    await Timer(1)
    assert dut.alu_mode.value == AluMode.ADD
    assert dut.rd_idx.value == 1
    assert dut.rs1_idx.value == 0
    assert dut.rs2_idx.value == 0
    assert dut.imm.value == 0xABC
    assert dut.imm_enable.value == 1
    assert dut.op_valid.value == 1
    assert dut.we.value == 0
    assert dut.load_mode.value == LoadMode.LM_NONE
    assert dut.branch_mode.value == BranchMode.BM_JUMP
    assert dut.pc_enable.value == 1

    dut.op.value = riscv_jalr(2, 3, 0x123)

    await Timer(1)
    assert dut.alu_mode.value == AluMode.ADD
    assert dut.rd_idx.value == 2
    assert dut.rs1_idx.value == 3
    assert dut.rs2_idx.value == 0
    assert dut.imm.value == 0x123
    assert dut.imm_enable.value == 1
    assert dut.op_valid.value == 1
    assert dut.we.value == 0
    assert dut.load_mode.value == LoadMode.LM_NONE
    assert dut.branch_mode.value == BranchMode.BM_JUMP
    assert dut.pc_enable.value == 0


@cocotb.test
async def test_load_upper_instructions(dut):
    dut.op.value = riscv_auipc(1, 0xABCDE)

    await Timer(1)
    assert dut.alu_mode.value == AluMode.ADD
    assert dut.rd_idx.value == 1
    assert dut.rs1_idx.value == 0
    assert dut.rs2_idx.value == 0
    assert dut.imm.value == 0xABCDE000
    assert dut.imm_enable.value == 1
    assert dut.op_valid.value == 1
    assert dut.we.value == 0
    assert dut.load_mode.value == LoadMode.LM_NONE
    assert dut.branch_mode.value == BranchMode.BM_NONE
    assert dut.pc_enable.value == 1

    dut.op.value = riscv_lui(2, 0x12345)

    await Timer(1)
    assert dut.alu_mode.value == AluMode.ADD
    assert dut.rd_idx.value == 2
    assert dut.rs1_idx.value == 0
    assert dut.rs2_idx.value == 0
    assert dut.imm.value == 0x12345000
    assert dut.imm_enable.value == 1
    assert dut.op_valid.value == 1
    assert dut.we.value == 0
    assert dut.load_mode.value == LoadMode.LM_NONE
    assert dut.branch_mode.value == BranchMode.BM_NONE
    assert dut.pc_enable.value == 0


@cocotb.test
async def test_env_instructions(dut):
    assert 0

@cocotb.test
async def test_fence(dut):
    assert 0
