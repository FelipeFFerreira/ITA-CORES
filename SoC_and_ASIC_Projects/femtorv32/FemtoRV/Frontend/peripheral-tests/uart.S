.section .text
.globl main

main:
  # Chama a função putstring para imprimir a string
  la a0, hello
  call putstring

  # Loop para o efeito de acender e apagar o LED
  loop:
    # Acende o LED
    lui t0, %hi(0x404000)
    li t1, 4095
    sw t1, %lo(0x404000)(t0)

    # Atraso de 1 segundo
    li t2, 4938
    delay:
      addi t2, t2, -1
      bnez t2, delay

    # Apaga o LED
    lui t0, %hi(0x404000)
    li t1, 0
    sw t1, %lo(0x404000)(t0)

    # Atraso de 1 segundo
    li t2, 4938
    delay2:
      addi t2, t2, -1
      bnez t2, delay2

  # Salta de volta para o início do loop
  j loop

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
  .asciz "Felipe Ferreira Nascimento\n"
