.section .text
.globl main

main:
.L0:
    # Escrever nome do teste 'add'
    la a0, test_name
    jal putstring

    # Conjunto de testes 'add'
    #-------------------------------------------------------------
    # Teste 1
    addi a0, zero, 0
    addi a1, zero, 0
    add a2, a0, a1
    li a3, 0x00000000  # Valor esperado
    beq a2, a3, .Lok1
    la a0, fail_msg
    jal putstring
    j .Lend

.Lok1:
    # Teste 2
    addi a0, zero, 2
    addi a1, zero, 1
    add a2, a0, a1
    li a3, 0x00000003  # Valor esperado
    beq a2, a3, .Lok2
    la a0, fail_msg
    jal putstring
    j .Lend

.Lok2:
    # Teste 3
    addi a0, zero, 10
    addi a1, zero, 4
    add a2, a0, a1
    li a3, 0x0000000d  # Valor esperado
    beq a2, a3, .Lok3
    la a0, fail_msg
    jal putstring
    j .Lend

.Lok3:
    # Teste 4 (Teste com um valor negativo e um positivo)
    addi a0, zero, -7
    addi a1, zero, 3
    add a2, a0, a1
    li a3, 0x00000004  # Valor esperado: -4
    beq a2, a3, .Lok4
    la a0, fail_msg
    jal putstring
    j .Lend

.Lok4:
    # Teste 5 (Teste com ambos os valores negativos)
    addi a0, zero, -3
    addi a1, zero, -8
    add a2, a0, a1
    li a3, 0x0000000B  # Valor esperado: -11
    beq a2, a3, .Lok5
    la a0, fail_msg
    jal putstring
    j .Lend

.Lok5:
    # Teste 6 (Teste com um valor zero e outro negativo)
    addi a0, zero, 0
    addi a1, zero, -5
    add a2, a0, a1
    li a3, 0xFFFFFFFB  # Valor esperado: -5
    beq a2, a3, .Lok6
    la a0, fail_msg
    jal putstring
    j .Lend

.Lok6:
    # Teste 7 (Teste com grandes valores positivos)
    li a0, 0x7FFFFFF0
    addi a1, zero, 10
    add a2, a0, a1
    li a3, 0x80000000  # Valor esperado devido ao overflow
    beq a2, a3, .Lok7
    la a0, fail_msg
    jal putstring
    j .Lend

.Lok7:

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
    .asciz "Testes 'add':\n"

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
