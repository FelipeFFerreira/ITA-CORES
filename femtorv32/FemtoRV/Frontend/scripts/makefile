# all: clean make-all run-hex run-test run-dump run-script run-vvp run
all: run-script run

run: 
	cd bin/ && ./run-script

# make-all: aux-make-all.o
# 	gcc -o bin/make-all aux-make-all.o

# aux-make-all.o: src/aux-make-all.c
# 	gcc -c src/aux-make-all.c

# run-test: run-test.o
# 	gcc -o bin/run-test run-test.o

# run-test.o: src/run-test.c
# 	gcc -c src/run-test.c


run-vvp: run-vvp.o
	gcc -o bin/run-vvp run-vvp.o

run-vvp.o: src/run-vvp.c
	gcc -c src/run-vvp.c

run-tools-elf: tool-elf.o
	gcc -o bin/tool-elf tool-elf.o

tool-elf.o: ../../TOOLS/elf-verilog/tool-elf.c
	gcc -c ../../TOOLS/elf-verilog/tool-elf.c

run-script: script.o
	gcc -o bin/run-script script.o

script.o: src/script.c
	gcc -c src/script.c	

clean:
	rm -f *.s *.o *~ bin/make-all bin/run-hex bin/run-test bin/run-dump bin/run-script