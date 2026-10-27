.text
.global _start
.type _start, %function
_start:
    // Preload all registers
    addi x0, x0, 1
    addi x1, x1, 1
    addi x2, x2, 2
    addi x3, x3, 3
    addi x4, x4, 4
    addi x5, x5, 5
    addi x6, x6, 6
    addi x7, x7, 7
    addi x8, x8, 8
    addi x9, x9, 9
    addi x10, x10, 10
    addi x11, x11, 11
    addi x12, x12, 12
    addi x13, x13, 13
    addi x14, x14, 14
    addi x15, x15, 15
    addi x16, x16, 16
    addi x17, x17, 17
    addi x18, x18, 18
    addi x19, x19, 19
    addi x20, x20, 20
    addi x21, x21, 21
    addi x22, x22, 22
    addi x23, x23, 23
    addi x24, x24, 24
    addi x25, x25, 25
    addi x26, x26, 26
    addi x27, x27, 27
    addi x28, x28, 28
    addi x29, x29, 29
    addi x30, x30, 30
    addi x31, x31, 31

    // Synchronization barrier for the TB.
    addi x0, x0, 0xFF

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
