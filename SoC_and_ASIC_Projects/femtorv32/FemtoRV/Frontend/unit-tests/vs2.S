.section .text
.globl main

main:
.L0:
    # teste 'vs2'
    la a0, test_name
    jal putstring

    # Conjunto de testes 'vs2'
    #-------------------------------------------------------------
    # Teste 1
    li a0, 0x12345678
    li a1, 0x87654321
    and a2, a0, a1
    li a3, 0x02244220  # Valor esperado
    beq a2, a3, .vs2_1
    la a0, fail_msg
    jal putstring
    j .Lend

.vs2_1:
    # Teste 2
    addi a0, zero, 15
    addi a1, zero, -5
    sub a2, a0, a1
    li a3, 0x00000014  # Valor esperado (15 - (-5) = 20)
    beq a2, a3, .vs2_2
    la a0, fail_msg
    jal putstring
    j .Lend

.vs2_2:
    # Teste 3
    addi a0, zero, 10
    addi a1, zero, 10
    slt a2, a0, a1
    li a3, 0x00000000  # Valor esperado (10 < 10 é falso)
    beq a2, a3, .vs2_3
    la a0, fail_msg
    jal putstring
    j .Lend

.vs2_3:
    # Teste 4
    addi a0, zero, 5
    addi a1, zero, -5
    slt a2, a1, a0
    li a3, 0x00000001  # Valor esperado (-5 < 5)
    beq a2, a3, .vs2_4
    la a0, fail_msg
    jal putstring
    j .Lend

.vs2_4:
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
    .asciz "Testes 'vs2':\n"

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

