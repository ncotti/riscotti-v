import cocotb
from cocotb.triggers import Timer, RisingEdge
from cocotb.clock import Clock

from common.riscv_instructions import *
from common.data_types import *

REGISTER_LADDER_VALUES = [
    0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
    16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
]

async def reset(dut):
    c = Clock(dut.clk, 10, "ns")
    c.start()

    dut.rdata.value = 0x00
    dut.rstN.value = 1
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    dut.rstN.value = 0
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    dut.rstN.value = 1


async def register_preload(dut, register_values: list):
    for i in range(32):
        dut.op.value = riscv_addi(i, 0, register_values[i])
        await RisingEdge(dut.clk)

    # Flush pipeline
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)   # ID -> EX
    await RisingEdge(dut.clk)   # EX -> MEM
    await RisingEdge(dut.clk)   # MEM -> WB

@cocotb.test
async def test_imm_math(dut):
    await reset(dut)
    await register_preload(dut, REGISTER_LADDER_VALUES)

    instructions = [
        riscv_addi(1, 2, 0x53),
        riscv_xori(3, 4, 0xFF),
        riscv_ori(5, 6, 0x10),
        riscv_andi(7, 8, 0xFF),
        riscv_slli(9, 10, 3),
        riscv_srli(11, 12, 1),
        riscv_srai(13, 14, 2),
        riscv_slti(15, 16, 17),
        riscv_sltiu(17, 18, 18),
        riscv_nop(),
    ]

    expected_values = [
        0,  # ID -> EX
        0x53 + 2,
        4 ^ 0xFF,
        6 | 0x10,
        8 & 0xFF,
        10 << 3,
        12 >> 1,
        14 >> 2,
        0x01,
        0x00
    ]

    for op, value in zip(instructions, expected_values):
        dut.op.value = op

        await RisingEdge(dut.clk)
        await Timer(1, "ns")
        assert dut.we.value == 0
        assert dut.addr.value == value

@cocotb.test
async def test_register_math(dut):
    await reset(dut)
    await register_preload(dut, REGISTER_LADDER_VALUES)

    instructions = [
        riscv_add(31, 31, 30),
        riscv_sub(29, 29, 28),
        riscv_xor(27, 27, 26),
        riscv_or(25, 25, 24),
        riscv_and(23, 23, 22),
        riscv_mul(21, 21, 20),
        riscv_mulh(19, 19, 18),
        riscv_mulhsu(17, 17, 16),
        riscv_mulhu(15, 15, 14),
        riscv_div(13, 13, 12),
        riscv_divu(11, 11, 10),
        riscv_rem(9, 9, 8),
        riscv_remu(7, 7, 6),
        riscv_sll(5, 5, 4),
        riscv_srl(3, 3, 2),
        riscv_sra(1, 1, 0),
        riscv_slt(0, 0, 11),
        riscv_sltu(0, 11, 0),
        riscv_nop(),
    ]

    expected_values = [
        0,  # ID -> EX
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
        0
    ]

    for op, value in zip(instructions, expected_values):
        dut.op.value = op

        await RisingEdge(dut.clk)
        await Timer(1, "ns")
        assert dut.we.value == 0
        assert dut.addr.value == value




@cocotb.test
async def test_load_instructions(dut):
    await reset(dut)
    await register_preload(dut, REGISTER_LADDER_VALUES)

    ram = [
        0xFFFFFFFF,
        0x000000F9,
        0x0000Fabc,
        0xF1234567,
        0x000000CC,
        0x0000BEEF,
    ]

    instructions = [
        riscv_lb(10, 4, 0),
        riscv_lh(11, 4, 4),
        riscv_lw(12, 4, 8),
        riscv_lbu(13, 4, 12),
        riscv_lhu(14, 4, 16),
        riscv_addi(0, 10, 0),
        riscv_addi(0, 11, 0),
        riscv_addi(0, 12, 0),
        riscv_addi(0, 13, 0),
        riscv_addi(0, 14, 0),
        riscv_nop(),
    ]

    expected_addr = [
        0, # ID -> EX,
        4,
        8,
        12,
        16,
        20,
        (ram[1] & 0xFF) | 0xFFFFFF00,
        (ram[2] & 0xFFFF) | 0xFFFF0000,
        ram[3] & 0xFFFFFFFF,
        ram[4] & 0xFF,
        ram[5] & 0xFFFF
    ]

    rdata_wb = 0
    for op, addr in zip(instructions, expected_addr):
        dut.op.value = op

        await RisingEdge(dut.clk)
        await Timer(1, "ns")
        assert dut.we.value == 0
        assert dut.addr.value == addr

        # The value from the RAM should be available on the next clock cycle
        dut.rdata.value = rdata_wb

        if (addr < len(ram) * 4):
            rdata_wb = ram[addr >> 2]
        else:
            rdata_wb = 0


@cocotb.test
async def test_store_instruction(dut):
    await reset(dut)

    # Addi instructions only support up to 12 bits.
    register_values = [
        0,0xFAB,0xBCD,0x678,
        4,5,6,7,8,9,10,11,12,13,14,15,
        16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
    ]
    await register_preload(dut, register_values)

    instructions = [
        riscv_sb(1, 4, 8),
        riscv_sh(2, 4, 12),
        riscv_sw(3, 4, 16),
        riscv_nop(),
    ]

    expected_addr = [
        0, # ID -> EX,
        12,
        16,
        20
    ]

    expected_wdata = [
        0,
        0xFAB,
        0xBCD,
        0x678
    ]

    expected_we = [
        0,
        0b0001,
        0b0011,
        0b1111
    ]

    for op, addr, wdata, we in zip(instructions, expected_addr, expected_wdata, expected_we):
        dut.op.value = op

        await RisingEdge(dut.clk)
        await Timer(1, "ns")
        await Timer(1, "ns")

        assert dut.we.value == we
        assert dut.addr.value == addr
        assert dut.wdata.value == wdata

@cocotb.test
async def test_branch_instruction(dut):
    await reset(dut)
    assert dut.pc.value == 0

    dut.op.value = riscv_nop()  # This instruction does not exist yet.
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.pc.value == 4
    dut.op.value = riscv_addi(1, 0, 10) # PC = 0
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.pc.value == 8
    dut.op.value = riscv_addi(2, 0, 20) # PC = 4
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Since the PC == 12, that means that the PC related to the branch
    # instruction is PC - 4,
    assert dut.pc.value == 12
    dut.op.value = riscv_beq(0, 0, 32)  # PC = 8
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # ID -> EX
    assert dut.pc.value == 16
    dut.op.value = riscv_nop()  # PC = 12
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # EX -> MEM
    assert dut.pc.value == 20
    dut.op.value = riscv_nop()  # PC = 16
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # BEQ branch happened
    assert dut.pc.value == 8 + 32
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Wait until the first address is read from the ROM
    assert dut.pc.value == 12 + 32
    dut.op.value = riscv_bne(1, 2, 32) # PC = 40
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # ID -> EX
    assert dut.pc.value == 48
    dut.op.value = riscv_nop() # PC = 44
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # EX -> MEM
    assert dut.pc.value == 52
    dut.op.value = riscv_nop() # PC = 48
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # BNE branch happened
    assert dut.pc.value == 40 + 32
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Wait until the first address is read from the ROM
    assert dut.pc.value == 44 + 32
    dut.op.value = riscv_blt(1, 2, 32) # PC = 72
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # ID -> EX
    assert dut.pc.value == 80
    dut.op.value = riscv_nop() # PC = 76
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # EX -> MEM
    assert dut.pc.value == 84
    dut.op.value = riscv_nop() # PC = 80
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # BLT branch happened
    assert dut.pc.value == 72 + 32
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Wait until the first address is read from the ROM
    # Now, a branch conditions evaluated to false
    assert dut.pc.value == 76 + 32
    dut.op.value = riscv_beq(1, 2, 32) # PC 104
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # ID -> EX
    assert dut.pc.value == 112
    dut.op.value = riscv_nop() # 108
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # EX -> MEM
    assert dut.pc.value == 116
    dut.op.value = riscv_nop() # 112
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Branch did not happen
    assert dut.pc.value == 120


@cocotb.test
async def test_load_upper_imm(dut):
    await reset(dut)

    # ID
    dut.op.value = riscv_lui(1, 0x45678)

    # EX
    await RisingEdge(dut.clk)
    # Use nops here, to not make a dependency of the next operation on the
    # write-back of the previous one (register value is not updated, and is
    # being used)
    dut.op.value = riscv_nop()

    # MEM
    await RisingEdge(dut.clk)
    await Timer(1, "ns")
    assert dut.addr.value == 0x45678000

    # WB
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # ID
    dut.op.value = riscv_addi(1, 1, 0x123)
    await RisingEdge(dut.clk)   # EX
    await RisingEdge(dut.clk)   # MEM
    await Timer(1, "ns")
    await Timer(1, "ns")
    assert dut.addr.value == 0x45678123



@cocotb.test
async def test_first_instruction_after_reset_is_not_executed(dut):
    """After leaving the reset, the PC points to the address "0", but
    the value from the ROM is not read until the next clock cycle. Therefore,
    the first instruction read after reset is junk, and should not be used.
    """
    await reset(dut)
    assert dut.pc.value == 0

    # We just came back from reset, there should'nt be any instructions here,
    # because the PC == 0, means that the instruction has not yet been read from
    # ROM

    # IF1
    #       ID0
    dut.op.value = riscv_addi(1, 0, 0x123)
    await RisingEdge(dut.clk)

    #       ID1
    #           EX0
    dut.op.value = riscv_addi(2, 0, 0x456)  # This should be the only valid
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    #           EX1
    #               MEM0
    assert dut.addr.value == 0
    await RisingEdge(dut.clk)
    await Timer(dut.clk)

    #               MEM1
    #                   WB0
    assert dut.addr.value == 0x456



@cocotb.test
async def test_add_upper_imm_to_pc(dut):
    await reset(dut)

    assert dut.pc.value == 0
    dut.op.value = riscv_nop()  # First instruction is not executed

    await RisingEdge(dut.clk)   # PC = 0
    await RisingEdge(dut.clk)   # PC = 4
    await RisingEdge(dut.clk)   # PC = 8
    await Timer(1, "ns")

    # ID
    assert dut.pc.value == 12
    dut.op.value = riscv_auipc(1, 0x12345) # PC = 8

    # EX, MEM
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.addr.value == 0x12345008

@cocotb.test
async def test_jump_and_link(dut):
    await reset(dut)

    # First operation is ignored
    assert dut.pc.value == 0
    dut.op.value = riscv_nop()


    await RisingEdge(dut.clk) # PC = 0
    await RisingEdge(dut.clk) # PC = 4
    await RisingEdge(dut.clk) # PC = 8
    await Timer(1, "ns")

    # Send JAL
    assert dut.pc.value == 12
    dut.op.value = riscv_jal(1, 64) # PC = 8
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # EX
    assert dut.pc.value == 16
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # MEM
    assert dut.pc.value == 20
    assert dut.addr.value == 8 + 4

    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # PC should be updated, give a cycle until the memory settles
    assert dut.pc.value == 8 + 64
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # JALR, using the value from the previous jump, which should be
    # PC + 4 = 12
    assert dut.pc.value == 76
    dut.op.value = riscv_jalr(5, 1, 32) # PC = 72 + 4, but jumping to 12 + 32 = 44
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # EX
    assert dut.pc.value == 80
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # MEM
    assert dut.pc.value == 84
    assert dut.addr.value == 72 + 4
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # PC should be updated
    assert dut.pc.value == 44

@cocotb.test
async def test_data_hazard_single_store(dut):
    await reset(dut)

    # Initialize registers and flush the pipeline
    dut.op.value = riscv_addi(1, 0, 10)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(3, 0, 30)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(5, 0, 50)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(6, 0, 60)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(15, 0, 150)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # Source instruction (SRC) wants to store X2.
    # The following instructions (DST) use X2, while this instruction is in
    # the pipeline
    dut.op.value = riscv_sub(2, 3, 1)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # First hazard:
    # SRC in EX, DST in ID
    # Move the alu output directly into its input (from MEM into EX).
    dut.op.value = riscv_and(12, 2, 5)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Second hazard:
    # SRC in MEM, DST in ID
    # Move the rd register directly into the ALU input (from WB into EX).
    dut.op.value = riscv_or(13, 6, 2)
    assert dut.addr.value == 30 - 10
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Third hazard:
    # SRC in WB, DST in ID
    # The register file reads and writes the same register, so the output
    # should be bypassed.
    dut.op.value = riscv_add(14, 2, 2)
    assert dut.addr.value == 50 & 20
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # This instruction has no hazard, since SRC finished the pipeline
    dut.op.value = riscv_sw(15, 2, 100)
    assert dut.addr.value == 60 | 20
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.addr.value == 20 + 20
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.addr.value == 20 + 100
    assert dut.wdata.value == 150

@cocotb.test
async def test_data_hazard_repeated_store(dut):
    await reset(dut)

    # Initialize registers and flush the pipeline
    dut.op.value = riscv_addi(1, 0, 10)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(2, 0, 20)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(3, 0, 30)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(4, 0, 40)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(5, 0, 50)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # The first instruction and all the following ones use and store
    # the "x1" register.
    dut.op.value = riscv_add(1, 1, 2)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Data hazard 1:
    # SRC in EX, DST in ID
    # The output of the ALU should be used as the input.
    dut.op.value = riscv_add(1, 1, 3)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Data hazard 2:
    # SRC in MEM, DST in ID and EX
    # Once again, use the value from the ALU as the new input.
    dut.op.value = riscv_add(1, 1, 4)
    assert dut.addr.value == 30
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # Data hazard 3:
    # SRC in WB, DST in ID, EX and MEM
    # Use the value from the ALU once again., the value of the register
    # file is outdated.
    dut.op.value = riscv_add(1, 1, 5)
    assert dut.addr.value == 60

    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.addr.value == 100

    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.addr.value == 150

@cocotb.test
async def test_data_hazard_memory(dut):
    """
    Whenever you have an instruction that depends on a value that is read from
    memory, you need to stall the pipeline until that value is read, since
    it is not available until the "WB" stage.
    E.g.:
    lw x1, 4(x2)
    add x1, x1, x3
    """
    await reset(dut)

    # First instruction is a mock
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)

    # Initialize registers and flush the pipeline
    dut.op.value = riscv_addi(1, 0, 0)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(2, 0, 20)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(3, 0, 30)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_addi(4, 0, 40)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)

    # LW in ID
    dut.op.value = riscv_lw(1, 2, 8)    # PC_i = PC0; PC = PC0 + 4
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in EX, ADD in ID
    # We need to stall here, so that the current PC, which points to
    # the next instruction, does not move.
    old_pc = dut.pc.value
    dut.op.value = riscv_add(1, 1, 3)   # PC_i = PC0 + 4; PC = PC0 + 8
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in MEM, NOP in EX, ADD in ID
    # The pipeline is stalled, which means:
    # 1. The program counter should retain its previous value.
    # 2. A "NOP" instruction should be forced into the EX stage of the pipeline.
    # 3. The previous "ADD" command should be re-entered into the ID stage.
    assert dut.pc.value == old_pc
    assert dut.addr.value == 28         # Address to be read by the LW instruction
    dut.op.value = riscv_sub(1, 1, 4)   # PC_i = PC0 + 8; PC = PC0 + 8
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in WB, NOP in MEM, ADD in EX, SUB in ID
    # The pipeline is has resumed, which means:
    # 1. PC value should increment as normal.
    # 2. The NOP instruction is in the MEM stage.
    # 3. Value from WB stage should be bypassed to the EX stage for the ADD.
    assert dut.pc.value == int(old_pc) + 4
    dut.op.value = riscv_sub(1, 1, 4)   # PC_i = PC0 + 8; PC = PC0 + 12
    dut.rdata.value = 34                # Value read from address 28 in memory
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # NOP in WB, ADD in MEM, SUB in EX, NOP in ID
    assert dut.addr.value == 30 + 34
    assert dut.pc.value == int(old_pc) + 8
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # ADD in WB, SUB in MEM, NOP in EX
    assert dut.pc.value == int(old_pc) + 12
    assert dut.addr.value == 64 - 40

@cocotb.test
async def test_data_hazard_memcpy(dut):
    """
    A memcpy is a very common operation.

    By default, a memcpy is not a hazard per se, an operation like this:

    lw x1, 0(x2)
    sw x1, 4(x2)

    Would result in "x1" stalling the pipeline by one cycle, and then storing
    the value read from address "x2 + 0" into "x2 + 4".

    However, since "memcpy" is such a common function, we want to avoid
    stalling the pipeline just for this particular case.
    """
    await reset(dut)

    # LW in ID
    old_pc = dut.pc.value
    dut.op.value = riscv_lw(1, 2, 0)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in EX, SW in ID
    assert dut.pc.value == int(old_pc) + 4
    dut.op.value = riscv_sw(1, 2, 4)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in MEM, SW in EX, ADD in ID
    assert dut.pc.value == int(old_pc) + 8
    assert dut.addr.value == 0
    dut.op.value = riscv_add(1, 1, 1)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in WB, SW in MEM, ADD in EX, NOP in ID
    # Here, the value read from WB should be forwarded directly into
    # the MEM stage, while the updated value from MEM should be forwarded
    # into EX.
    assert dut.pc.value == int(old_pc) + 12
    assert dut.addr.value == 4
    assert dut.wdata.value == 0
    dut.rdata.value = 0xAB
    await Timer(1, "ns")
    assert dut.wdata.value == 0xAB
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    assert dut.pc.value == int(old_pc) + 16
    assert dut.addr.value == 0xAB + 0xAB


@cocotb.test
async def test_data_hazard_memcpy_but_address(dut):
    """
    A memcpy where the address is the one that changes should stall
    the pipeline, because the operation "x5 + imm" must be done in the
    EX stage.

    lw x5, 12(x6)
    sw x7, 16(x5)
    """
    await reset(dut)

    # Initialize registers and flush the pipeline
    dut.op.value = riscv_addi(7, 0, 70)
    await RisingEdge(dut.clk)
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")


    old_pc = dut.pc.value
    dut.op.value = riscv_lw(5, 6, 12)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in EX, SW in ID
    assert dut.pc.value == int(old_pc) + 4
    dut.op.value = riscv_sw(7, 5, 16)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in MEM, SW in EX, ADD in ID
    # Having the LW in MEM, with the address being the one changing, should
    # stall the pipeline
    assert dut.pc.value == int(old_pc) + 4
    assert dut.addr.value == 12
    dut.op.value = riscv_add(10, 5, 0)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in WB, NOP in MEM, SW in EX, ADD in ID
    assert dut.pc.value == int(old_pc) + 8
    dut.rdata.value = 0xAD
    dut.op.value = riscv_add(10, 5, 0)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # NOP in WB, SW in MEM, ADD in EX, NOP in ID
    assert dut.pc.value == int(old_pc) + 12
    assert dut.addr.value == 0xAD + 16
    assert dut.wdata.value == 70
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # SW in WB, ADD in MEM
    assert dut.pc.value == int(old_pc) + 16
    assert dut.addr.value == 0xAD


@cocotb.test
async def test_data_hazard_memcpy_both_arguments(dut):
    """
    A memcpy where both the address and the value change
    should only cost a single cycle of stall

    lw x1, 12(x2)
    sw x1, 16(x1)
    """
    await reset(dut)

    old_pc = dut.pc.value
    dut.op.value = riscv_lw(1, 2, 12)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in EX, SW in ID
    assert dut.pc.value == int(old_pc) + 4
    dut.op.value = riscv_sw(1, 1, 16)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in MEM, SW in EX, ADD in ID
    # Having the LW in MEM, with the address being the one changing, should
    # stall the pipeline
    assert dut.pc.value == int(old_pc) + 4
    assert dut.addr.value == 12
    dut.op.value = riscv_add(1, 1, 1)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # LW in WB, NOP in MEM, SW in EX, ADD in ID
    assert dut.pc.value == int(old_pc) + 8
    dut.rdata.value = 0xAD
    dut.op.value = riscv_add(1, 1, 1)
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # NOP in WB, SW in MEM, ADD in EX, NOP in ID
    assert dut.pc.value == int(old_pc) + 12
    assert dut.addr.value == 0xAD + 16
    assert dut.wdata.value == 0xAD
    dut.op.value = riscv_nop()
    await RisingEdge(dut.clk)
    await Timer(1, "ns")

    # SW in WB, ADD in MEM
    assert dut.pc.value == int(old_pc) + 16
    assert dut.addr.value == 0xAD + 0xAD
