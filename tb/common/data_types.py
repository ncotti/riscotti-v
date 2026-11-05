from enum import IntEnum


class AluMode(IntEnum):
    ADD = 0
    SUB = 1
    MUL = 2
    DIV = 3
    XOR = 4
    OR  = 5
    AND = 6
    SLL = 7
    SRL = 8
    SRA = 9
    SLT = 10
    SLTU = 11
    REM = 12
    MULH = 13
    MULHSU = 14
    DIVU = 15
    REMU = 16
    MULHU = 17
    INVALID = 18


class LoadMode(IntEnum):
    LM_B = 0
    LM_H = 1
    LM_W = 2
    LM_BU = 4
    LM_HU = 5
    LM_NONE = 7

class BranchMode(IntEnum):
    BM_EQ   = 0
    BM_NE   = 1
    BM_NONE = 2
    BM_LT   = 4
    BM_GE   = 5
    BM_LTU  = 6
    BM_GEU  = 7