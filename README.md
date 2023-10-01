SoC RISC-V: An ASIC implementation of the FEMTORV32
===============================================================
Designed by Felipe Ferreira Nascimento, São Paulo, Brazil.

Overview
--------
The RISC-V architecture, an open-source ISA with a Berkeley Software Distribution (BSD) license, has been gaining global recognition in both academia and the market. The reduced and expandable instruction set of this architecture allows for the implementation of versatile microarchitectures, suitable for both specific and general-purpose applications. This study is dedicated to the full physical implementation of an SoC based on the RISC-V architecture, using the FemtoRV32 project as a foundation. The Quark core, which executes the base RV32I instruction set, was the choice for this implementation. This work is among the first to complete a full physical implementation of the Quark core, offering a validated microarchitecture that can be utilized in future ASIC projects. The initial implementation was performed on a low-cost iCESugar-nano FPGA and subsequently transposed to a 180 nm CMOS technology. The results obtained show that the Quark core is a viable option for economical microprocessor projects, operating at frequencies of up to 120 MHz. One of the highlights of this study is the implementation of an automated testing environment, providing a validation framework that spans from the front-end phase to post-layout. With the chip already in hand, future power characterization tests and other analyses are planned, with the aim of evaluating the SoC's strengths and areas for improvement. This work aims to be a valuable resource for future research in RISC-V-based implementations.

FemtoRV32: https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV
Copyright (c) 2020-2021, Bruno Levy
All rights reserved.

##
The requirements for simulating the SoC are:  iverilog
(iverilog.icarus.com), and the RISC-V gcc configured for the
RISC-V options used by the Femtorv32 or picoRV32 processor design.  The best way to obtain the correct gcc cross-compiler is to install the
picoRV32 source from github (https://github.com/cliffordwolf/picorv32).


![SoC-RISC-V](docs/block_diagram.png)
