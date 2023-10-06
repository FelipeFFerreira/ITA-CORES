.section .text
.globl main

main:
.L0:
    # teste 'vs4'
    la a0, test_name
    jal putstring

    # Conjunto de testes 'vs4'
    #-------------------------------------------------------------
    # Teste 1
    li a0, 0xCCCCCCCC
    li a1, 0x33333333
    and a2, a0, a1
    li a3, 0x00000000  # Valor esperado
    beq a2, a3, .vs4_1
    la a0, fail_msg
    jal putstring
    j .Lend

.vs4_1:
    # Teste 2
    addi a0, zero, 40
    addi a1, zero, 8
    div a2, a0, a1
    li a3, 0x00000005  # Valor esperado (40 dividido por 8 é 5)
    beq a2, a3, .vs4_2
    la a0, fail_msg
    jal putstring
    j .Lend

.vs4_2:
    # Teste 3
    addi a0, zero, -5
    addi a1, zero, -10
    slt a2, a0, a1
    li a3, 0x00000000  # Valor esperado (-5 não é menor que -10)
    beq a2, a3, .vs4_3
    la a0, fail_msg
    jal putstring
    j .Lend

.vs4_3:
    # Teste 4
    addi a0, zero, -15
    addi a1, zero, 5
    add a2, a0, a1
    li a3, 0xFFFFFFF0  # Valor esperado (-15 + 5 = -10)
    beq a2, a3, .vs4_4
    la a0, fail_msg
    jal putstring
    j .Lend

.vs4_4:
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
    .asciz "Testes 'vs4':\n"

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

