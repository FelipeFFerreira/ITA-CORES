# See LICENSE for license details.

#*****************************************************************************
# sh.S
#-----------------------------------------------------------------------------
#
# Test sh instruction.
#

#include "riscv_test.h"
#include "test_macros.h"

.globl main
.globl fail_check
.section .text

RVTEST_FAIL_CHECK

main:
RVTEST_RV32U
RVTEST_CODE_BEGIN
  #-------------------------------------------------------------
  # Basic tests
  #-------------------------------------------------------------

  TEST_ST_OP( 2, lh, sh, 0x000000aa, 0, tdat );
  TEST_ST_OP( 3, lh, sh, 0xffffaa00, 2, tdat );
  TEST_ST_OP( 4, lw, sw, 0xbeef0aa0, 4, tdat ); 
  TEST_ST_OP( 5, lh, sh, 0xffffa00a, 6, tdat );

  # Test with negative offset

  TEST_ST_OP( 6, lh, sh, 0x000000aa, -6, tdat1 );
  TEST_ST_OP( 7, lh, sh, 0xffffaa00, -4, tdat1 );
  TEST_ST_OP( 8, lh, sh, 0x00000aa0, -2, tdat1 );
  TEST_ST_OP( 9, lh, sh, 0xffffa00a, 0,  tdat1 );

  # Test with a negative base

  TEST_CASE( 10, x3, 0x5678, \
    la  x1, tdat; \
    li  x2, 0x12345678; \
    addi x4, x1, -32; \
    sh x2, 32(x4); \
    lh x3, 0(x1); \
  )

  # Test with unaligned base

  TEST_CASE( 11, x3, 0x3098, \
    la  x1, 58; \
    li  x2, 0x00003098; \
    addi x1, x1, -5; \
    sh x2, 7(x1); \
    la  x4, 60; \
    lh x3, 0(x4); \
  )

  #-------------------------------------------------------------
  # Bypassing tests
  #-------------------------------------------------------------

  TEST_ST_SRC12_BYPASS( 12, 0, 0, lh, sh, 0xffffccdd, 0,  tdat );
  TEST_ST_SRC12_BYPASS( 13, 0, 1, lh, sh, 0xffffbccd, 2,  tdat );
  TEST_ST_SRC12_BYPASS( 14, 0, 2, lh, sh, 0xffffbbcc, 4,  tdat );
  TEST_ST_SRC12_BYPASS( 15, 1, 0, lh, sh, 0xffffabbc, 6, tdat );
  TEST_ST_SRC12_BYPASS( 16, 1, 1, lh, sh, 0xffffaabb, 8, tdat );
  TEST_ST_SRC12_BYPASS( 17, 2, 0, lh, sh, 0xffffdaab, 10, tdat );

  TEST_ST_SRC21_BYPASS( 18, 0, 0, lh, sh, 0x2233, 0,  tdat );
  TEST_ST_SRC21_BYPASS( 19, 0, 1, lh, sh, 0x1223, 2,  tdat );
  TEST_ST_SRC21_BYPASS( 20, 0, 2, lh, sh, 0x1122, 4,  tdat );
  TEST_ST_SRC21_BYPASS( 21, 1, 0, lh, sh, 0x0112, 6, tdat );
  TEST_ST_SRC21_BYPASS( 22, 1, 1, lh, sh, 0x0011, 8, tdat );
  TEST_ST_SRC21_BYPASS( 23, 2, 0, lh, sh, 0x3001, 10, tdat );

  li a0, 0xbeef
  la a1, tdat
  sh a0, 6(a1)

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

# tdat:
# tdat1:  .half 0xbeef
# tdat2:  .half 0xbeef
# tdat3:  .half 0xbeef
# tdat4:  .half 0xbeef
# tdat5:  .half 0xbeef
# tdat6:  .half 0xbeef
# tdat7:  .half 0xbeef
# tdat8:  .half 0xbeef
# tdat9:  .half 0xbeef
# tdat10: .half 0xbeef

# In the presented program, global variables like tdat are stored in flash 
# memory. Thus, in the execution of the tests, when trying to write to 
# these addresses (for example, tdat), the writing operations fail.
# One solution found was to modify the base address to 0...x in the 
# test TEST_ST_OP( 2, lw, sw, 0x00aa00aa, 0, 0 ). 
# This action caused the instruction sw x2, 0(x1); 
# store the value at address 0 in RAM memory instead of in 
# flash memory. As RAM is read-write memory, the write operation was successful.
.equ tdat,  40
.equ tdat1, 80
.equ tdat2, 120
.equ tdat3, 160
.equ tdat4, 200
.equ tdat5, 240
.equ tdat6, 280
.equ tdat7, 320
.equ tdat8, 40
.equ tdat9, 80
.equ tdat10, 120


RVTEST_DATA_END
