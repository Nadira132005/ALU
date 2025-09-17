# CN - Basic ALU Implementation in Verilog

[![Verilog](https://img.shields.io/badge/Language-Verilog-blue?style=for-the-badge&logo=verilog)](https://www.verilog.com/)

## Overview

This project implements a basic **Arithmetic Logic Unit (ALU)** in Verilog, along with supporting digital components such as an adder, multiplexer, flip-flop, and counter. It serves as an educational example for understanding fundamental digital design concepts using hardware description languages (HDL). The ALU supports common operations like addition, subtraction, AND, OR, XOR, and more, controlled by an ALU control unit.

The design is modular, with each component defined in separate Verilog files, and includes a SystemVerilog testbench for simulation and verification.

## Features

- **32-bit ALU**: Performs arithmetic (add, subtract) and logical operations (AND, OR, XOR, NOR, SLT).
- **Adder Module**: A simple ripple-carry 32-bit adder for arithmetic computations.
- **2-to-1 Multiplexer**: Selects between inputs for ALU result routing.
- **ALU Control Unit**: Decodes control signals (ALUOp, funct7, funct3) to generate operation-specific controls.
- **D Flip-Flop**: Basic sequential element for register-like behavior.
- **4-bit Counter**: Up-counter for sequencing or timing applications.
- **Testbench**: Comprehensive SystemVerilog test suite to verify ALU functionality with various inputs.

## File Structure

```
cn/
├── adder.v                 # 32-bit adder module
├── ALU_control_unit.v      # ALU control logic decoder
├── counter.v               # 4-bit up counter
├── ff.v                    # D flip-flop
├── mux2_1.v                # 2-to-1 multiplexer
├── testbench.sv            # SystemVerilog testbench for ALU
└── README.md               # This file
```

## Prerequisites

- A Verilog simulator such as:
  - Icarus Verilog (`iverilog`) for open-source simulation.
  - ModelSim or Vivado Simulator for advanced features.
- SystemVerilog support (for the testbench).

Install Icarus Verilog (on Linux):
```bash
sudo apt update
sudo apt install iverilog
```

## Usage

### Simulation

1. **Compile the Design**:
   Run the following command in the project root to compile all modules and the testbench:
   ```bash
   iverilog -o alu_sim *.v testbench.sv
   ```

2. **Run the Simulation**:
   Execute the compiled simulation:
   ```bash
   vvp alu_sim
   ```
   This will run the testbench, displaying input/output waveforms or results in the console (depending on `$display` statements).

3. **View Waveforms** (Optional):
   For visual debugging, use GTKWave:
   ```bash
   # Generate VCD file during simulation (add `$dumpfile` and `$dumpvars` in testbench if not present)
   gtkwave dump.vcd
   ```

### Example Test Output

The testbench verifies ALU operations with inputs like:
- Add: `A=5, B=3` → Result=8
- Subtract: `A=5, B=3` → Result=2
- AND: `A=5 (101b), B=3 (011b)` → Result=1 (001b)

All tests should pass without errors, confirming correct implementation.

## Architecture

The ALU integrates:
- An **adder** for arithmetic.
- A **multiplexer** to select the operation result.
- Control signals from the **ALU control unit** to choose operations based on RISC-V-like opcodes.

The flip-flop and counter are standalone modules that can be integrated into larger designs, such as a simple processor pipeline.
