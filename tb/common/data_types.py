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
    MULU = 15
    DIVU = 16
    REMU = 17
    MULHU = 18
    INVALID = 19
