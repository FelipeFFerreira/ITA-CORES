/media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-as -march=rv32i -mabi=ilp32   hello.S -o hello.o 
/media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-as -march=rv32i -mabi=ilp32   start.S -o start.o 
/media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-as -march=rv32i -mabi=ilp32   putchar.S -o putchar.o 
/media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-as -march=rv32i -mabi=ilp32   wait.S -o wait.o 
/media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc -I. -O2 -fno-pic -march=rv32i -mabi=ilp32 -fno-stack-protector -w -Wl,--no-relax  -c print.c
/media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc -I. -O2 -fno-pic -march=rv32i -mabi=ilp32 -fno-stack-protector -w -Wl,--no-relax  -c memcpy.c
/media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-gcc -I. -O2 -fno-pic -march=rv32i -mabi=ilp32 -fno-stack-protector -w -Wl,--no-relax  -c errno.c
/media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-as -march=rv32i -mabi=ilp32   perf.S -o perf.o 
/media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-ld -T spiflash0.ld -m elf32lriscv -nostdlib -norelax hello.o putchar.o wait.o print.o memcpy.o errno.o perf.o /media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/lib/gcc/riscv64-unknown-elf/8.3.0/rv32i/ilp32/libgcc.a -o hello_flash.elf
objcopy -O verilog hello_flash.elf my_verilog_flash.hex
/media/Projeto/ASIC/base_femtorv32/learn-fpga/FemtoRV/FIRMWARE//TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14/bin/riscv64-unknown-elf-objcopy hello_flash.elf hello.spiflash0.bin -O binary
sudo icesprog -w -o 0x00020000 hello.spiflash0.bin
#rm hello_flash.elf hello.o wait.o print.o start.o memcpy.o perf.o putchar.o errno.o

