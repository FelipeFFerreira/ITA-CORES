#ifndef _ENV_ITA_CORES_QUARK_TEST_H
#define _ENV_ITA_CORES_QUARK_TEST_H

// # define ENV_FRONTEND_SIGNOFF

#ifndef TEST_FUNC_NAME
#  define TEST_FUNC_NAME mytest
#  define TEST_FUNC_TXT "mytest"
#  define TEST_FUNC_RET mytest_ret
#endif

#define RVTEST_RV32U
#define TESTNUM x28

#ifdef ENV_FRONTEND_SIGNOFF
#define s_1 5
#define s_05 2
#else
#define s_1 44444
#define s_05 4938
#endif


// 
	// #define RVTEST_PASS                     \
//     li      gp, IO_BASE;                \
//     li      sp, 0x1800;                 \
//     la      a0, passou;                \
//     call    putstring;

//
#define RVTEST_CODE_BEGIN		\
	lui t0, %hi(0x404000); \
  	li t1, 0; \
  	sw t1, %lo(0x404000)(t0); 

#define RVTEST_PASS			\
	addi a0, zero, 100;   \
	addi a1, zero, 'O';   \
	addi a2, zero, 'K';   \
	addi a3, zero, '\n';  \
	sb a1, 0(a0);         \
	addi a0, a0, 1;       \
	sb a2, 0(a0);         \
	addi a0, a0, 1;       \
	sb a3, 0(a0);         \
  	lui t0, %hi(0x404000);       \
 	li t1, 0;                    \
  	sw t1, %lo(0x404000)(t0);     \
  loop_pass:                        \
    lui t0, %hi(0x404000);     \
    li t1, 4095;               \
    sw t1, %lo(0x404000)(t0);   \
    li t2, s_1;               \
    delay_pass:                     \
      addi t2, t2, -1;         \
      bnez t2, delay_pass;          \
    lui t0, %hi(0x404000);     \
    li t1, 0;                  \
    sw t1, %lo(0x404000)(t0);   \
    li t2, s_1;               \
    delay2_pass:                    \
      addi t2, t2, -1;         \
      bnez t2, delay2_pass;         \
	j loop_pass;

#define RVTEST_FAIL			\
	addi a0, zero, 100;   \
	addi a1, zero, 'E';   \
	addi a2, zero, 'R';   \
	addi a3, zero, '\n';  \
	sb a1, 0(a0);         \
	addi a0, a0, 1;       \
	sb a2, 0(a0);         \
	addi a0, a0, 1;       \
	sb a3, 0(a0);         \
  	lui t0, %hi(0x404000);       \
 	li t1, 0;                    \
  	sw t1, %lo(0x404000)(t0);     \
  loop_fail:                        \
    lui t0, %hi(0x404000);     \
    li t1, 4095;               \
    sw t1, %lo(0x404000)(t0);   \
    li t2, s_05;               \
    delay_fail:                     \
      addi t2, t2, -1;         \
      bnez t2, delay_fail;          \
    lui t0, %hi(0x404000);     \
    li t1, 0;                  \
    sw t1, %lo(0x404000)(t0);   \
    li t2, s_05;               \
    delay2_fail:                    \
      addi t2, t2, -1;         \
      bnez t2, delay2_fail;         \
  j loop_fail;

#define PUTCHAR \
	putchar: \
	sw a0, IO_UART_DAT(gp); \
	li t0, 1<<9; \
	.L0: \
	lw t1, IO_UART_CNTL(gp); \
	and t1, t1, t0; \
	bnez t1, .L0; \
	ret

#define PUTSTRING \
	putstring: \
	addi sp, zero, 4; \
	sw ra, 0(sp); \
	mv t2, a0; \
	.L1: \
	lbu a0, 0(t2); \
	beqz a0, .L2; \
	call putchar; \
	addi t2, t2, 1; \
	j .L1; \
	.L2: \
	lw ra, 0(sp); \
	addi sp, sp, 4; \
	ret

#define RVTEST_CODE_END
#define RVTEST_DATA_BEGIN .balign 4;
#define RVTEST_DATA_END

#endif
