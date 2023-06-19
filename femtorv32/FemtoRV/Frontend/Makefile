RISCV_GNU_TOOLCHAIN_GIT_REVISION = 411d134
RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX = /opt/riscv32

SHELL = bash
PYTHON = python3
VERILATOR = verilator
ICARUS_SUFFIX =
IVERILOG = iverilog$(ICARUS_SUFFIX)
VVP = vvp$(ICARUS_SUFFIX)

CURRENT_DIR = $(shell pwd)
FIRMWARE_SRC = $(wildcard firmware/*.S)
FIRMWARE_OBJS = $(FIRMWARE_SRC:.S=.o)

GCC_WARNS  = -Werror -Wall -Wextra -Wshadow -Wundef -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings
GCC_WARNS += -Wredundant-decls -Wstrict-prototypes -Wmissing-prototypes -pedantic # -Wconversion
TOOLCHAIN_PREFIX = $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)i/bin/riscv32-unknown-elf-
COMPRESSED_ISA = C

#RISCV-TESTS
ifdef RISCV-TESTS
TEST_OBJS_RISCV_TESTS = $(addsuffix .o,$(basename $(wildcard riscv-tests/*.S)))
OBJECTS_RISCV_TESTS := $(wildcard riscv-tests/*.o)
ELFS_RISCV_TESTS := $(patsubst riscv-tests/%.o,build/%.elf,$(TEST_OBJS_RISCV_TESTS))
endif

#RISCV-TESTS-SUITE
ifdef RISCV-TESTS-SUITE
TEST_OBJS_RISCV_TEST_SUITE = $(addsuffix .o,$(basename $(wildcard riscv-test-suite/*.S)))
OBJECTS_RISCV_TEST_SUITE := $(wildcard riscv-test-suite/*.o)
ELFS_RISCV_TEST_SUITE := $(patsubst riscv-test-suite/%.o,build/%.elf,$(TEST_OBJS_RISCV_TEST_SUITE))
endif

TEST_DIRS := $(wildcard build/*/)
ELFS_BUILD := $(foreach dir,$(TEST_DIRS),$(wildcard $(dir)*.elf))
BIN_DIR := $(CURDIR)/bin_tests
BINARIES := $(patsubst build/%.elf,build/%.bin,$(ELFS_BUILD))
BINARIES_COPY := $(patsubst build/%.elf,$(BIN_DIR)/%.bin,$(ELFS_BUILD))

CFLAGS =

ifdef ENV_FRONTEND_SIGNOFF
    CFLAGS += -DENV_FRONTEND_SIGNOFF=$(ENV_FRONTEND_SIGNOFF)
endif

.PHONY: all riscv-formal bin

toolchain:
	if [ ! -d "$(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)" ]; then \
		$(MAKE) download-tools build-rv32im-tools; \
	else \
		echo "Toolchain already installed. Skipping installation."; \
	fi

.PHONY: toolchain

GIT_ENV = true

all: hex

hex: $(patsubst build/%.elf,build/%.hex,$(ELFS_BUILD))

firmware/start.o: firmware/start.S
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32im$(subst C,c,$(COMPRESSED_ISA)) -o $@ $<


#RISCV-TESTS
ifdef RISCV-TESTS
riscv-tests/%.o: riscv-tests/%.S riscv-tests/riscv_test.h riscv-tests/test_macros.h riscv-tests/definitions.h 
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' $(CFLAGS) -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

riscv-tests: $(FIRMWARE_OBJS) $(TEST_OBJS_RISCV_TESTS) $(ELFS_RISCV_TESTS)

build/%.elf: firmware/start.o riscv-tests/%.o
	mkdir -p $(basename $@)
	@echo "[RISCV-TESTS] Using object files: firmware/start.o riscv-tests/$*.o"
	$(TOOLCHAIN_PREFIX)ld -T firmware/spiflash0.ld -m elf32lriscv -nostdlib -norelax firmware/start.o riscv-tests/$*.o -o $@
	mv $@ $(basename $@)/$(notdir $@)
endif
###

#RISCV-TESTS-SUITE
ifdef RISCV-TESTS-SUITE
riscv-test-suite/%.o: riscv-test-suite/%.S riscv-test-suite/riscv_test_macros.h riscv-test-suite/compliance_test.h riscv-test-suite/compliance_io.h
	$(TOOLCHAIN_PREFIX)gcc -c -mabi=ilp32 -march=rv32im -o $@ -DTEST_FUNC_NAME=$(notdir $(basename $<)) \
		-DTEST_FUNC_TXT='"$(notdir $(basename $<))"' $(CFLAGS) -DTEST_FUNC_RET=$(notdir $(basename $<))_ret $<

riscv-test-suite: $(FIRMWARE_OBJS) $(TEST_OBJS_RISCV_TEST_SUITE) $(ELFS_RISCV_TEST_SUITE)

build/%.elf: firmware/start.o riscv-test-suite/%.o
	mkdir -p $(basename $@)
	@echo "[RISCV-TESTS-SUITE] Using object files: $(CURRENT_DIR)/riscv-test-suite/$*.o"
	$(TOOLCHAIN_PREFIX)ld -T firmware/spiflash0.ld -m elf32lriscv -nostdlib -norelax firmware/start.o riscv-test-suite/$*.o -o $@
	mv $@ $(basename $@)/$(notdir $@)
endif
###

build/%.hex: build/%.elf
	objcopy -O verilog $< $@

bin: $(BINARIES) $(BINARIES_COPY)

build/%.bin: build/%.elf
	$(TOOLCHAIN_PREFIX)objcopy $< $@ -O binary

$(BIN_DIR)/%.bin: build/%.bin
	@mkdir -p $(BIN_DIR)
	cp $< $(BIN_DIR)

download-tools:
	sudo bash -c 'set -ex; mkdir -p /var/cache/distfiles; $(GIT_ENV); \
	$(foreach REPO,riscv-gnu-toolchain riscv-binutils-gdb riscv-gcc riscv-glibc riscv-newlib, \
		if ! test -d /var/cache/distfiles/$(REPO).git; then rm -rf /var/cache/distfiles/$(REPO).git.part; \
			git clone --bare https://github.com/riscv/$(REPO) /var/cache/distfiles/$(REPO).git.part; \
			mv /var/cache/distfiles/$(REPO).git.part /var/cache/distfiles/$(REPO).git; else \
			(cd /var/cache/distfiles/$(REPO).git; git fetch https://github.com/riscv/$(REPO)); fi;)'

define build_tools_template
build-$(1)-tools:
	@read -p "This will remove all existing data from $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)$(subst riscv32,,$(1)). Type YES to continue: " reply && [[ "$$$$reply" == [Yy][Ee][Ss] || "$$$$reply" == [Yy] ]]
	sudo bash -c "set -ex; rm -rf $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)$(subst riscv32,,$(1)); mkdir -p $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)$(subst riscv32,,$(1)); chown $$$${USER}: $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)$(subst riscv32,,$(1))"
	+$(MAKE) build-$(1)-tools-bh

build-$(1)-tools-bh:
	+set -ex; $(GIT_ENV); \
	if [ -d /var/cache/distfiles/riscv-gnu-toolchain.git ]; then reference_riscv_gnu_toolchain="--reference /var/cache/distfiles/riscv-gnu-toolchain.git"; else reference_riscv_gnu_toolchain=""; fi; \
	if [ -d /var/cache/distfiles/riscv-binutils-gdb.git ]; then reference_riscv_binutils_gdb="--reference /var/cache/distfiles/riscv-binutils-gdb.git"; else reference_riscv_binutils_gdb=""; fi; \
	if [ -d /var/cache/distfiles/riscv-gcc.git ]; then reference_riscv_gcc="--reference /var/cache/distfiles/riscv-gcc.git"; else reference_riscv_gcc=""; fi; \
	if [ -d /var/cache/distfiles/riscv-glibc.git ]; then reference_riscv_glibc="--reference /var/cache/distfiles/riscv-glibc.git"; else reference_riscv_glibc=""; fi; \
	if [ -d /var/cache/distfiles/riscv-newlib.git ]; then reference_riscv_newlib="--reference /var/cache/distfiles/riscv-newlib.git"; else reference_riscv_newlib=""; fi; \
	rm -rf riscv-gnu-toolchain-$(1); git clone $$$$reference_riscv_gnu_toolchain https://github.com/riscv/riscv-gnu-toolchain riscv-gnu-toolchain-$(1); \
	cd riscv-gnu-toolchain-$(1); git checkout $(RISCV_GNU_TOOLCHAIN_GIT_REVISION); \
	git submodule update --init $$$$reference_riscv_binutils_gdb riscv-binutils; \
	git submodule update --init $$$$reference_riscv_binutils_gdb riscv-gdb; \
	git submodule update --init $$$$reference_riscv_gcc riscv-gcc; \
	git submodule update --init $$$$reference_riscv_glibc riscv-glibc; \
	git submodule update --init $$$$reference_riscv_newlib riscv-newlib; \
	mkdir build; cd build; ../configure --with-arch=$(2) --prefix=$(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)$(subst riscv32,,$(1)); make

.PHONY: build-$(1)-tools
endef

$(eval $(call build_tools_template,riscv32i,rv32i))
$(eval $(call build_tools_template,riscv32ic,rv32ic))
$(eval $(call build_tools_template,riscv32im,rv32im))
$(eval $(call build_tools_template,riscv32imc,rv32imc))

build-tools:
	@echo "This will remove all existing data from $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)i, $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)ic, $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)im, and $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX)imc."
	@read -p "Type YES to continue: " reply && [[ "$$reply" == [Yy][Ee][Ss] || "$$reply" == [Yy] ]]
	sudo bash -c "set -ex; rm -rf $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX){i,ic,im,imc}; mkdir -p $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX){i,ic,im,imc}; chown $${USER}: $(RISCV_GNU_TOOLCHAIN_INSTALL_PREFIX){i,ic,im,imc}"
	+$(MAKE) build-riscv32i-tools-bh
	+$(MAKE) build-riscv32ic-tools-bh
	+$(MAKE) build-riscv32im-tools-bh
	+$(MAKE) build-riscv32imc-tools-bh

clean:
	rm -rf riscv-gnu-toolchain-riscv32i riscv-gnu-toolchain-riscv32ic \
		riscv-gnu-toolchain-riscv32im riscv-gnu-toolchain-riscv32imc
	rm -vrf $(FIRMWARE_OBJS) $(TEST_OBJS_RISCV_TESTS) \
		firmware/firmware.elf firmware/firmware.bin firmware/firmware.hex \
	rm -rf build
	rm -rf $(BIN_DIR)

.PHONY: clean