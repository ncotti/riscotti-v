.text
.global _start
.type _start, %function
_start:
    // Preload all registers
    addi x0, x0, 1
    addi x1, x0, 1
    addi x2, x0, 2
    addi x3, x0, 3
    addi x4, x0, 4
    addi x5, x0, 5
    addi x6, x0, 6
    addi x7, x0, 7
    addi x8, x0, 8
    addi x9, x0, 9
    addi x10, x0, 10
    addi x11, x0, 11
    addi x12, x0, 12
    addi x13, x0, 13
    addi x14, x0, 14
    addi x15, x0, 15
    addi x16, x0, 16
    addi x17, x0, 17
    addi x18, x0, 18
    addi x19, x0, 19
    addi x20, x0, 20
    addi x21, x0, 21
    addi x22, x0, 22
    addi x23, x0, 23
    addi x24, x0, 24
    addi x25, x0, 25
    addi x26, x0, 26
    addi x27, x0, 27
    addi x28, x0, 28
    addi x29, x0, 29
    addi x30, x0, 30
    addi x31, x0, 31

    // Synchronization barrier for the TB.
    // Start of immediate math
    addi x0, x0, 0x7FF

    // Test all ALU immediate operations.
    addi x1, x2, 0x53   // 0x55
    xori x3, x4, 0xFF   // 0xFB
    ori x5, x6, 0x10    // 0x16
    andi x7, x8, 0xFF   // 0x08
    slli x9, x10, 3     // 0x50
    srli x11, x12, 1    // 0x06
    srai x13, x14, 2    // 0x03
    slti x15, x16, 17   // 0x01
    sltiu x17, x18, 18  // 0x00

    // Preload all registers
    addi x0, x0, 1
    addi x1, x0, 1
    addi x2, x0, 2
    addi x3, x0, 3
    addi x4, x0, 4
    addi x5, x0, 5
    addi x6, x0, 6
    addi x7, x0, 7
    addi x8, x0, 8
    addi x9, x0, 9
    addi x10, x0, 10
    addi x11, x0, 11
    addi x12, x0, 12
    addi x13, x0, 13
    addi x14, x0, 14
    addi x15, x0, 15
    addi x16, x0, 16
    addi x17, x0, 17
    addi x18, x0, 18
    addi x19, x0, 19
    addi x20, x0, 20
    addi x21, x0, 21
    addi x22, x0, 22
    addi x23, x0, 23
    addi x24, x0, 24
    addi x25, x0, 25
    addi x26, x0, 26
    addi x27, x0, 27
    addi x28, x0, 28
    addi x29, x0, 29
    addi x30, x0, 30
    addi x31, x0, 31

    // Synchronization barrier for the TB.
    // Start of register math
    addi x0, x0, 0x7FF

    add x31, x31, x30
    sub x29, x29, x28
    xor x27, x27, x26
    or x25, x25, x24
    and x23, x23, x22
    mul x21, x21, x20
    mulh x19, x19, x18
    mulhsu x17, x17, x16
    mulhu x15, x15, x14
    div x13, x13, x12
    divu x11, x11, x10
    rem x9, x9, x8
    remu x7, x7, x6
    sll x5, x5, x4
    srl x3, x3, x2
    sra x1, x1, x0
    slt x0, x0, x1
    sltu x0, x1, x0

    // Synchronization barrier for the TB.
    // Start Upper instructions
    addi x0, x0, 0x7FF

    lui x1, 0xABC

    # The value of the PC at this label is printed in the symbol table
    # It should be 0x17c
    .global read_pc1
    read_pc1: auipc x2, 0xDEF

    // Preload registers for next test
    addi x1, x0, 1
    addi x2, x0, 1

    // Synchronization barrier for the TB.
    // Start of branch instructions
    addi x0, x0, 0x7FF

    .global read_pc2
    read_pc2: beq x1, x2, branch_eq;
    addi x0, x0, 0xAA  # Seeing this value at the output would be a failure
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA

    branch_eq:
    bne x0, x1, branch_ne
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA

    branch_ne:
    blt x0, x1, branch_lt
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA

    branch_lt:
    bge x1, x0, branch_ge
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA

    branch_ge:
    bltu x0, x1, branch_ltu
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA

    branch_ltu:
    bgeu x1, x0, branch_geu
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA
    addi x0, x0, 0xAA

    branch_geu:
    # Now, test the other way around, that branches are not being done
    beq x0, x1, read_pc2
    bne x0, x0, read_pc2
    blt x0, x0, read_pc2
    bge x0, x1, read_pc2
    bltu x0, x0, read_pc2
    bgeu x0, x1, read_pc2

.data
data_start:
.word 0x80808080
.word 0x81818181
.word 0x82828282
.word 0x83838383
.word 0x84848484
.word 0x85858585
.word 0x86868686
.word 0x87878787
.word 0x88888888
.word 0x89898989
.word 0x8A8A8A8A
.word 0x8B8B8B8B
.word 0x8C8C8C8C
.word 0x8D8D8D8D
.word 0x8E8E8E8E
.word 0x8F8F8F8F
