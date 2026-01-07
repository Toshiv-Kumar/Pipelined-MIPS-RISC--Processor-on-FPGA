# Pipelined-MIPS-RISC-Processor-on-FPGA
Designed a 32-bit RISC(Reduced Instruction set architecture) based pipelined processor and implemented the complete FPGA design flow using Vivado. Verified the design by implementing a factorial program.
# Overview in short and complete Theory explained later-:


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
**Instructions** : Instructions are words(commands) whereas the ISA is the vocabulary.
Microarchitecture and circuits is the specific implementation of that ISA.
### The Program flow in short:
<img width="1278" height="662" alt="image" src="https://github.com/user-attachments/assets/52388a68-c06e-442c-af28-bf24a31e8e99" />

## Types of Instructions:
1. Arithmetic and Logical Instructions: Goes by the name. Performs these operations on the register or memory values.
2. Data Movement Instructions: Movement of data from Registers to memory or vice versa. Eg-: Load and Store
3. Control Flow Instructions: Halting, jumping, or starting the program.

**Note-:** I am using the Register-Register-Load-Store ISA in this design. This allows the ALU to access only the registers on the processor for operations and can't directly access the memory.

### Addressing Modes Used in this project are:
<img width="1246" height="302" alt="image" src="https://github.com/user-attachments/assets/1928ff69-baec-402c-ba16-7355f378d503" />

- Immediate addressing — used by ADDI R10, R0, 200 and SUBI R3, R3, 1: an immediate constant is encoded in the instruction and used as an operand.
- Register (register‑direct) addressing — used by MUL R2, R2, R3 and OR R20, R20, R20: operands come directly from registers.
- Base + displacement (register indirect with offset) — used by LW R3, 0(R10) and SW R2, -2(R10): memory address = contents of base register (R10) plus a signed offset.

## RISC features
1.  Reduces the cycles per instructions and that results in simple instructions but a larger number of instructions needed to execute a program. Encoding is simple.


# Introduction to Pipelining(Linear used)

<img width="1308" height="432" alt="image" src="https://github.com/user-attachments/assets/52a17df6-4ac1-4d95-a0b5-189291a7897b" />

For a large number of instructions to be executed, only then the total time is reduced by a factor of k(splits).

## Why a buffering mechanism is needed?
The combinational ckts that lie within the pipeline have different amount of delays. The input to the stage must be stable for a specific amount of time as only then the output can be determined, if the input of a stage changes then the output can change at the wrong time if the previous stage has much lesser delay. So we try to synchornize the stages by the delay of the slowest stage+delay of latch as the clk frequency of the entire operation or the frequency of production of output. That can be done by inserting baskets/latches in between stages so as to hold the previous outputs so as to isolate the inputs and outputs from each other. 
This frequency(f=1/T) represents the throughput of the pipeline per unit time.
Speedup-: less_time(stages)/more_time(no stages) . Try to derive this yourself.
Efficiency = Speedup/ideal_speedup. Ideal speedup is the number of stages

## Important Delays:

<img width="1306" height="546" alt="image" src="https://github.com/user-attachments/assets/63486a12-8574-4dc3-9500-a72e29f69b91" />
Jitter: The noise in the signal due to environmental factors
Clock Skew: If due to the actual wiring the time it takes for the clock to reach different parts of the ckt is different then the slowest activated hardware dut to clock  and the fastest activated hardware have a time difference between them. That is called the clock skew.

# Lets see the MIPS32 processor and the pipeline implementation used to design it
<img width="1265" height="497" alt="image" src="https://github.com/user-attachments/assets/87f241a3-eca1-4462-88bb-88edfb2fa53f" />

What is the use of flag registers?
Flag registers hold single‑bit status indicators that reflect the outcome of recent operations and control conditional behavior. They’re used to record conditions like zero, carry/borrow, overflow, and negative/sign, which the CPU or ALU checks to decide branches, arithmetic adjustments, or exception handling.
They help in the primarily provide support in the pipeline

What is the difference byte and word addressable?
- Byte‑addressable: Each memory address refers to one byte. To access a 32‑bit word you read four consecutive byte addresses (or the memory returns a 32‑bit word assembled from those bytes).
- Word‑addressable: Each memory address refers to a machine word (for example, 32 bits). Address n refers to the nth word; there is no separate address for individual bytes inside that word.

## The different instructions used in this processor implementation and their working
Here when we say R2 then that means we are picking up the actual value of the register which has the address of R2 by going to that address.

<img width="1297" height="532" alt="image" src="https://github.com/user-attachments/assets/44dc1fc5-19a4-4e73-95b0-f12ca2a6f3a7" />

<img width="1187" height="507" alt="image" src="https://github.com/user-attachments/assets/e7c59a7c-404e-46e7-8479-6468fd74d1b3" />
Notice that the BEQ instruction has only 2 operands so there are 6 bits which are left unused of a source field.
## Instruction Encoding and their fixed format
<img width="1188" height="411" alt="image" src="https://github.com/user-attachments/assets/7437287b-f82f-4ade-9b9d-9fb07a4ed5d6" />


<img width="1300" height="412" alt="image" src="https://github.com/user-attachments/assets/a1687820-57da-47e7-9eb4-c7ae91ada12d" />
The R-type instructions execute the basic Arithmetic and Logical operations.

<img width="1211" height="400" alt="image" src="https://github.com/user-attachments/assets/77cb65c9-16bf-4d50-b9ff-5532f5134dfc" />

The I- type instruction includes the basic Arithmetic operations along with **load/store and branch instructions**


