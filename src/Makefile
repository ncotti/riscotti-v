CROSS_COMPILE ?= riscv32-unknown-elf-

CC ?= gcc

SRC_DIRS := riscv_assembly_test_code/immediate_math

CFLAGS := -Wall -Wpedantic -march=rv32im -mdiv -mabi=ilp32 -nostdlib
LDFLAGS := -nostartfiles -Wl,--gc-sections -nostdlib
LDSCRIPT ?= linker.ld

include ../cotti-make/cottimake.mk