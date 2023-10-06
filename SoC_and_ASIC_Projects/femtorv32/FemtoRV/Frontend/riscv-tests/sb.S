# See LICENSE for license details.

#*****************************************************************************
# sb.S
#-----------------------------------------------------------------------------
#
# Test sb instruction.
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

    li a1, 0xef
    li a2, 40     # start address for data storage
    li a3, 11     
init_loop:
    sb a1, 0(a2)  
    addi a2, a2, 1 
    addi a3, a3, -1 
    bnez a3, init_loop 

  #-------------------------------------------------------------
  # Basic tests
  #-------------------------------------------------------------

  TEST_ST_OP( 2, lb, sb, 0xffffffaa, 0, tdat );
  TEST_ST_OP( 3, lb, sb, 0x00000000, 1, tdat1 );
  TEST_ST_OP( 4, lh, sb, 0xffffefa0, 2, tdat2 );
  TEST_ST_OP( 5, lb, sb, 0x0000000a, 3, tdat3 );

  # # Test with negative offset

  TEST_ST_OP( 6, lb, sb, 0xffffffaa, -3, tdat4 );
  TEST_ST_OP( 7, lb, sb, 0x00000000, -2, tdat5 );
  TEST_ST_OP( 8, lb, sb, 0xffffffa0, -1, tdat6 );
  TEST_ST_OP( 9, lb, sb, 0x0000000a, 0,  tdat7 );

  # # Test with a negative base

  TEST_CASE( 10, x3, 0x78, \
    la  x1, tdat8; \
    li  x2, 0x12345678; \
    addi x4, x1, -32; \
    sb x2, 32(x4); \
    lb x3, 0(x1); \
  )

  # Test with unaligned base

  TEST_CASE( 11, x3, 0xffffff98, \
    la  x1, tdat9; \
    li  x2, 0x00003098; \
    addi x1, x1, -6; \
    sb x2, 7(x1); \
    la  x4, tdat10; \
    lb x3, 0(x4); \
  )

  # #-------------------------------------------------------------
  # # Bypassing tests
  # #-------------------------------------------------------------

  TEST_ST_SRC12_BYPASS( 12, 0, 0, lb, sb, 0xffffffdd, 0, tdat );
  TEST_ST_SRC12_BYPASS( 13, 0, 1, lb, sb, 0xffffffcd, 1, tdat );
  TEST_ST_SRC12_BYPASS( 14, 0, 2, lb, sb, 0xffffffcc, 2, tdat );
  TEST_ST_SRC12_BYPASS( 15, 1, 0, lb, sb, 0xffffffbc, 3, tdat );
  TEST_ST_SRC12_BYPASS( 16, 1, 1, lb, sb, 0xffffffbb, 4, tdat );
  TEST_ST_SRC12_BYPASS( 17, 2, 0, lb, sb, 0xffffffab, 5, tdat );

  TEST_ST_SRC21_BYPASS( 18, 0, 0, lb, sb, 0x33, 0, tdat );
  TEST_ST_SRC21_BYPASS( 19, 0, 1, lb, sb, 0x23, 1, tdat );
  TEST_ST_SRC21_BYPASS( 20, 0, 2, lb, sb, 0x22, 2, tdat );
  TEST_ST_SRC21_BYPASS( 21, 1, 0, lb, sb, 0x12, 3, tdat );
  TEST_ST_SRC21_BYPASS( 22, 1, 1, lb, sb, 0x11, 4, tdat );
  TEST_ST_SRC21_BYPASS( 23, 2, 0, lb, sb, 0x01, 5, tdat );

  li a0, 0xef
  la a1, tdat
  sb a0, 3(a1)

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN

  TEST_DATA

# tdat:
# tdat1:  .byte 0xef
# tdat2:  .byte 0xef
# tdat3:  .byte 0xef
# tdat4:  .byte 0xef
# tdat5:  .byte 0xef
# tdat6:  .byte 0xef
# tdat7:  .byte 0xef
# tdat8:  .byte 0xef
# tdat9:  .byte 0xef
# tdat10: .byte 0xef

# In the presented program, global variables like tdat are stored in flash 
# memory. Thus, in the execution of the tests, when trying to write to 
# these addresses (for example, tdat), the writing operations fail.
# One solution found was to modify the base address to 0...x in the 
# test TEST_ST_OP( 2, lw, sw, 0x00aa00aa, 0, 0 ). 
# This action caused the instruction sw x2, 0(x1); 
# store the value at address 0 in RAM memory instead of in 
# flash memory. As RAM is read-write memory, the write operation was successful.

.equ tdat,  40
.equ tdat1, 41
.equ tdat2, 42
.equ tdat3, 43
.equ tdat4, 44
.equ tdat5, 45
.equ tdat6, 46
.equ tdat7, 47
.equ tdat8, 48
.equ tdat9, 49
.equ tdat10, 50
.equ tdat10, 51

RVTEST_DATA_END
