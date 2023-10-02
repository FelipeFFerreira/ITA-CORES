# SoC RISC-V: An ASIC Implementation of the FEMTORV32
### Designed by Felipe Ferreira Nascimento, São Paulo, Brazil.

---
## Overview 🌐
The RISC-V architecture is an open-source ISA under a Berkeley Software Distribution (BSD) license, enjoying global recognition in academia and the industry due to its reduced and expandable instruction set. This project focuses on the full physical implementation of an SoC using the FemtoRV32 project as a foundation, presenting a validated microarchitecture suitable for future ASIC projects.

🔗 [FemtoRV32 Project](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV)
- Copyright (c) 2020-2021, Bruno Levy
- All rights reserved.

---
## 🛠 Requirements
- [Iverilog](http://iverilog.icarus.com)
- RISC-V GCC configured for Femtorv32 or picoRV32 processor design.

> 💡 To acquire the correct GCC cross-compiler, install the picoRV32 source from [GitHub](https://github.com/cliffordwolf/picorv32).

---
## 🌟 ITA-CORES Initiative
RISC-V and Open Source are forging paths in global innovation. ITA, recognizing this shift, launched the "ITA CORES" initiative, focusing on the design and manufacturing of digital processors based on the RISC-V ISA.
![ITA.CORES](docs/ITA_CORES_LOGO_OF.png)

---
## 🧠 SoC RISC-V Implementation
We aimed to implement and physically validate the Quark core based on the FemtoRV32 project due to its compact microarchitecture, ideal for low-cost implementations.
![SoC-RISC-V](docs/block_diagram.png)

### 🛠 Methodologies and Tools
Explored were crucial methodologies and tools needed for a complex digital flow, aimed at the effective implementation and validation of the core.
![Development Phases](docs/steps.png)
![Tap-out](docs/tapout.png)

---
## 🛠 Developed Framework
A framework was created to verify the conformity of the Quark core with the ISA RISC-V specifications, including various tests ensuring the validity and efficacy of the RISC-V SoC implementation.
![Framework](docs/diagrama_fluxo_test.png)
![Purpose of the Framework](docs/fluxo_automatizado.png)

### 📚 Framework Details
In digital chip development, the original representation of the design is often modified during various optimization stages. However, even minor modifications can introduce errors or inconsistencies, threatening the correctness and reliability of the design.

---
### 💌 Feedback & Contributions
Feel free to send your feedback and contribute to the project. Every piece of advice and contribution is highly appreciated!

