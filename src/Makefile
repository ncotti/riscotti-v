CROSS_COMPILE ?= riscv32-unknown-elf-

CC ?= gcc

SRC_DIRS := .

CFLAGS := -Wall -Wpedantic -march=rv32im -mdiv -mabi=ilp32 -nostdlib
LDFLAGS := -nostartfiles -Wl,--gc-sections -nostdlib
LDSCRIPT ?= linker.ld

EXE := rom

include ../cotti-make/cottimake.mk