/* SPDX-License-Identifier: GPL-3.0-or-later */
/* Copyright (C) 2026  Nicolas Gabriel Cotti */

/*-----------------------------------------------------------------------------
*   Output format
-----------------------------------------------------------------------------*/
OUTPUT_FORMAT("elf32-littleriscv")
OUTPUT_ARCH(riscv)
ENTRY(_start)

/*-----------------------------------------------------------------------------
*   Memory regions' origins and lengths
-----------------------------------------------------------------------------*/
/* NOR flash (SMC CS0) Remapped from 0x4000_0000 to 0x7000_0000 */
HIDDEN(ld_rom_origin          = 0x00000000);
HIDDEN(ld_rom_length          = 0x00000400);   /* 1 KB */

/*-----------------------------------------------------------------------------
*   Memory sections
-----------------------------------------------------------------------------*/
MEMORY {
    rom   (rx)    :   ORIGIN = 0x00000000,   LENGTH = 0x00000400
}

/*-----------------------------------------------------------------------------
*   Section definitions
-----------------------------------------------------------------------------*/
SECTIONS {
    .text : ALIGN(4) {
        *(.text*)
    } >rom AT>rom
    PROVIDE(ld_text_lma = LOADADDR(.text));
    PROVIDE(ld_text_vma = ADDR(.text));
    PROVIDE(ld_text_size = SIZEOF(.text));


    .rodata : ALIGN(4) {
        *(.rodata*)
    } >rom AT>rom
    PROVIDE(ld_rodata_lma = LOADADDR(.rodata));
    PROVIDE(ld_rodata_vma = ADDR(.rodata));
    PROVIDE(ld_rodata_size = SIZEOF(.rodata));

    .data : ALIGN(4) {
        *(.data*)
    } >rom AT>rom
    PROVIDE(ld_rodata_lma = LOADADDR(.data));
    PROVIDE(ld_rodata_vma = ADDR(.data));
    PROVIDE(ld_rodata_size = SIZEOF(.data));
}
