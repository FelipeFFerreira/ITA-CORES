# RISCV_GNU_TOOLCHAIN_GIT_REVISION = 411d134
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = ../FIRMWARE/TOOLCHAIN/riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14

# Give the user some easy overrides for local configuration quirks.
# If you change one of these and it breaks, then you get to keep both pieces.
SHELL = bash
PYTHON = python3
VERILATOR = verilator
ICARUS_SUFFIX =
IVERILOG = iverilog$(ICARUS_SUFFIX)
VVP = vvp$(ICARUS_SUFFIX)

FIRMWARE_OBJS = firmware/start.o 
GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)/bin/riscv64-unknown-elf-
COMPRESSED_ISA = C

TEST_OBJS = $(addsuffix .o,$(basename $(wildcard tests/*.S)))
OBJECTS := $(wildcard tests/*.o)
ELFS := $(patsubst tests/%.o,build/%.elf,$(TEST_OBJS))
# Obter a lista de diretórios de teste dentro de build
TEST_DIRS := $(wildcard build/*/)
# Obter a lista de arquivos .elf em cada diretório de teste
ELFS_BUILD := $(foreach dir,$(TEST_DIRS),$(wildcard $(dir)*.elf))
# Obter a lista de arquivos .elf em cada diretório de teste
# BIN_DIR := $(CURDIR)/bin_tests
# BINARIES := $(patsubst build/%.elf,build/%.bin,$(ELFS_BUILD))
# BINARIES_COPY := $(patsubst build/%.elf,$(BIN_DIR)/%.bin,$(ELFS_BUILD))
BIN_DIR := $(CURDIR)/bin_tests
BINARIES := $(patsubst build/%.elf,build/%.bin,$(ELFS_BUILD))
BINARIES_COPY := $(patsubst build/%.elf,$(BIN_DIR)/%.bin,$(ELFS_BUILD))

.PHONY: all riscv-formal bin

all: hex

riscv-formal: tests hex

hex: $(patsubst build/%.elf,build/%.hex,$(ELFS_BUILD))

firmware/start.o: firmware/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -o $@ $<

tests/%.o: tests/%.S tests/riscv_test.h tests/test_macros.h
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

tests: $(FIRMWARE_OBJS) $(TEST_OBJS) $(ELFS)

build/%.elf: tests/%.o
	mkdir -p $(basename $@)  # Cria uma pasta com o mesmo nome do arquivo .elf
	$(TOOLCHAIN_PREFIX)ld -T spiflash0.ld -m elf32lriscv -nostdlib -norelax $< -o $@
	mv $@ $(basename $@)/$(notdir $@)  # Move o arquivo .elf para a pasta correspondente

build/%.hex: build/%.elf
	objcopy -O verilog $< $@

# bin: $(BINARIES) $(BINARIES_COPY)

# build/%.bin: build/%.elf
# 	$(TOOLCHAIN_PREFIX)objcopy $< $@ -O binary

# $(BIN_DIR)/%.bin: build/%.bin
# 	@mkdir -p $(dir $@)
# 	cp $< $@

bin: $(BINARIES) $(BINARIES_COPY)

build/%.bin: build/%.elf
	$(TOOLCHAIN_PREFIX)objcopy $< $@ -O binary

$(BIN_DIR)/%.bin: build/%.bin
	@mkdir -p $(BIN_DIR)
	cp $< $(BIN_DIR)


clean:
	rm -rf riscv-gnu-toolchain-riscv32i riscv-gnu-toolchain-riscv32ic \
		riscv-gnu-toolchain-riscv32im riscv-gnu-toolchain-riscv32imc
	rm -vrf $(FIRMWARE_OBJS) $(TEST_OBJS) \
		firmware/firmware.elf firmware/firmware.bin firmware/firmware.hex \
	rm -rf build
	rm -rf $(BIN_DIR)

.PHONY: clean