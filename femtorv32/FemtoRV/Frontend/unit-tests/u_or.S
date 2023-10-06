.section .text
.globl main

main:
.L0:
    # teste 'or'
    la a0, test_name
    jal putstring

    # Conjunto de testes 'or'
    #-------------------------------------------------------------
    # Teste 1
    li a0, 0x0F0F0F0F
    li a1, 0xF0F0F0F0
    or a2, a0, a1
    li a3, 0xFFFFFFFF  # Valor esperado
    beq a2, a3, .Lor1
    la a0, fail_msg
    jal putstring
    j .Lend

.Lor1:
    # Teste 2
    li a0, 0xAAAAAAAA
    li a1, 0x55555555
    or a2, a0, a1
    li a3, 0xFFFFFFFF  # Valor esperado
    beq a2, a3, .Lor2
    la a0, fail_msg
    jal putstring
    j .Lend

.Lor2:
    # Teste 3
    li a0, 0x0A0A0A0A
    li a1, 0x50505050
    or a2, a0, a1
    li a3, 0x5A5A5A5A  # Valor esperado
    beq a2, a3, .Lor3
    la a0, fail_msg
    jal putstring
    j .Lend

.Lor3:

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
    .asciz "Testes 'u_or':\n"

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
