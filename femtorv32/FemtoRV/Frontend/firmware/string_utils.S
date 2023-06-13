.include "firmware/putchar.S"
.section .text
.globl putstring

putstring:
	addi sp,zero,4 # save ra on the stack
	sw ra,0(sp)   # (need to do that for functions that call functions)
	mv t2,a0	
.L1:    lbu a0,0(t2)
	beqz a0,.L2
	call putchar
	addi t2,t2,1	
	j .L1
.L2:    lw ra,0(sp)  # restore ra
	addi sp,sp,4 # restore sp
	ret

.section .data
PASSOU:
    .asciz "OK\n"
FALHA:
    .asciz "OII\n"