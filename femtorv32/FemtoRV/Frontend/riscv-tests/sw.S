# See LICENSE for license details.

#*****************************************************************************
# sw.S
#-----------------------------------------------------------------------------
#
# Test sw instruction.
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

  TEST_ST_OP( 2, lw, sw, 0x00aa00aa, 0,  tdat );
  TEST_ST_OP( 3, lw, sw, 0xaa00aa00, 4,  tdat );
  TEST_ST_OP( 4, lw, sw, 0x0aa00aa0, 8,  tdat );
  TEST_ST_OP( 5, lw, sw, 0xa00aa00a, 12, tdat );

  # Test with negative offset

  TEST_ST_OP( 6, lw, sw, 0x00aa00aa, -12, tdat );
  TEST_ST_OP( 7, lw, sw, 0xaa00aa00, -8,  tdat );
  TEST_ST_OP( 8, lw, sw, 0x0aa00aa0, -4,  tdat );
  TEST_ST_OP( 9, lw, sw, 0xa00aa00a, 0,   tdat );

  # # Test with a negative base

  TEST_CASE( 10, x3, 0x12345678, \
    la  x1, tdat; \
    li  x2, 0x12345678; \
    addi x4, x1, -32; \
    sw x2, 32(x4); \
    lw x3, 0(x1); \
  )

  # # # Test with unaligned base

  TEST_CASE( 11, x3, 0x58213098, \
    la  x1, 0; \
    li  x2, 0x58213098; \
    addi x1, x1, -3; \
    sw x2, 7(x1); \
    la  x4, 5; \
    lw x3, 0(x4); \
  )

  # #-------------------------------------------------------------
  # # Bypassing tests
  # #-------------------------------------------------------------

  TEST_ST_SRC12_BYPASS( 12, 0, 0, lw, sw, 0xaabbccdd, 0,  tdat );
  TEST_ST_SRC12_BYPASS( 13, 0, 1, lw, sw, 0xdaabbccd, 4,  tdat );
  TEST_ST_SRC12_BYPASS( 14, 0, 2, lw, sw, 0xddaabbcc, 8,  tdat );
  TEST_ST_SRC12_BYPASS( 15, 1, 0, lw, sw, 0xcddaabbc, 12, tdat );
  TEST_ST_SRC12_BYPASS( 16, 1, 1, lw, sw, 0xccddaabb, 16, tdat );
  TEST_ST_SRC12_BYPASS( 17, 2, 0, lw, sw, 0xbccddaab, 20, tdat );

  TEST_ST_SRC21_BYPASS( 18, 0, 0, lw, sw, 0x00112233, 0,  tdat );
  TEST_ST_SRC21_BYPASS( 19, 0, 1, lw, sw, 0x30011223, 4,  tdat );
  TEST_ST_SRC21_BYPASS( 20, 0, 2, lw, sw, 0x33001122, 8,  tdat );
  TEST_ST_SRC21_BYPASS( 21, 1, 0, lw, sw, 0x23300112, 12, tdat );
  TEST_ST_SRC21_BYPASS( 22, 1, 1, lw, sw, 0x22330011, 16, tdat );
  TEST_ST_SRC21_BYPASS( 23, 2, 0, lw, sw, 0x12233001, 20, tdat );

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

# original form of address
# tdat:
# tdat1:  .word 0xdeadbeef
# tdat2:  .word 0xdeadbeef
# tdat3:  .word 0xdeadbeef
# tdat4:  .word 0xdeadbeef
# tdat5:  .word 0xdeadbeef
# tdat6:  .word 0xdeadbeef
# tdat7:  .word 0xdeadbeef
# tdat8:  .word 0xdeadbeef
# tdat9:  .word 0xdeadbeef
# tdat10: .word 0xdeadbeef

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
