# RISC-V Compliance Test LHU-01
#
# Copyright (c) 2019, Imperas Software Ltd.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#      * Redistributions of source code must retain the above copyright
#        notice, this list of conditions and the following disclaimer.
#      * Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
#      * Neither the name of the Imperas Software Ltd. nor the
#        names of its contributors may be used to endorse or promote products
#        derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL Imperas Software Ltd. BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# Specification: RV32I Base Integer Instruction Set, Version 2.1
# Description: Testing instruction 'LHU'.

#include "riscv_test_macros.h"
#include "compliance_test.h"
#include "compliance_io.h"

.globl main
.globl fail_check
.section .text

RVTEST_FAIL_CHECK

main:
RV_COMPLIANCE_RV32M

RV_COMPLIANCE_CODE_BEGIN


	RVTEST_IO_INIT
	RVTEST_IO_ASSERT_GPR_EQ(x31, x0, 0x00000000)
	RVTEST_IO_WRITE_STR(x31, "Test Begin\n")

	# ---------------------------------------------------------------------------------------------

	RVTEST_IO_WRITE_STR(x31, "# Test number 1\n")


    # Addresses for test data and results
	la	x5, test_1_res

	TEST_CASE(x7, x0, 0x0, x5, 0, \
    la  x31, test_data; \
    lhu x0, 0x0(x31); \
    )
	TEST_CASE(x7, x1, 0xbbb, x5, 4, \
    la  x30, test_data; \
    lhu x1, -0x2(x30); \
    )
	TEST_CASE(x7, x2, 0xdd0d, x5, 8, \
    la  x29, test_data; \
    lhu x2, 0x2(x29); \
    )
	TEST_CASE(x7, x3, 0xcc0c, x5, 12, \
    la  x28, test_data; \
    lhu x3, -0x4(x28); \
    )
	TEST_CASE(x7, x4, 0xdd0d, x5, 16, \
    la  x27, test_data; \
    lhu x4, 0x2(x27); \
    )


	# ---------------------------------------------------------------------------------------------
	RVTEST_IO_WRITE_STR(x31, "# Test number 2\n")


    # Addresses for test data and results
	la	x1, test_2_res

	TEST_CASE(x3, x5, 0xf0, x1, 0, \
    la  x26, test_data; \
    lhu x5, 0x4(x26); \
    )
	TEST_CASE(x3, x6, 0xeee, x1, 4, \
    la  x25, test_data; \
    lhu x6, 0x0(x25); \
    )
	TEST_CASE(x3, x7, 0xeee, x1, 8, \
    la  x24, test_data; \
    lhu x7, 0x0(x24); \
    )
	TEST_CASE(x3, x8, 0xeee, x1, 12, \
    la  x23, test_data; \
    lhu x8, 0x0(x23); \
    )
	TEST_CASE(x3, x9, 0xbbb, x1, 16, \
    la  x22, test_data; \
    lhu x9, -0x2(x22); \
    )


	# ---------------------------------------------------------------------------------------------
	RVTEST_IO_WRITE_STR(x31, "# Test number 3\n")


    # Addresses for test data and results
	la	x1, test_3_res

	TEST_CASE(x8, x10, 0xdd0d, x1, 0, \
    la  x21, test_data; \
    lhu x10, 0x2(x21); \
    )
	TEST_CASE(x8, x11, 0xcc0c, x1, 4, \
    la  x20, test_data; \
    lhu x11, -0x4(x20); \
    )
	TEST_CASE(x8, x12, 0xdd0d, x1, 8, \
    la  x19, test_data; \
    lhu x12, 0x2(x19); \
    )
	TEST_CASE(x8, x13, 0xf0, x1, 12, \
    la  x18, test_data; \
    lhu x13, 0x4(x18); \
    )
	TEST_CASE(x8, x14, 0xeee, x1, 16, \
    la  x17, test_data; \
    lhu x14, 0x0(x17); \
    )


	# ---------------------------------------------------------------------------------------------
	RVTEST_IO_WRITE_STR(x31, "# Test number 4\n")


    # Addresses for test data and results
	la	x2, test_4_res

	TEST_CASE(x4, x15, 0xeee, x2, 0, \
    la  x16, test_data; \
    lhu x15, 0x0(x16); \
    )
	TEST_CASE(x4, x16, 0xeee, x2, 4, \
    la  x15, test_data; \
    lhu x16, 0x0(x15); \
    )
	TEST_CASE(x4, x17, 0xbbb, x2, 8, \
    la  x14, test_data; \
    lhu x17, -0x2(x14); \
    )
	TEST_CASE(x4, x18, 0xdd0d, x2, 12, \
    la  x13, test_data; \
    lhu x18, 0x2(x13); \
    )
	TEST_CASE(x4, x19, 0xcc0c, x2, 16, \
    la  x12, test_data; \
    lhu x19, -0x4(x12); \
    )


	# ---------------------------------------------------------------------------------------------
	RVTEST_IO_WRITE_STR(x31, "# Test number 5\n")


    # Addresses for test data and results
	la	x1, test_5_res

	TEST_CASE(x3, x20, 0xdd0d, x1, 0, \
    la  x11, test_data; \
    lhu x20, 0x2(x11); \
    )
	TEST_CASE(x3, x21, 0xf0, x1, 4, \
    la  x10, test_data; \
    lhu x21, 0x4(x10); \
    )
	TEST_CASE(x3, x22, 0xeee, x1, 8, \
    la  x9, test_data; \
    lhu x22, 0x0(x9); \
    )
	TEST_CASE(x3, x23, 0xeee, x1, 12, \
    la  x8, test_data; \
    lhu x23, 0x0(x8); \
    )
	TEST_CASE(x3, x24, 0xeee, x1, 16, \
    la  x7, test_data; \
    lhu x24, 0x0(x7); \
    )


	# ---------------------------------------------------------------------------------------------
	RVTEST_IO_WRITE_STR(x31, "# Test number 6\n")


    # Addresses for test data and results
	la	x1, test_6_res

	TEST_CASE(x8, x25, 0xbbb, x1, 0, \
    la  x6, test_data; \
    lhu x25, -0x2(x6); \
    )
	TEST_CASE(x8, x26, 0xdd0d, x1, 4, \
    la  x5, test_data; \
    lhu x26, 0x2(x5); \
    )
	TEST_CASE(x8, x27, 0xcc0c, x1, 8, \
    la  x4, test_data; \
    lhu x27, -0x4(x4); \
    )
	TEST_CASE(x8, x28, 0xdd0d, x1, 12, \
    la  x3, test_data; \
    lhu x28, 0x2(x3); \
    )
	TEST_CASE(x8, x29, 0xf0, x1, 16, \
    la  x2, test_data; \
    lhu x29, 0x4(x2); \
    )


	# ---------------------------------------------------------------------------------------------
	RVTEST_IO_WRITE_STR(x31, "# Test number 7\n")


    # Addresses for test data and results
	la	x2, test_7_res

	TEST_CASE(x4, x30, 0xeee, x2, 0, \
    la  x1, test_data; \
    lhu x30, 0x0(x1); \
    )
	TEST_CASE(x4, x31, 0xeee, x2, 4, \
    la  x1, test_data; \
    lhu x31, 0x0(x1); \
    )


	# ---------------------------------------------------------------------------------------------
	
	RVTEST_IO_WRITE_STR(x31, "Test End\n")

	# ---------------------------------------------------------------------------------------------

	RV_COMPLIANCE_HALT

RV_COMPLIANCE_CODE_END

# Input data section.
	.data
	.align 4
test_data_start:

	.word 0x11f1f222
	.word 0xf33344f4
	.word 0x55f5f666
	.word 0xf77788f8
	.word 0x99090aaa
	.word 0xbbbcc0c
test_data:
	.word 0xdd0d0eee
	.word 0xfff00f0
	.word 0x12345678
	.word 0x9abcdef0
	.word 0x76543210
	.word 0xfedcba98

# Output data section.
RV_COMPLIANCE_DATA_BEGIN

.equ test_1_res, 40
.equ test_2_res, 80
.equ test_3_res, 120
.equ test_4_res, 160
.equ test_5_res, 200
.equ test_6_res, 240
.equ test_7_res, 280

RV_COMPLIANCE_DATA_END

