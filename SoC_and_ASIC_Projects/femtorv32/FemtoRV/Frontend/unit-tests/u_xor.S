.section .text
.globl main

main:
.L0:
    # teste 'xor'
    la a0, test_name
    jal putstring

    # Conjunto de testes 'xor'
    #-------------------------------------------------------------
    # Teste 1
    li a0, 0x0F0F0F0F
    li a1, 0xF0F0F0F0
    xor a2, a0, a1
    li a3, 0xFFFFFFFF  # Valor esperado
    beq a2, a3, .Lxor1
    la a0, fail_msg
    jal putstring
    j .Lend

.Lxor1:
    # Teste 2
    li a0, 0xAAAAAAAA
    li a1, 0x55555555
    xor a2, a0, a1
    li a3, 0xFFFFFFFF  # Valor esperado
    beq a2, a3, .Lxor2
    la a0, fail_msg
    jal putstring
    j .Lend

.Lxor2:
    # Teste 3
    li a0, 0x12345678
    li a1, 0x12345678
    xor a2, a0, a1
    li a3, 0x00000000  # Valor esperado (xor de dois números iguais resulta em 0)
    beq a2, a3, .Lxor3
    la a0, fail_msg
    jal putstring
    j .Lend

.Lxor3:
    # Teste 4
    li a0, 0x87654321
    li a1, 0x12345678
    xor a2, a0, a1
    li a3, 0x95511559  # Valor esperado
    beq a2, a3, .Lxor4
    la a0, fail_msg
    jal putstring
    j .Lend

.Lxor4:

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
    .asciz "Testes 'u_xor':\n"

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
