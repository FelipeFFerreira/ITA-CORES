.section .text
.globl main

main:
.L0:
    # teste 'vs3'
    la a0, test_name
    jal putstring

    # Conjunto de testes 'vs3'
    #-------------------------------------------------------------
    # Teste 1
    li a0, 0xA5A5A5A5
    li a1, 0x5A5A5A5A
    xor a2, a0, a1
    li a3, 0xFFFFFFFF  # Valor esperado
    beq a2, a3, .vs3_1
    la a0, fail_msg
    jal putstring
    j .Lend

.vs3_1:
    # Teste 2
    addi a0, zero, 25
    addi a1, zero, 7
    rem a2, a0, a1
    li a3, 0x00000004  # Valor esperado (resto de 25 dividido por 7 é 4)
    beq a2, a3, .vs3_2
    la a0, fail_msg
    jal putstring
    j .Lend

.vs3_2:
    # Teste 3
    addi a0, zero, 7
    addi a1, zero, 25
    slt a2, a0, a1
    li a3, 0x00000001  # Valor esperado (7 < 25)
    beq a2, a3, .vs3_3
    la a0, fail_msg
    jal putstring
    j .Lend

.vs3_3:
    # Teste 4
    addi a0, zero, 50
    addi a1, zero, 20
    sub a2, a0, a1
    li a3, 0x0000001E  # Valor esperado (50 - 20 = 30)
    beq a2, a3, .vs3_4
    la a0, fail_msg
    jal putstring
    j .Lend

.vs3_4:
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
    .asciz "Testes 'vs3':\n"

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
