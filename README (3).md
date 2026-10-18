# 8-bit Accumulator CPU (Gate-Level VHDL)

CSE 450 (VLSI Lab) final project, University of Asia Pacific.

- **Name:** Mahnoor Akter Esha
- **ID:** 22201087
- **Instruction set:** Set 7 (LDI, ADD, AND, XOR, SHR)
- **Language and tool:** VHDL, Xilinx ISE 14.7, ISim

## What this project is

A small single-cycle 8-bit CPU. It reads a 12-bit instruction from a ROM, decodes it,
does the calculation in an ALU, and keeps the result in an accumulator (ACC).
One instruction finishes in one clock cycle.

The design is written at gate level with single-bit ports (no `std_logic_vector`),
so every gate and flip-flop can be seen in the RTL schematic.

## Instructions (Set 7)

| Instruction | Opcode | Operation |
|---|---|---|
| LDI imm | `0001` | `ACC <- imm` |
| ADD imm | `0010` | `ACC <- ACC + imm` (8-bit, carry discarded) |
| AND imm | `0100` | `ACC <- ACC AND imm` |
| XOR imm | `0110` | `ACC <- ACC XOR imm` |
| SHR | `1001` | `ACC <- ACC >> 1` (0 enters the MSB) |
| any other | | NOP (PC + 1, nothing else changes) |

Instruction format: `[11:8]` opcode, `[7:0]` operand. Z flag is updated by every instruction.
Reset is synchronous and active-high: `PC = 0`, `ACC = 0`, `Z = 1`.

## Program in the ROM

| Address | Instruction | ROM value |
|---|---|---|
| 0 | LDI 0xF3 | `0x1F3` |
| 1 | AND 0x3C | `0x43C` |
| 2 | XOR 0x11 | `0x611` |
| 3 | SHR | `0x900` |
| 4 | ADD 0x30 | `0x230` |
| 5 | XOR 0x40 | `0x640` |
| 6 to 15 | NOP | `0x000` |

Expected ACC after each clock: `F3, 30, 21, 10, 40, 00` (Z = 1 only after the last one).

## Modules (cpu8_gate.vhd)

| Entity | Job |
|---|---|
| `gc_pc` | 4-bit program counter (4 flip-flops + incrementer gates) |
| `gc_rom` | Program ROM written as Boolean equations |
| `gc_ctrl` | Control unit, decodes the opcode |
| `gc_alu_slice`, `gc_alu` | 1-bit ALU slice and the 8-bit ALU made from 8 slices |
| `gc_acc` | ACC (8 flip-flops) and Z flag |
| `cpu8_gate` | Top level, connects everything |

Small building blocks: `gc_and2`, `gc_xor2`, `gc_fa` (full adder), `gc_dff`, `gc_dffs`.

## Testbenches

| File | Tests |
|---|---|
| `gc_pc_tb.vhd` | PC |
| `gc_rom_tb.vhd` | ROM |
| `gc_ctrl_tb.vhd` | Control unit |
| `gc_alu_tb.vhd` | ALU (LDI, ADD, AND, XOR, SHR) |
| `gc_acc_tb.vhd` | ACC and Z |
| `cpu8_gate_tb.vhd` | Whole CPU running the Set 7 program |

Each testbench prints PASS or FAIL for every check and `ALL TESTS PASSED` at the end.

## How to run

1. Open the project in ISE 14.7.
2. Add `cpu8_gate.vhd` as a design source and the testbench files as simulation sources.
3. Set the simulator to ISim (Project > Design Properties).
4. Select a testbench in the Simulation view and run Simulate Behavioral Model.
