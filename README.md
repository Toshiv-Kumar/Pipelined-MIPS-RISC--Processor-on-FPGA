# Pipelined-MIPS-RISC-Processor-on-FPGA
Designed a 32-bit RISC based pipelined processor and implemented the complete FPGA design flow using Vivado. Verified the design by implementing a factorial program.

## Theory
### Let's start with the basics of COA:
What is the difference between  Computer Organization and Architecture?

<img width="1302" height="733" alt="image" src="https://github.com/user-attachments/assets/fcd19b68-6f19-4c41-8f0e-9a8bd8473e81" />

### Process of execution of instruction and Processor Memory Interaction
<img width="1292" height="698" alt="image" src="https://github.com/user-attachments/assets/74fd9406-3d9c-450d-bca0-8db45c6cd02c" />

**What are a few types of CPU Registers?**
Accumulator : This is the most frequently used register used to store data taken from memory.
Memory Address Registers (MAR) : It holds the address of the location to be accessed from memory. MAR and MDR (Memory Data Register) together facilitate the communication of the CPU and the main memory.
Memory Data Registers (MDR) : It contains data to be written into or to be read out from the addressed location.

### The MIPS processor I designed currently stores bytes in Little Endian format
<img width="1292" height="717" alt="image" src="https://github.com/user-attachments/assets/db222d51-8485-41f8-bfda-565f7abe06eb" />
Little Endian-: Lowest byte to lowest address. Instruction word is stored exactly as written.

# ISA and Addressing Modes

### The Program flow in short:
<img width="1278" height="662" alt="image" src="https://github.com/user-attachments/assets/52388a68-c06e-442c-af28-bf24a31e8e99" />

## Types of Instructions:
1. Arithmetic and Logical Instructions: Goes by the name. Performs these operations on the register or memory values.
2. Data Movement Instructions: Movement of data from Registers to memory or vice versa. Eg-: Load and Store
3. Control Flow Instructions: Halting, jumping, or starting the program.
