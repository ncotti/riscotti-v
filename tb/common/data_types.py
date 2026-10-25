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
