.text
.globl main
main:

    li t0, 1229
    lui t1, %hi(0x404000)
    addi t1, t1, %lo(0x404000)
loop:
    sw t0, 0(t1)
    li t2, 1000
delay_loop:
    addi t2, t2, -1
    bnez t2, delay_loop
    j loop


