# Hello world !
	
.section .text
.globl main

main:
.L0:
	la   a0, hello
	call putstring
	j .L0

putstring:
  addi sp, zero, 4  # Salva ra na pilha
  sw ra, 0(sp)

  mv t2, a0  # Copia o argumento para t2

.L1:
  lbu a0, 0(t2)
  beqz a0, .L2  # Verifica se chegou ao final da string
  call putchar
  addi t2, t2, 1
  j .L1

.L2:
  lw ra, 0(sp)  # Restaura ra
  addi sp, sp, 4  # Restaura sp
  ret

.section .data
hello:
  .asciz "[ITA-CORES-FELIPE-FERREIRA]\n"
