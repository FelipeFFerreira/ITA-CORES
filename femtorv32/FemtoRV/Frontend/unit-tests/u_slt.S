.section .text
.globl main

main:
.L0:
    # teste 'slt'
    la a0, test_name
    jal putstring

    # Conjunto de testes 'slt'
    #-------------------------------------------------------------
    # Teste 1
    addi a0, zero, 5
    addi a1, zero, 10
    slt a2, a0, a1
    li a3, 0x00000001  # Valor esperado (5 < 10)
    beq a2, a3, .Lslt1
    la a0, fail_msg
    jal putstring
    j .Lend

.Lslt1:
    # Teste 2
    addi a0, zero, 10
    addi a1, zero, 5
    slt a2, a0, a1
    li a3, 0x00000000  # Valor esperado (10 não é < 5)
    beq a2, a3, .Lslt2
    la a0, fail_msg
    jal putstring
    j .Lend

.Lslt2:
    # Teste 3
    addi a0, zero, -5
    addi a1, zero, 5
    slt a2, a0, a1
    li a3, 0x00000001  # Valor esperado (-5 < 5)
    beq a2, a3, .Lslt3
    la a0, fail_msg
    jal putstring
    j .Lend

.Lslt3:
    # Teste 4 (Comparação de dois números negativos)
    addi a0, zero, -10
    addi a1, zero, -5
    slt a2, a0, a1
    li a3, 0x00000001  # Valor esperado (-10 < -5)
    beq a2, a3, .Lslt4
    la a0, fail_msg
    jal putstring
    j .Lend

.Lslt4:

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
    .asciz "Testes 'u_slt':\n"

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

