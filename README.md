## MIPS32 Pipelined Processor Design (5-Stage RTL, Verilog)
Cycle-accurate RTL implementation of a 5-stage pipelined MIPS32 processor written in Verilog. Designed with modularity, performance, and clarity, this processor supports 30+ MIPS32 instructions, includes 32 general-purpose registers, a 1024-word memory, and features two-phase clocking to mitigate race conditions. Fully testbench-driven and GTKWave verified.

📘 Overview
This project demonstrates a simplified but realistic MIPS32 processor core using a classical 5-stage pipeline:
IF → ID → EX → MEM → WB
Built from scratch in Verilog, the design includes hazard detection, partial forwarding, and branch control logic, mimicking real CPU behavior and instruction throughput.

Ideal for those learning CPU design, digital logic, or building foundations in computer architecture and VLSI.

🚀 Key Features
✅ Instruction Support (30+ Instructions)
Arithmetic: ADD, SUB, MUL, DIV, MOD, ADDI, SUBI

Logical: AND, OR, XOR, NOR

Comparison: SLT, SLTI

Shift: SLLV, SRLV, SRA

Branch: BEQZ, BNEQZ

Memory Access: LW, SW

Control Flow: HLT

⚙️ Pipeline Architecture
5 pipeline stages:

IF – Instruction Fetch

ID – Instruction Decode / Register Fetch

EX – Execute / Address Calculation

MEM – Memory Access

WB – Write Back

Inter-stage Registers:

IF_ID, ID_EX, EX_MEM, MEM_WB

Maintain instruction/data flow between pipeline stages

🧩 Processor Components
Register File: 32 registers (32-bit)

Memory: 1024-word unified memory (instruction + data)

Clocking: Dual-phase (clk1 and clk2) to prevent read-write conflicts

🛡 Hazard Handling
Data Hazards: Managed via basic forwarding and pipeline stalling

Control Hazards: Resolved through delayed branching logic

🧪 Simulation & Testing
✔️ 50+ test programs (e.g., arithmetic, memory, control flow)

✔️ Cycle-by-cycle debug via $display

✔️ Validated using GTKWave waveform viewer.
