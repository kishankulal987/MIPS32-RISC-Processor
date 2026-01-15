# 🚀 MIPS32 Pipelined Processor Implementation

## 📌 Overview
This project implements a **pipelined processor** based on the **RISC (Reduced Instruction Set Computer)** architecture, which is easy to implement in pipelined systems.

### ⚠️ Note
We are not considering the whole processor, only a small subset with a limited number of instructions.

---

## ✨ Features

### 🔧 MIPS32 Registers

**a) 32-bit General Purpose Registers (GPRs)**
- 32 registers: `R0` to `R31`
- Used to temporarily store data during computation
- `R0` contains a constant 0 and cannot be written with other constants

**b) Program Counter (PC)**
- Special purpose 32-bit register
- Points to the next instruction to be fetched and executed
- MIPS has no flag registers

### 💾 Memory Architecture
- Very limited addressing modes: register mode, immediate, and register index are available
- Only load and store instructions can access the memory
- Memory word size: **32 bits** (word-aligned)

**What is word-aligned?**
<img width="921" height="296" alt="Untitled Diagram drawio (1)" src="https://github.com/user-attachments/assets/af485cf3-2060-487f-aef2-b03d84086d59" />

Each memory address points to one full word of data, not one byte. Word addressable memory means one address stores one complete word of data.

---

## 📚 MIPS Instruction Subset

### 🔄 Load and Store Instructions

**LW R2, 128(R8)**  
Meaning: `R2 = MEM[R8 + 128]`

**SW R5, -10(R25)**  
Meaning: `MEM[R25 - 10] = R5`

### ➕ Arithmetic and Logical Instructions (Register Operands)

- **ADD R1, R2, R3** — `R1 = R2 + R3`
- **ADD R1, R2, R0** — `R1 = R2 + 0` (indirect way to copy content)
- **SUB R12, R10, R8** — `R12 = R10 - R8`
- **AND R20, R1, R5** — `R20 = R1 & R5`
- **OR R11, R5, R6** — `R11 = R5 | R6`
- **MUL R5, R6, R12** — `R5 = R6 * R12`
- **SLT R5, R11, R12** — `if R11 < R12 then R5 = 1 else R5 = 0` (set less than)

All the above instructions are bitwise operations.

### 🔢 Arithmetic and Logic Instructions (Immediate Operand)

- **ADDI R1, R2, 25** — `R1 = R2 + 25`
- **SUBI R5, R1, 150** — `R5 = R1 - 150`
- **SLTI R2, R10, 10** — `if R10 < 10, R2 = 1, else R2 = 0`

### 🔀 Branch Instructions

- **BEQZ R1, Loop** — Branch to Loop if R1 = 0
- **BNEQZ R5, label** — Branch to label if R5 != 0

---

## 🏗️ Instruction Types

MIPS instructions can be classified as:
1. **R-type**
2. **I-type**
3. **J-type** (not implemented in my design)

### 1️⃣ R-type Instruction Encoding

<img width="1144" height="215" alt="image" src="https://github.com/user-attachments/assets/b5f7cd73-d0b1-48f2-bccd-54d75c933294" />


**Example:** `ADD R1, R2, R3` (R-type instruction)

**Opcode:** Tells what kind of operation it is (6 bits)

#### R-type Instructions with Opcodes

| Instruction | Opcode |
|-------------|--------|
| ADD         | 000000 |
| SUB         | 000001 |
| AND         | 000010 |
| OR          | 000011 |
| SLT         | 000100 |
| MUL         | 000101 |
| HLT         | 111111 (used to stop execution; not implemented in my design) |

**Example:** `SUB R5, R12, R25`
000001 01100 11001 00101 0000 000000
-SUB- -R12- -R25- -R5- -not required-
= 05992800 (in hex)

### 2️⃣ I-type Instruction Encoding
<img width="967" height="232" alt="image" src="https://github.com/user-attachments/assets/ead27e4c-f3e9-45de-bb8d-b17ed998cb77" />

**Example:** `ADDI R1, R2, 50`
- `R1` → destination register
- `R2` → source register
- `50` → 16-bit immediate data

#### I-type Instructions with Opcodes

| Instruction | Opcode |
|-------------|--------|
| LW          | 001000 |
| SW          | 001001 |
| ADDI        | 001010 |
| SUBI        | 001011 |
| SLTI        | 001100 |
| BNEQZ       | 001101 |
| BEQZ        | 001110 |

**Example:** `LW R20, 84(R9)`

001000 01001 10100 0000 000001010100
--LW-- --R9- -R20- ------offset-------
= 21340054 (in hex)


**Example:** `BEQZ R25, Label`

001110 11001 0000 yyyyyyyyyyyyyyy
-BEQZ- -R25- -NR- ---offset------
= 3b20yyyy (in hex)


Offset value will be added to the PC and then the address of the next instruction is obtained.

### 3️⃣ J-type Instruction Encoding (Not Implemented)
<img width="1041" height="175" alt="image" src="https://github.com/user-attachments/assets/199aa4f8-5034-4cc0-a0a1-109391bf068e" />


Contains a 26-bit jump address field, extended to 28 bits by padding 2 zeros on the right.

| Instruction | Opcode |
|-------------|--------|
| J           | 010000 |

---

## ⚙️ Pipeline Architecture

To speed up execution, we assume 2 source registers will be required for our computation. We prefetch two registers, though we don't know whether they are actually required until we decode the instruction.

### 🔁 Instruction Cycle

**Instruction Cycle:** Time period required for the execution of the complete instruction.

The instruction cycle can be divided into **5 sub-cycles:**

1. **IF:** Instruction Fetch
2. **ID:** Instruction Decode / Register Fetch
3. **EX:** Execution / Effective Address Calculation
4. **MEM:** Memory Access / Branch Completion
5. **WB:** Register Write Back

---

## 🔍 Pipeline Stages Detailed

### 1️⃣ IF (Instruction Fetch)

The instruction pointed by the PC is fetched from memory and the next value of PC is computed.

- Every MIPS instruction is 32 bits
- Every memory word is 32 bits and has a unique address
- For a branch instruction, new value of the PC may be the target address, so PC is not updated in this stage; new value is stored in register NPC

IR ← MEM[PC]
NPC ← PC + 1


For byte-addressable memory, PC has to be incremented by 4.

---

### 2️⃣ ID (Instruction Decode)

The instruction already fetched in IR is decoded.

- Opcode: 6 bits (bit[31:26])
- First source operand `rs`: bits[25:21]
- Second operand `rt`: bits[20:16]
- 16-bit immediate data: bits[15:0]

Decoding is done in parallel with reading the register operands `rs` and `rt`, possible because these fields are in a fixed location in the instruction format.

The immediate data is sign-extended.

A ← Reg[rs]
B ← Reg[rt]
Imm ← (IR15)^16 ##### IR[15:0] // sign extended 16-bit immediate field

The 16-bit immediate field is considered as a signed number in 2's complement form:
- If starts with 0 → positive immediate
- If starts with 1 → negative immediate

Replicate the sign bit (last bit).

---

### 3️⃣ EX (Execution / Effective Address Computation)

In this step, ALU is used to perform some calculation.

#### Memory Reference
ALUout ← A + Imm

**Example:** `LW R3, 100(R8)`
- `R8` is contained in A
- 100 is offset value which is added with A

#### Register-Register ALU Instruction
ALUout ← A func B

**Example:** `SUB R2, R5, R12`
- `func` can be any ALU operation

#### Branch
ALUout ← NPC + Imm
cond ← (A == 0)

**Example:** `BEQZ R2, label`
- `cond` is 1 bit

---

### 4️⃣ MEM (Memory Access / Branch Completion)

The instructions that make use of this step are loads, stores, and branches.

The load and store instructions access the memory. The branch instruction updates PC depending upon the outcome of the branch condition.

#### Load Instruction
PC ← NPC
LMD ← MEM[ALUout]

#### Store Instruction
PC ← NPC
MEM[ALUout] ← B

#### Branch Instruction
if (cond) PC ← ALUout
else PC ← NPC

#### Other Instructions
PC ← NPC

---

### 5️⃣ WB (Register Write Back)

Result may come from ALU or from the memory system.

#### Register-Register ALU Instruction
Reg[rd] ← ALUout

#### Register-Immediate ALU Instruction
Reg[rt] ← ALUout  

#### Load Instruction
Reg[rt] ← LMD

---

## 📝 Complete Instruction Implementation Examples

### Example 1: ADD R2, R5, R10

IF: IR ← MEM[PC]
NPC ← PC + 1

ID: A ← Reg[rs]
B ← Reg[rt]

EX: ALUout ← A + B

MEM: PC ← NPC

WB: Reg[rd] ← ALUout

---

### Example 2: ADDI R2, R5, 150

IF: IR ← MEM[PC]
NPC ← PC + 1

ID: A ← Reg[rs]
Imm ← (IR15)^16 ##### IR[15:0]

EX: ALUout ← A + Imm

MEM: PC ← NPC

WB: Reg[rt] ← ALUout

---

### Example 3: LW R2, 200(R6)

IF: IR ← MEM[PC]
NPC ← PC + 1

ID: A ← Reg[rs]
Imm ← (IR15)^16 ##### IR[15:0]

EX: ALUout ← Imm + A

MEM: PC ← NPC
LMD ← MEM[ALUout]

WB: Reg[rt] ← LMD

---

### Example 4: SW R3, 25(R10)

IF: IR ← MEM[PC]
NPC ← PC + 1

ID: A ← Reg[rs]
B ← Reg[rt]
Imm ← (IR15)^16 ##### IR[15:0]

EX: ALUout ← A + Imm

MEM: PC ← NPC
MEM[ALUout] ← B

WB: Nothing

---

### Example 5: BEQZ R3, label

IF: IR ← MEM[PC]
NPC ← PC + 1

ID: A ← Reg[rs]
Imm ← (IR15)^16 ##### IR[15:0]

EX: ALUout ← NPC + Imm
cond ← (A == 0)

MEM: if (cond) PC ← ALUout
else PC ← NPC

WB: Nothing
---

## 🔌 Datapath Design

### Complete Single-Cycle Datapath Architecture

The following diagram shows the complete datapath of the MIPS32 processor implementation:

<img width="2041" height="1323" alt="Untitled design (2)" src="https://github.com/user-attachments/assets/451cfb02-1c40-4430-a089-66bd5dc6a7d6" />

### Key Components

- **PC (Program Counter)** — Holds the address of the current instruction
- **Instruction Memory (IM)** — Stores the program instructions
- **GPRs (General Purpose Registers)** — 32 registers for data storage
- **ALU (Arithmetic Logic Unit)** — Performs arithmetic and logical operations
- **dmem (Data Memory)** — Stores data for load/store operations
- **Sign Extend** — Extends 16-bit immediate values to 32 bits
- **Multiplexers** — Control signal routing based on instruction type
- **Control Unit** — Generates control signals for datapath components

### Datapath Flow

1. **Instruction Fetch:** PC fetches instruction from Instruction Memory
2. **Register Read:** Source registers (rs, rt) are read from GPRs
3. **ALU Operation:** ALU performs computation based on instruction type
4. **Memory Access:** Load/Store instructions access data memory
5. **Write Back:** Results are written back to destination register

---

## 🧪 Simulation Results

### Test Program: SWAP TEST (Compare & Swap)

This test program demonstrates the compare-and-swap functionality by sorting two values in memory.

#### Initial Setup

**Registers:**
- R1 = 10
- R2 = 5

**Memory:**
- MEM[0] = 10
- MEM[4] = 5

#### Simulation Output

<img width="608" height="721" alt="Screenshot 2026-01-15 101111" src="https://github.com/user-attachments/assets/886e4645-f8e3-4222-958d-955982e08c48" />
<img width="575" height="628" alt="Screenshot 2026-01-15 101147" src="https://github.com/user-attachments/assets/f49f16a9-3b22-4ff0-9060-4a0f1a0a715b" />

### Test Analysis
## The testbench tests a sorting algorithm that compares two values in memory and swaps them if they are out of order, resulting in ascending sorted order.

✅ **Test Result:** PASSED

The simulation successfully demonstrates:
- **Load/Store Operations** — Data correctly transferred between registers and memory
- **ALU Operations** — Arithmetic and comparison operations executed properly
- **Branch Logic** — Conditional branching based on SLT comparison
- **Memory Sorting** — Values swapped correctly, resulting in ascending order (5, 10)

### Performance Metrics

- **Total Execution Time:** 145,000 ns
- **Instructions Executed:** 18 instructions (PC=0 to PC=17)
- **Clock Cycles:** 145 cycles (assuming 1000ns per cycle)
- **Average CPI:** ~8.1 cycles per instruction (single-cycle datapath)

---

