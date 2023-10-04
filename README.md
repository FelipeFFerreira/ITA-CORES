# 🚀 SoC RISC-V: An ASIC Implementation of the FEMTORV32
#### 🛠️ Designed by Felipe Ferreira Nascimento, São Paulo, Brazil.

---
## 🌐 Overview
The RISC-V architecture, under a Berkeley Software Distribution (BSD) license, is revered globally in academia and the industry. This project aims at a full physical implementation of an SoC using the FemtoRV32 project, offering a microarchitecture ready for future ASIC projects.

🔗 [FemtoRV32 Project](https://github.com/BrunoLevy/learn-fpga/tree/master/FemtoRV)
- 📄 Copyright (c) 2020-2021, Bruno Levy
- 📜 All rights reserved.

---
## 🛠 Requirements
To simulate the SoC, the following tools are needed:
- [Iverilog](http://iverilog.icarus.com)
- RISC-V GCC configured for Femtorv32 or picoRV32 processor design.

💡 **Tip:** Acquire the correct GCC cross-compiler by installing the picoRV32 source from [GitHub](https://github.com/cliffordwolf/picorv32).

---
## 🌟 ITA-CORES Initiative
Acknowledging the global advancements in RISC-V and Open Source, ITA introduced the "ITA CORES" initiative focusing on designing and manufacturing digital processors based on the RISC-V ISA.
![ITA.CORES](docs/ITA_CORES_LOGO_OF.png)

---
## 🧠 SoC RISC-V Implementation
This project aimed to implement and physically validate the Quark core, ideal due to its compact microarchitecture for low-cost implementations.
![SoC-RISC-V](docs/block_diagram.png)

### 🛠 Methodologies and Tools
We explored essential methodologies and tools necessary for a complex digital flow, targeting the efficient implementation and validation of the core.
![Development Phases](docs/steps.png)
![Tap-out](docs/tapout.png)

---
## 📚 Framework Details
In digital chip development, optimizations often lead to modifications in the original design, which, although intended for improvements, can introduce errors or inconsistencies.

### 🛠 Developed Framework
This project developed a framework to verify the conformity of the Quark core with the ISA RISC-V specifications.
![Framework](docs/diagrama_fluxo_test.png)
![Purpose of the Framework](docs/fluxo_automatizado.png)

#### 🌀 Functioning and steps of the framework
The framework operates through several stages, managing test files, setting up test environments, compiling with the RISC-V toolchain, organizing compiled files, preparing instructions for simulation, automated test execution and validation, and finally, executing tests on a physical device.

1. **Stage 1: Test File Management**
   - System identifies and manages the test files, which are stored in five main repositories, supporting test files written in both C language and RISC-V assembly.

2. **Stage 2: Test Environment Setup**
   - Application prepares the automated testing environment through a series of specialized scripts.

3. **Stage 3: Compilation with the RISC-V Toolchain**
   - The application uses the RISC-V toolchain to convert the test files into executable machine code.

4. **Stage 4: Organization of Compiled Files**
   - The files and their dependencies are organized in specific directories for each test.

5. **Stage 5: Preparation of Instructions for Simulation**
   - The resulting .elf files are converted into instructions in hexadecimal format suitable for digital simulators used in the project.

6. **Stage 6: Automated Test Execution and Validation**
   - This stage involves the execution and automated validation of each test, providing visual feedback on the test status.

7. **Stage 7: Execution of Tests on Physical Device**
   - This stage involves setting up and executing the tests on hardware, such as an FPGA or physical chip.



## 🛠 Framework Execution Guide

### 📁 Directory Preparation

1. **Initial Setup**  
   Navigate to the directory: `femtorv32/FemtoRV/Frontend/scripts`. This repository stores the main codes used in the development of the framework.

2. **Framework Construction**  
   In your terminal (ensure you're in the path indicated above), type:  `sudo make all ENV_FRONTEND_SIGNOFF=1`
   This command constructs the framework, primarily considering the environment for simulation execution. This step encompasses the compilation of files and dependencies essential for the framework's execution.
   Upon completion, a `bin` folder will be created in the `/scripts/bin` directory, storing the compiled binaries.

### 🖥 Framework Interface
   
   Upon the successful setup, running the framework will display a user interface showcasing the available functions as outlined in the [Functioning and steps of the framework](#-functioning-and-steps-of-the-framework) section.

   ![Framework Interface](docs/janela_inicial.png)

   For a practical demonstration, the image below showcases the interface when executing the official RISC-V conformity tests, i.e., option 1.

   ![Conformity Test Example](docs/etapas.png)

### 📂 File Organization & Test Execution

   After test execution, you can locate the generated files in the `../build` directory. This directory organizes each test individually, identified by their respective names.

   ![Directory Structure](docs/diretorios.png)

   When accessing a specific test directory, the following file structure can be observed:

   - `.bin` - Binary file for physical devices.
   - `.elf` - Executable and linkable file.
   - `.hex` - Executable instruction file.
   - `_firmware.hex` - Formatted file for digital simulators.
   - `_firmware_spi.v` - SPI interface file.
   - `testbench_XD.vcd` - Resulting simulation file.

   For example, the `ADD` instruction test might present:

   ![File Structure](docs/arquivos.png)

   Following the test's completion, the resulting log file can be found in `../build`. Utility and linker files for the processor are located in `../firmware`, while intermediary files for test execution are in `../test_repository_name/base_testbench`. Where 'teste_repository_name' refers to the name of the test in question.

   ![File log](docs/log_full.png)



   For execution tests related to the LowRISC project, consider:

   1. Navigate to the directory: `femtorv32/FemtoRV/Frontend/scripts`.
   2. In your terminal, type: `sudo make all ENV_FRONTEND_SIGNOFF=1`.
   3. Select option 2. The necessary dependencies will be verified.
   4. The following image illustrates a sample execution, where several operations are performed. Ultimately, a signature is generated and compared with the reference signature found in `../riscv-test-suite/references`. Test coverages can also be located in this repository.

   ![riscv-test-suite references](docs/lowrisc_inicio.png)

   ![riscv-test-suite references](docs/lowrisc_testes.png)


---
### 💌 Feedback & Contributions
Your feedback and contributions are highly welcomed and appreciated! Feel free to improve any part of this project and submit your ideas and enhancements.
