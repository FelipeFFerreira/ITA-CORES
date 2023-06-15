# all: clean make-all run-hex run-test run-dump run-script run-vvp run
CFLAGS =

ifdef ENV_FRONTEND_SIGNOFF
    CFLAGS += -D ENV_FRONTEND_SIGNOFF=$(ENV_FRONTEND_SIGNOFF)
endif

BIN_DIR := $(CURDIR)/bin

all: clean clean_bin mkdir_bin run-script run

mkdir_bin:
	mkdir -p $(BIN_DIR)

run: 
	cd bin/ && ./run-script

run-vvp: run-vvp.o
	gcc -o bin/run-vvp run-vvp.o

run-vvp.o: src/run-vvp.c
	gcc -c src/run-vvp.c $(CFLAGS)

run-tools-elf: tool-elf.o
	gcc -o bin/tool-elf tool-elf.o

run-tools-elf-flash: tool-elf-flash.o
	gcc -o bin/tool-elf-flash tool-elf-flash.o

tool-elf.o: ../../TOOLS/elf-verilog/tool-elf.c
	gcc -c ../../TOOLS/elf-verilog/tool-elf.c

tool-elf-flash.o: ../../TOOLS/elf-verilog/tool-elf-flash.c
	gcc -c ../../TOOLS/elf-verilog/tool-elf-flash.c

run-script: script.o src/script.h
	gcc -o bin/run-script script.o

script.o: src/script.c src/script.h
	gcc -c src/script.c	$(CFLAGS)

clean_bin:
	-rm -rf $(BIN_DIR)

clean:
	rm -f *.s *.o *~ bin/make-all bin/run-hex bin/run-test bin/run-dump bin/run-script