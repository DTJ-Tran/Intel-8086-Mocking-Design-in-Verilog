# Intel-8086-Mocking-Design-in-Verilog - Memory Automation Module for Verilog-Based CPU Simulation

This repository contains a Verilog implementation of a Memory Automation Module designed for CPU simulations. The module integrates memory management functionality, address generation, and instruction pointer handling, enabling dynamic memory access and control.

Features:

	•	Instruction Pointer (IP) Management: Generates and manages the instruction pointer with reset and load capabilities.
 
	•	Address Generation Circuit: Converts logical addresses to physical addresses based on the provided segment and instruction pointer offset.
 
	•	Memory Access Modes:
 
	•	Instance Read/Write: Automatic access controlled by the module.
 
	•	Manual Access: Allows manual read/write operations using an external physical address register.
 
	•	Operation Selector: Supports multiple operations (read/write modes) using a 4-to-1 multiplexer (mul_4_to_1).
 
	•	Used Address Logging: Logs accessed memory addresses in a circular buffer (RESULT_SIZE).
 

Submodules: memory_automate (do include with these component)

	•	mul_4_to_1: A multiplexer for operation selection.
 
	•	InstructionPointer: Manages the instruction pointer with clocked updates.
 
	•	AddressGenerationCircuit: Generates physical addresses from logical components.
 
	•	memory: Handles data storage, input, and output operations.
 

Usage:

This module is a simmulation of CPU or hardware design projects where:

	•	Fine-grained control over memory operations is needed.
 
	•	Simulation of physical memory access is required.
 
	•	A modular design approach benefits system extensibility.
 

Getting Started:
	•	Clone the repository.
 
	•	Simulate the module using a Verilog simulator like ModelSim or Xilinx Vivado.
 
	•	Integrate with other CPU or memory management components.
 
  	•	Run the test.vvp (compile from the file PrototypeVer2_2.v)
  

Contribution:

Dat Tran Tien - trantiendat083@gmail.com

Dung Nguyen Khanh - dung.nkv207947@sis.hust.edu.vn

Cuong Nguyen Kim - tuancuong112504@gmail.com

An Nguyen Hai - haiann663@gmail.com

Tri Nguyen Duc - ndtribk@gmail.com

