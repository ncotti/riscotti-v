
# ------------------------------------------------------------
# Instruction format encoders
# ------------------------------------------------------------
def riscv_rtype(rs1: int, rs2: int, rd: int, funct3: int, funct7: int, opcode:int) -> int:
    return (
        ((funct7 & 0b1111111) << 25) |
        ((rs2 & 0b11111) << 20) |
        ((rs1 & 0b11111) << 15) |
        ((funct3 & 0b111) << 12) |
        ((rd & 0b11111) << 7) |
        (opcode & 0b1111111))

def riscv_itype(rs1: int, rd: int, funct3: int,
                imm: int, opcode: int) -> int:
    return (
        ((imm & 0xFFF) << 20) |
        ((rs1 & 0x1F) << 15) |
        ((funct3 & 0x7) << 12) |
        ((rd & 0x1F) << 7) |
        (opcode & 0x7F)
    )


def riscv_stype(rs1: int, rs2: int, funct3: int,
                imm: int, opcode: int = 0b0100011) -> int:
    imm &= 0xFFF
    return (
        (((imm >> 5) & 0x7F) << 25) |
        ((rs2 & 0x1F) << 20) |
        ((rs1 & 0x1F) << 15) |
        ((funct3 & 0x7) << 12) |
        ((imm & 0x1F) << 7) |
        (opcode & 0x7F)
    )


def riscv_btype(rs1: int, rs2: int, funct3: int,
                offset: int) -> int:
    # offset is a signed byte offset from the current PC.
    imm = offset & 0x1FFF
    return (
        (((imm >> 12) & 0x1) << 31) |
        (((imm >> 5) & 0x3F) << 25) |
        ((rs2 & 0x1F) << 20) |
        ((rs1 & 0x1F) << 15) |
        ((funct3 & 0x7) << 12) |
        (((imm >> 1) & 0xF) << 8) |
        (((imm >> 11) & 0x1) << 7) |
        0b1100011
    )


def riscv_utype(rd: int, imm20: int, opcode: int) -> int:
    return (
        ((imm20 & 0xFFFFF) << 12) |
        ((rd & 0x1F) << 7) |
        (opcode & 0x7F)
    )


def riscv_jtype(rd: int, offset: int) -> int:
    imm = offset & 0x1FFFFF
    return (
        (((imm >> 20) & 0x1) << 31) |
        (((imm >> 1) & 0x3FF) << 21) |
        (((imm >> 11) & 0x1) << 20) |
        (((imm >> 12) & 0xFF) << 12) |
        ((rd & 0x1F) << 7) |
        0b1101111
    )

# ------------------------------------------------------------
# R-type arithmetic and logical instructions
# ------------------------------------------------------------

def riscv_add(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b000, 0b0000000, 0b0110011)


def riscv_sub(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b000, 0b0100000, 0b0110011)


def riscv_sll(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b001, 0b0000000, 0b0110011)


def riscv_slt(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b010, 0b0000000, 0b0110011)


def riscv_sltu(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b011, 0b0000000, 0b0110011)


def riscv_xor(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b100, 0b0000000, 0b0110011)


def riscv_srl(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b101, 0b0000000, 0b0110011)


def riscv_sra(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b101, 0b0100000, 0b0110011)


def riscv_or(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b110, 0b0000000, 0b0110011)


def riscv_and(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b111, 0b0000000, 0b0110011)


# ------------------------------------------------------------
# R-type M extension mutliplication and division instructions
# ------------------------------------------------------------

def riscv_mul(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b000, 0b0000001, 0b0110011)


def riscv_mulh(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b001, 0b0000001, 0b0110011)


def riscv_mulhsu(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b010, 0b0000001, 0b0110011)


def riscv_mulhu(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b011, 0b0000001, 0b0110011)


def riscv_div(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b100, 0b0000001, 0b0110011)


def riscv_divu(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b101, 0b0000001, 0b0110011)


def riscv_rem(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b110, 0b0000001, 0b0110011)


def riscv_remu(rd: int, rs1: int, rs2: int) -> int:
    return riscv_rtype(rs1, rs2, rd, 0b111, 0b0000001, 0b0110011)


# ------------------------------------------------------------
# I-type arithmetic and logical instructions
# ------------------------------------------------------------

def riscv_addi(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b000, imm, 0b0010011)


def riscv_slti(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b010, imm, 0b0010011)


def riscv_sltiu(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b011, imm, 0b0010011)


def riscv_xori(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b100, imm, 0b0010011)


def riscv_ori(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b110, imm, 0b0010011)


def riscv_andi(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b111, imm, 0b0010011)


def riscv_slli(rd: int, rs1: int, shamt: int) -> int:
    return riscv_itype(rs1, rd, 0b001, shamt & 0x1F,
                       0b0010011)


def riscv_srli(rd: int, rs1: int, shamt: int) -> int:
    return riscv_itype(rs1, rd, 0b101, shamt & 0x1F,
                       0b0010011)


def riscv_srai(rd: int, rs1: int, shamt: int) -> int:
    # funct7 = 0100000
    imm = (0b0100000 << 5) | (shamt & 0x1F)
    return riscv_itype(rs1, rd, 0b101, imm, 0b0010011)


# ------------------------------------------------------------
# Loads: I-type
# ------------------------------------------------------------

def riscv_lb(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b000, imm, 0b0000011)


def riscv_lh(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b001, imm, 0b0000011)


def riscv_lw(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b010, imm, 0b0000011)


def riscv_lbu(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b100, imm, 0b0000011)


def riscv_lhu(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b101, imm, 0b0000011)


# ------------------------------------------------------------
# Stores: S-type
# ------------------------------------------------------------

def riscv_sb(rs2: int, rs1: int, imm: int) -> int:
    return riscv_stype(rs1, rs2, 0b000, imm)


def riscv_sh(rs2: int, rs1: int, imm: int) -> int:
    return riscv_stype(rs1, rs2, 0b001, imm)


def riscv_sw(rs2: int, rs1: int, imm: int) -> int:
    return riscv_stype(rs1, rs2, 0b010, imm)


# ------------------------------------------------------------
# Conditional branches: B-type
# ------------------------------------------------------------

def riscv_beq(rs1: int, rs2: int, offset: int) -> int:
    return riscv_btype(rs1, rs2, 0b000, offset)


def riscv_bne(rs1: int, rs2: int, offset: int) -> int:
    return riscv_btype(rs1, rs2, 0b001, offset)


def riscv_blt(rs1: int, rs2: int, offset: int) -> int:
    return riscv_btype(rs1, rs2, 0b100, offset)


def riscv_bge(rs1: int, rs2: int, offset: int) -> int:
    return riscv_btype(rs1, rs2, 0b101, offset)


def riscv_bltu(rs1: int, rs2: int, offset: int) -> int:
    return riscv_btype(rs1, rs2, 0b110, offset)


def riscv_bgeu(rs1: int, rs2: int, offset: int) -> int:
    return riscv_btype(rs1, rs2, 0b111, offset)


# ------------------------------------------------------------
# Upper-immediate instructions: U-type
# ------------------------------------------------------------

def riscv_lui(rd: int, imm20: int) -> int:
    return riscv_utype(rd, imm20, 0b0110111)


def riscv_auipc(rd: int, imm20: int) -> int:
    return riscv_utype(rd, imm20, 0b0010111)


# ------------------------------------------------------------
# Unconditional jumps
# ------------------------------------------------------------

def riscv_jal(rd: int, offset: int) -> int:
    return riscv_jtype(rd, offset)


def riscv_jalr(rd: int, rs1: int, imm: int) -> int:
    return riscv_itype(rs1, rd, 0b000, imm, 0b1100111)


# ------------------------------------------------------------
# Memory ordering
# ------------------------------------------------------------

def riscv_fence(pred: int = 0b1111,
                succ: int = 0b1111,
                fm: int = 0) -> int:
    imm = ((fm & 0xF) << 8) | ((pred & 0xF) << 4) | (succ & 0xF)
    return riscv_itype(0, 0, 0b000, imm, 0b0001111)


# ------------------------------------------------------------
# Environment and breakpoint instructions
# ------------------------------------------------------------

def riscv_ecall() -> int:
    return 0x00000073


def riscv_ebreak() -> int:
    return 0x00100073


# Canonical NOP pseudoinstruction: addi x0, x0, 0
def riscv_nop() -> int:
    return riscv_addi(0, 0, 0)
