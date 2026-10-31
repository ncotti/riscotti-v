# riscotti-v
RISC-V core implementation

sudo apt install gcc-riscv64-unknown-elf binutils-riscv64-unknown-elf

## RISCV GCC

Follow the Cotti-docs documentation and install CRossTool NG.

```bash
$ ./ct-ng list-samples
[...]
riscv32-unknown-elf
```

```bash
./ct-ng riscv32-unknown-elf
# Will leave configuration by default
# ./ct-ng nconfig

./ct-ng build
echo "PATH=\$PATH:/home/\$USER/x-tools/riscv32-unknown-elf/bin" >> /home/$USER/.bashrc
```
