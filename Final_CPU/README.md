# 8-bit Accumulator CPU (Gate-Level VHDL)

Final project for **CSE 450 (VLSI Lab)**, University of Asia Pacific.

| | |
|---|---|
| Name | Mahnoor Akter Esha |
| ID | 22201087 |
| Instruction set | **Set 7**: LDI, ADD, AND, XOR, SHR |
| Language | VHDL |
| Tools | Xilinx ISE 14.7, ISim |
| Target device (project setting) | Artix-7 `xc7a100t-3csg324` |

## 1. Overview

This is a small single-cycle 8-bit CPU. On every rising clock edge it reads one
12-bit instruction from a ROM, decodes it, does the calculation in an ALU, and
stores the result in the accumulator (ACC). The Z flag shows whether the new
result is zero.

The whole design is written at **gate level with single-bit ports**. There is no
`std_logic_vector`, no `case` statement and no `+` operator in the design files.
Every operation is built from AND, OR, XOR, NOT gates, full adders and D flip-flops,
so each part is visible in the RTL schematic.

```
   clk, reset
      |
      v
  +--------+  p0..p3   +--------+  i11..i8   +---------+  is_ldi/is_add/
  |   PC   |---------->|  ROM   |----------->| CONTROL |  is_and/is_xor/is_shr
  +--------+           +--------+            +---------+----------+
                           |                      | we           |
                           | i7..i0 (immediate)   |              v
                           +----------------------|---------> +--------+
                                                  |           |  ALU   |
                       a0..a7 (ACC value) ------------------->|        |
                                                  |           +--------+
                                                  |               | r0..r7
                                                  v               v
                                              +----------------------+
                                              |   ACC (8 FF) and Z   |--> q0..q7, z
                                              +----------------------+
                                                         |
                                                         +--> back to ALU (a0..a7)
```

<img width="2210" height="1195" alt="cpu_flow_chart" src="https://github.com/user-attachments/assets/66b2d1a5-ea8b-408b-84e9-1c4d0d6c8112" />


## 2. Instruction format and instruction set

Each instruction is 12 bits wide:

```
 11  10   9   8   7   6   5   4   3   2   1   0
+---+---+---+---+---+---+---+---+---+---+---+---+
|    opcode     |            operand            |
+---+---+---+---+---+---+---+---+---+---+---+---+
```

| Instruction | Opcode | Operation | Z flag |
|---|---|---|---|
| `LDI imm` | `0001` | `ACC <- imm` | updated |
| `ADD imm` | `0010` | `ACC <- ACC + imm` (8-bit, carry discarded) | updated |
| `AND imm` | `0100` | `ACC <- ACC AND imm` | updated |
| `XOR imm` | `0110` | `ACC <- ACC XOR imm` | updated |
| `SHR` | `1001` | `ACC <- ACC >> 1` (0 enters the MSB, operand ignored) | updated |
| any other opcode | | NOP: `PC <- PC + 1`, ACC and Z unchanged | unchanged |

**Z flag:** Z = 1 when the value written to ACC is `0x00`, otherwise Z = 0.

**Reset:** synchronous and active-high. On the next rising clock edge with `reset = 1`:
`PC = 0`, `ACC = 0`, `Z = 1`. Reset has priority over everything else.

LDI and ADD are mandatory for every student. AND, XOR and SHR are the three
instructions assigned for ID `22201087` (last digit 7, Set 7). Set 7 has no STA/LDR
and no JZ, so the design has no R register and the PC only counts up.

## 3. Program stored in the ROM

| Address | Instruction | ROM value | ACC after it | Z |
|---|---|---|---|---|
| 0 | LDI 0xF3 | `0x1F3` | `0xF3` | 0 |
| 1 | AND 0x3C | `0x43C` | `0x30` | 0 |
| 2 | XOR 0x11 | `0x611` | `0x21` | 0 |
| 3 | SHR | `0x900` | `0x10` | 0 |
| 4 | ADD 0x30 | `0x230` | `0x40` | 0 |
| 5 | XOR 0x40 | `0x640` | `0x00` | 1 |
| 6 to 15 | NOP | `0x000` | unchanged | unchanged |

## 4. Design details

All modules are in `cpu8_gate.vhd`.

### 4.1 Building blocks

| Entity | Function |
|---|---|
| `gc_and2` | AND gate: `y = a . b` |
| `gc_xor2` | XOR gate: `y = a xor b` |
| `gc_fa` | 1-bit full adder: `sum = a xor b xor cin`, `cout = a.b + cin.(a xor b)` |
| `gc_dff` | D flip-flop, synchronous reset to 0 |
| `gc_dffs` | D flip-flop, synchronous reset to 1 (used for Z) |

### 4.2 `gc_pc`: program counter

Four `gc_dff` flip-flops (`PC0` to `PC3`) and an incrementer made of gates. A bit
toggles when all the bits below it are 1:

```
n0 = not s0
n1 = s1 xor s0
n2 = s2 xor (s1 and s0)
n3 = s3 xor (s2 and s1 and s0)
```

`s0..s3` are the flip-flop outputs and `n0..n3` are the next PC value. The outputs
are `p0..p3`.

### 4.3 `gc_rom`: program ROM as Boolean equations

The ROM is not an array. The address is decoded with six 4-input AND gates and every
output bit is an OR of the addresses where that bit is 1:

```
a0 = ~p3 ~p2 ~p1 ~p0     a3 = ~p3 ~p2  p1  p0
a1 = ~p3 ~p2 ~p1  p0     a4 = ~p3  p2 ~p1 ~p0
a2 = ~p3 ~p2  p1 ~p0     a5 = ~p3  p2 ~p1  p0

i11 = a3              i5 = a0 + a1 + a4
i10 = a1 + a2 + a5    i4 = a0 + a1 + a2 + a4
i9  = a2 + a4 + a5    i3 = a1
i8  = a0 + a3         i2 = a1
i7  = a0              i1 = a0
i6  = a0 + a5         i0 = a0 + a2
```

Addresses 6 to 15 do not activate any `a` signal, so the output is `0x000` (NOP).

### 4.4 `gc_ctrl`: control unit

Decodes the opcode `i11..i8` with 4-input AND gates:

```
is_ldi = ~i11 ~i10 ~i9  i8      (0001)
is_add = ~i11 ~i10  i9 ~i8      (0010)
is_and = ~i11  i10 ~i9 ~i8      (0100)
is_xor = ~i11  i10  i9 ~i8      (0110)
is_shr =  i11 ~i10 ~i9  i8      (1001)
we     = is_ldi + is_add + is_and + is_xor + is_shr
```

`we` (write enable) is 1 only for the five real instructions. For a NOP it is 0, so
ACC and Z keep their old value.

| Opcode | Instruction | is_ldi | is_add | is_and | is_xor | is_shr | we |
|---|---|---|---|---|---|---|---|
| 0001 | LDI | 1 | 0 | 0 | 0 | 0 | 1 |
| 0010 | ADD | 0 | 1 | 0 | 0 | 0 | 1 |
| 0100 | AND | 0 | 0 | 1 | 0 | 0 | 1 |
| 0110 | XOR | 0 | 0 | 0 | 1 | 0 | 1 |
| 1001 | SHR | 0 | 0 | 0 | 0 | 1 | 1 |
| others | NOP | 0 | 0 | 0 | 0 | 0 | 0 |

### 4.5 `gc_alu_slice` and `gc_alu`: ALU

One slice handles one bit. It contains an AND gate (`AND_U`), an XOR gate (`XOR_U`) and
a full adder (`FA_U`), all working at the same time. An AND-OR selector then lets only
the selected result through:

```
y = is_ldi.imm + is_and.(a.imm) + is_xor.(a xor imm) + is_add.sum + is_shr.ashr
```

`a` is the ACC bit, `imm` is the operand bit and `ashr` is the next higher ACC bit
(used by SHR).

`gc_alu` joins eight slices `S0..S7`:

- **ADD:** the carry goes from slice to slice (`c1..c8`, ripple carry). `S0` gets
  `cin = 0`. The last carry `c8` is not used, so it is discarded.
- **SHR:** no gate is needed. It is only wiring: `r(k) = a(k+1)`, and `S7` gets
  `ashr = 0`, so a 0 enters the MSB.

### 4.6 `gc_acc`: accumulator and Z flag

- **ACC:** eight `gc_dff` flip-flops (`A0..A7`). Each input is a 2-to-1 mux made
  of gates: `m = we.d + (not we).s`. With `we = 1` the ALU result is loaded, with
  `we = 0` the flip-flop gets its own value back (hold).
- **Z flag:** `zr = NOR(d0..d7)` tells if the new result is zero. A second mux
  chooses between `zr` (when `we = 1`) and the old Z (when `we = 0`). Z is stored in
  `gc_dffs`, so reset sets it to 1.

### 4.7 `cpu8_gate`: top level

| Port | Direction | Meaning |
|---|---|---|
| `clk` | in | clock |
| `reset` | in | synchronous active-high reset |
| `q0..q7` | out | ACC |
| `z` | out | Z flag |
| `pc0..pc3` | out | program counter |

Connections: PC -> ROM -> (opcode to Control, immediate to ALU) -> ALU -> ACC, and the
ACC value goes back to the ALU.

## 5. One clock cycle, example: `AND 0x3C`

Before the clock edge: `PC = 0001`, `ACC = 0xF3`.

1. ROM address 1 is selected (`a1 = 1`), so the instruction is `0x43C`.
2. Opcode `0100` makes `is_and = 1` and `we = 1`. The immediate is `0x3C`.
3. Every ALU slice passes its AND result: `0xF3 AND 0x3C = 0x30`.
4. On the rising edge: `ACC = 0x30`, `Z = 0`, and PC goes from 1 to 2.

## 6. Simulation results

Clock period is 10 ns (rising edges at 5, 15, 25 ns ...). Outputs are checked 2 ns
after each edge.

| Cycle | Edge at | Instruction | ACC | Z | PC |
|---|---|---|---|---|---|
| 0 | 5 ns | RESET | `0x00` | 1 | 0 |
| 1 | 15 ns | LDI 0xF3 | `0xF3` | 0 | 1 |
| 2 | 25 ns | AND 0x3C | `0x30` | 0 | 2 |
| 3 | 35 ns | XOR 0x11 | `0x21` | 0 | 3 |
| 4 | 45 ns | SHR | `0x10` | 0 | 4 |
| 5 | 55 ns | ADD 0x30 | `0x40` | 0 | 5 |
| 6 | 65 ns | XOR 0x40 | `0x00` | 1 | 6 |
| 7 | 75 ns | NOP | `0x00` | 1 | 7 |

Before the first rising edge the outputs show `U` (uninitialized). This is expected,
because the reset is synchronous and only acts on a clock edge.

![CPU waveform](waveform_cpu.png)

![RTL schematic](rtl_schematic.png)

## 7. Testbenches

Every module has its own testbench, and one more tests the whole CPU. Each prints a
PASS or FAIL line for every check and `ALL TESTS PASSED` at the end.

| File | Tests | Checks |
|---|---|---|
| `gc_pc_tb.vhd` | Reset to 0, counting 1 to 15, wrap from 15 to 0, reset in the middle of counting | 22 |
| `gc_rom_tb.vhd` | All 16 addresses, `0x1F3 0x43C 0x611 0x900 0x230 0x640`, then `0x000` | 16 |
| `gc_ctrl_tb.vhd` | All 16 opcodes, the five instructions give `we = 1`, every other opcode is NOP | 16 |
| `gc_alu_tb.vhd` | LDI, ADD (including `0xFF + 1` and `200 + 100`), AND, XOR, SHR, nothing selected | 19 |
| `gc_acc_tb.vhd` | Reset, load, hold, Z for zero and non-zero, reset priority over load | 9 |
| `cpu8_gate_tb.vhd` | Whole Set 7 program, cycle 0 to 7 | 8 |

XOR is tested separately inside the ALU testbench with `0x30 xor 0x11`,
`0x40 xor 0x40`, `0xFF xor 0x00` and `0xAA xor 0x55`.

## 8. Design notes

- **Why gate level:** each AND, XOR, full adder and flip-flop shows up as its own block
  in the RTL schematic, which makes the design easy to explain.
- **Why the ROM uses equations:** it gives the same contents as a constant array,
  but built from gates.
- **ADD wraps around:** `0xFF + 1 = 0x00`. The carry-out is discarded.
- **No HALT:** after address 5 the ROM gives NOPs, so ACC and Z stay the same. When the
  PC reaches 15 it wraps to 0 and the program starts again.
- **Not needed for Set 7:** the R register (no STA/LDR) and a PC load (no JZ).

## 9. Files

```
Final_CPU/
 +-- README.md
 +-- cpu8_gate.vhd          design (all modules)
 +-- cpu8_gate_tb.vhd       CPU testbench
 +-- gc_pc_tb.vhd           PC testbench
 +-- gc_rom_tb.vhd          ROM testbench
 +-- gc_ctrl_tb.vhd         control unit testbench
 +-- gc_alu_tb.vhd          ALU testbench
 +-- gc_acc_tb.vhd          ACC/Z testbench
 +-- waveform_cpu.png       CPU waveform
 +-- rtl_schematic.png      RTL schematic
```

## 10. How to run

1. Open the project in ISE 14.7 and add `cpu8_gate.vhd` as a design source.
2. Add the testbench files as simulation sources.
3. Make sure the simulator is **ISim** (Project > Design Properties).
4. In the Simulation view, select a testbench and run **Simulate Behavioral Model**.
5. For the CPU testbench run for 90 ns. Add `clk`, `reset`, `pc0..pc3`, `q0..q7` and
   `z` to the waveform.
