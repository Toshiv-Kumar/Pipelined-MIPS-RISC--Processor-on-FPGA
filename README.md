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
The combinational ckts that lie within the pipeline have different amount of delays. The input to the stage must be stable for a specific amount of time as only then the output can be determined, if the input of a stage changes then the output can change at the wrong time if the previous stage has much lesser delay. So we try to synchornize the stages by the delay of the slowest stage + delay of latch as the clk frequency of the entire operation or the frequency of production of output. That can be done by inserting baskets/latches in between stages so as to hold the previous outputs so as to isolate the inputs and outputs from each other. 
This frequency(f=1/T) represents the throughput of the pipeline per unit time.
Speedup-: less_time(stages)/more_time(no stages) . Try to derive this yourself.
Efficiency = Speedup/ideal_speedup. Ideal speedup is the number of stages

If an old instruction running in the pipeline has variable that needs to be used as it is without any modification then that variable is transferred through latches in each clock. For every single variable that is suppossed to be propagated through stages or is used in only a specific stages as known beforehand then it is replicated to multiple variables with first name having the name of the inter-stage latch name. 
Eg-: EX_MEM_ALUOut,etc.
All the variables are implemented as inter stage latches.

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


# MIPS32 Instruction Cycle
The instruction cycle or the time required to complete one instruction is divided into 5 steps:
The default number of ports that come with a simple declaration of a register bank are 3. 2 for concurrent output or the read ports and 1 is a write port.
Whereas, in case of a BRAM it can be single-port or dual port as per user's choice.

## This is the view of how our processor's stages work in a pipeline-:

<img width="1188" height="505" alt="image" src="https://github.com/user-attachments/assets/9d075ca7-e461-4bb9-901a-fa292dfa969b" />

### Instead of a normal clock , 2-phase clock is implemented as it offers complete seperation of one stage from the other and hence the input does not change unnecessarily affecting the output.

<img width="1215" height="472" alt="image" src="https://github.com/user-attachments/assets/a05aaeb0-b6cd-438a-aac3-9075664f5113" />

## The better way to analyze the 2-phase clocking is this compared to a simply combining them together for ease.
![WhatsApp Image 2026-01-08 at 7 09 54 PM](https://github.com/user-attachments/assets/04f95233-3135-4b43-9638-fc6186fc8763)

# Micro-operations for pipelined processor

<img width="1195" height="477" alt="image" src="https://github.com/user-attachments/assets/0b2165c5-a915-44b0-ada9-01e71aaad4d5" />


<img width="1111" height="476" alt="image" src="https://github.com/user-attachments/assets/2341e80e-41c2-407c-a60f-1c7b2682c566" />


<img width="1172" height="516" alt="image" src="https://github.com/user-attachments/assets/a18d72e3-3539-447a-a9f1-f0f660e1f2ae" />

For byte addressable memory pc has to be incremented by +4. Each byte has its own address and hence only after 4 bytes(32bits) we can actually access the next instruction.


<img width="1092" height="440" alt="image" src="https://github.com/user-attachments/assets/87a296e2-e770-4b63-a3de-6c7c50f44f0d" />

<img width="1277" height="495" alt="image" src="https://github.com/user-attachments/assets/856a328e-77d5-45de-8d16-d8e780a25a4a" />

<img width="1156" height="493" alt="image" src="https://github.com/user-attachments/assets/3ca59b97-9eba-4e1a-b764-970e876814fc" />

<img width="1277" height="495" alt="image" src="https://github.com/user-attachments/assets/fe109654-e816-4fac-aee0-cf90cd6dbf5e" />


<img width="1256" height="531" alt="image" src="https://github.com/user-attachments/assets/66fce8ac-8774-4682-b888-aed46e401b40" />


<img width="1227" height="561" alt="image" src="https://github.com/user-attachments/assets/c24589e1-65d8-4cdc-8d4c-ce338a11d210" />

<img width="1297" height="541" alt="image" src="https://github.com/user-attachments/assets/be9688e2-efa0-457f-b381-c085e921139f" />


# Quick-view at operations for different types of instructions in short

<img width="1212" height="445" alt="image" src="https://github.com/user-attachments/assets/ced32a80-6953-4d21-bee0-44d7554df374" />

<img width="1236" height="556" alt="image" src="https://github.com/user-attachments/assets/12bb9153-042f-4eb4-8053-751fac29e8bc" />

<img width="657" height="425" alt="image" src="https://github.com/user-attachments/assets/1b08dc26-34cd-462a-9005-6d610cd52f0a" />

# Hazards in a pipeline implementation
1. Structural -: Happens when 2 stages of pipeline that have different instructions in them and they happen to use the same piece of hardware to read or write. That hardware may not support many concurrent read/writes at the same time.
2. Data hazards -: It arises due to instruction dependency. When an instruction uses a suposedly modified register/Memory from the previous instruction, then it is highly likely that modification is not yet done on the data and we are actually picking up the old value as the previous instruction is not yet completed and still stuck in one of the pipeline stages.
3. Control hazards -: It arises due to branch instructions. Whether the branch is to be executed or not is determined in the EX stage and by that time the next instruction from the wrong PC address was picked up. Hence 1 clock cycle is wasted there.
We only prevented Data hazards by dummy instructions in the assembly code as the user instead of implemented data forwarding.

# Implementation using Verilog

<img width="1272" height="535" alt="image" src="https://github.com/user-attachments/assets/398a93e7-1562-427d-9562-5639f46d4485" />

1. Halted variable logic(For pipeline) -: As per the timing diagram above, after instruction opcode decoding we come to know that it is a Halt instruction but we cannot yet halt the program since there is 1 previous instruction that is there in the pipeline that needs to be fully executed so we only place the HALTED flag as 1 at WB of the HLT instruction.
2. TAKEN_BRANCH logic -: According to the timing diagram, only the very next instruction after the branch instruction is invalid. So accordingly we turn on the TAKEN_BRANCH variable in IF_ID stage after EX_MEM_cond is set to 1 and the branch variable is immediately turned off on the very next clk1. This prevents the previous invalid instruction to write data and allows the 3rd(compared to branch[1st]) to write and read data in MEM and WB.
Do note that nptel taught it wrong, specifically the timing diagram that shows using simple clock compared to the actual 2-phase implementation. 
