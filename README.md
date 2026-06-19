# RISC-V 64-bit Single Cycle Processor (Verilog)

## 🧠 Overview
This project presents the design and implementation of a 64-bit single-cycle RISC-V processor (RV64I subset) using Verilog HDL. The processor executes each instruction in a single clock cycle following the classical single-cycle datapath architecture.

---

## ⚙️ Supported Instructions
The processor supports a subset of the RV64I instruction set, including:
- R-type: add, sub, and, or, xor, sll, srl
- I-type: addi, andi, ori, xori
- Load/Store: ld, sd
- Branch: beq, blt

---

## 🏗️ Architecture
The design consists of the following main modules:
- Program Counter (PC)
- Instruction Memory
- Register File
- ALU
- Control Unit (merged with ALU control)
- Immediate Generator
- Data Memory
- PC Update Logic

All modules are integrated into a single-cycle datapath where each instruction completes in one clock cycle.

---

## 🧠 Key Design Features
- Signed comparison support for branch instructions (BLT)
- Merged Control Unit and ALU Control for simplified design
- Word-aligned instruction and data memory
- 64-bit register architecture
- Fully combinational datapath with synchronous PC update

---

## 🧪 Verification
The processor was verified using Vivado XSim with a 15-instruction test program.

### Results:
- ✔ 11/11 assertions passed
- ✔ 0 simulation failures
- ✔ Correct execution of arithmetic, memory, and branch instructions

---

## 📊 Example Test Results
- x15 = 5  
- x16 = -1  
- x19 = 128  
- x21 = 100  
- x23 = 128  
- Mem[80] = 128  

---

## 🛠️ Tools & Technologies
- Verilog HDL
- Vivado XSim
- Digital Design Concepts
- RISC-V ISA (RV64I subset)

---

## 👨‍💻 My Contribution
- Implemented Program Counter (PC) module
- Designed and verified core datapath components
- Assisted in integration and simulation testing

---

## 📌 Course Information
Developed as part of CSC311 – Introduction to Computer Architecture, Nile University (Spring 2026).

---

## 📚 Reference Design
Based on classical single-cycle RISC-V architecture (Patterson & Hennessy).
