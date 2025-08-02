##MIPS32 Pipelined Processor Design (5-Stage RTL, Verilog)
1. Project Overview
This project is a Verilog-based RTL design of a 5-stage pipelined MIPS32 processor, built to simulate real processor behavior at the cycle level. It supports 30+ MIPS instructions, includes 32 general-purpose registers, and a 1024-word unified memory. The processor uses dual-phase clocking (clk1 and clk2) to avoid race conditions. It is fully tested using Verilog testbenches and verified with GTKWave.

2. Pipeline Architecture
The processor uses the classic 5-stage MIPS pipeline:

IF – Instruction Fetch

ID – Instruction Decode and Register Fetch

EX – Execute and ALU operations

MEM – Memory Read/Write

WB – Write Back to Register File

To support data flow between stages, it uses inter-stage pipeline registers: IF_ID, ID_EX, EX_MEM, and MEM_WB.

3. Instruction and Component Support
The processor supports over 30 instructions, including:

Arithmetic: ADD, SUB, MUL, DIV, MOD, ADDI, SUBI

Logical: AND, OR, XOR, NOR

Comparison: SLT, SLTI

Shifts: SLLV, SRLV, SRA

Branching: BEQZ, BNEQZ

Memory: LW, SW

Control: HLT

Components used:

32×32-bit Register File

1024-word unified memory (shared by instructions and data)

Dual-phase clock to separate read and write operations safely

4. Hazard Detection and Handling
Data Hazards: Handled using basic forwarding and pipeline stalls to prevent incorrect execution.

Control Hazards: Managed with delayed branching, ensuring correct instruction flow after branches.
This allows the pipeline to execute multiple instructions efficiently while maintaining correct results.

5. Simulation and GTKWave Analysis
The design is tested with 50+ Verilog test cases covering various instruction types.

$display is used for cycle-by-cycle debugging of register/memory contents.

GTKWave is used to view the waveform (.vcd) files, allowing detailed inspection of instruction flow, control signals, memory access, and data hazards.

Example: ADD_THREE_NUMBERS_TB.v , Factorial_Number.v is the testbench.

Run simulation to generate ADD_THREE_NUMBERS.vcd, Factorial.vcd then open it in GTKWave for visual debugging.

👨‍💻 Author
Ankit Kumar
B.Tech in Electronics and Communication Engineering
Indian Institute of Information Technology Guwahati (IIITG)
