.section .text
.globl main

main:
.L0:
    # teste 'sll'
    la a0, test_name
    jal putstring

    # Conjunto de testes 'sll'
    #-------------------------------------------------------------
    # Teste 1
    li a0, 0x00000001
    li a1, 4
    sll a2, a0, a1
    li a3, 0x00000010  # Valor esperado (1 << 4 = 16)
    beq a2, a3, .Lsll1
    la a0, fail_msg
    jal putstring
    j .Lend

.Lsll1:
    # Teste 2
    li a0, 0x0000000F
    li a1, 3
    sll a2, a0, a1
    li a3, 0x00000078  # Valor esperado (15 << 3 = 120)
    beq a2, a3, .Lsll2
    la a0, fail_msg
    jal putstring
    j .Lend

.Lsll2:
    # Teste 3
    li a0, 0x12345678
    li a1, 4
    sll a2, a0, a1
    li a3, 0x23456780  # Valor esperado após shift left de 4 posições
    beq a2, a3, .Lsll3
    la a0, fail_msg
    jal putstring
    j .Lend

.Lsll3:
    # Teste 4
    li a0, 0xFFFFFFFF
    li a1, 0
    sll a2, a0, a1
    li a3, 0xFFFFFFFF  # Valor esperado (deslocamento de 0 posições não muda o valor)
    beq a2, a3, .Lsll4
    la a0, fail_msg
    jal putstring
    j .Lend

.Lsll4:

    # Teste de todos os testes passarem
    la a0, ok_msg
    jal putstring
    j .Lend

.Lend:
    j .L0

.section .data
hello:
    .asciz "mensagem text!\n"
ok_msg:
    .asciz "Ok\n"
fail_msg:
    .asciz "falha\n"
test_name:
    .asciz "Testes 'u_sll':\n"

.section .text
.globl putstring

putstring:
    addi sp, zero, 4  # salvar ra na pilha
    sw ra, 0(sp)
    mv t2, a0
.L1:
    lbu a0, 0(t2)
    beqz a0, .L2
    jal putchar
    addi t2, t2, 1
    j .L1
.L2:
    lw ra, 0(sp)  # restaurar ra
    addi sp, sp, 4  # restaurar sp
    ret
