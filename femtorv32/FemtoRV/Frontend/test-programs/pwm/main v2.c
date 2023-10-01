int main() {
	
	unsigned int cnt = 0;
	while (1) {

		for (unsigned i = 0; i < 4096; i++) {
			*(volatile unsigned int*)(0x404000) = i;
			
			asm volatile (R"(
				la   a0, string
				call putstring
			)");

			asm volatile (R"(
				la   a0, string
				call putstring
			)");

				asm volatile (R"(
				la   a0, string
				call putstring
			)");

			
		}      	     
	}	

	return 0;
}

asm(R"(
	.section .text
	.globl putstring

	putstring:
		addi sp,zero,4 # save ra on the stack
		sw ra,0(sp)   # (need to do that for functions that call functions)
		mv t2,a0	
	.Loop1:    lbu a0,0(t2)
		beqz a0,.Loop2
		call putchar
		addi t2,t2,1	
		j .Loop1
	.Loop2:    lw ra,0(sp)  # restore ra
		addi sp,sp,4 # restore sp
		ret

	.section .data
	string:
		.asciz "[ITA-RVITA]\r\n"
)");
