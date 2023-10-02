# SoC RISC-V: An ASIC Implementation of the FEMTORV32
Designed by Felipe Ferreira Nascimento, São Paulo, Brazil.

## Overview
The RISC-V architecture, an open-source ISA under a Berkeley Software Distribution (BSD) license, is receiving global acclaim in academia and the industry. It offers a reduced and expandable instruction set, allowing the creation of versatile microarchitectures for both specific and general-purpose applications. This study revolves around the full physical implementation of an SoC using the RISC-V architecture, specifically building upon the FemtoRV32 project. We chose the Quark core, executing the base RV32I instruction set, for this implementation, marking one of the initial full physical implementations of this core. It provides a validated microarchitecture suitable for future ASIC projects. The project underwent its initial implementation on a low-cost iCESugar-nano FPGA before transitioning to a 180 nm CMOS technology. The outcomes indicate that the Quark core is a feasible alternative for cost-efficient microprocessor projects, operating at frequencies up to 120 MHz. This study emphasizes the introduction of an automated testing environment that spans from the front-end phase to post-layout, promising thorough validation. With the physical chip now available, we are planning further power characterization tests and analyses to identify areas of improvement in the SoC. 

[FemtoRV32 Project](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV)  
Copyright (c) 2020-2021, Bruno Levy  
All rights reserved.

## Requirements
To simulate the SoC, the following are required:  
- [Iverilog](http://iverilog.icarus.com)
- RISC-V GCC configured for the RISC-V options used by the Femtorv32 or picoRV32 processor design.

To acquire the correct GCC cross-compiler, install the picoRV32 source from [GitHub](https://github.com/cliffordwolf/picorv32).

## ITA-CORES
RISC-V and Open Source are gaining substantial traction globally, prompting ITA to launch the "ITA CORES" initiative in 2022. It focuses on designing and manufacturing digital processors based on the RISC-V ISA, aiming to join global discussions on innovative and accessible technologies.  
![ITA.CORES](docs/ITA_CORES_LOGO_OF.png)

## SoC RISC-V
This work aimed to implement and physically validate a RISC-V core based on the FemtoRV32 project, leveraging the Quark core due to its compact microarchitecture, suitable for low-cost implementations. The primary goal is to optimize the microarchitecture for ASIC projects, ensuring it serves as a reference for future projects and acting as a valuable educational resource for expanding an open-source ISA (Instruction Set Architecture).  
![SoC-RISC-V](docs/block_diagram.png)

### Methodologies and Tools
This project explored crucial methodologies and tools needed for a complex digital flow, aiming for the effective implementation and validation of the core. The insights and results obtained are anticipated to significantly contribute to the community and spur advancements in processor architecture.

