# Instruction Encoding Worksheet


## General Method
For every instruction:
1. Identify the format (R/I/S/B/U/J) from the opcode.
2. Look up the fixed opcode and, where applicable, funct3/funct7 values for that
   specific instruction.
3. Convert each operand (register number, immediate) to its binary field.
4. Immediates in S, B, and J formats are **not** stored as a simple contiguous binary
   number — they're split across non-adjacent bit positions to keep the format
   layouts consistent across instruction types. This is the part that's easy to get
   wrong, so each B/S/J example below spells out the split explicitly.
5. Concatenate all fields in the format's defined bit order, then convert the full
   32-bit binary string to hex.

---
## Examples:
### 1. `sub x1, x2, x3` — R-type
**Format:** `funct7[31:25] | rs2[24:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0]`

- opcode = `0110011`, funct3 = `000`, funct7 = `0100000`
- rd = x1 `->` `00001`, rs1 = x2 `->` `00010`, rs2 = x3 `->` `00011`

Concatenating in order (funct7, rs2, rs1, funct3, rd, opcode):
0100000 00011 00010 000 00001 0110011
**Hex: `0x403101B3`**

---

### 2. `ori x5, x6, 0xFF` — I-type
**Format:** `imm[31:20] | rs1[19:15] | funct3[14:12] | rd[11:7] | opcode[6:0]`

- opcode = `0010011`, funct3 for `ori` = `110`
- imm = 0xFF = `000011111111` (12 bits)
- rd = x5 `->` `00101`, rs1 = x6 `->` `00110`

Concatenating:
000011111111 00110 110 00101 0010011
**Hex: `0x0FF36293`**

---

### 3. `sw x7, 8(x8)` — S-type
**Format:** `imm[11:5] | rs2[24:20] | rs1[19:15] | funct3[14:12] | imm[4:0] | opcode[6:0]`

- opcode = `0100011`, funct3 = `010`
- imm = 8 `->` binary `000000001000` `->` imm[11:5] = `0000000`, imm[4:0] = `01000`
- rs1 = x8 `->` `01000`, rs2 = x7 `->` `00111`

Concatenating:
0000000 00111 01000 010 01000 0100011
**Hex: `0x00742423`**

---

### 4. `beq x1, x2, +16` — B-type
**Format:** `imm[12] | imm[10:5] | rs2[24:20] | rs1[19:15] | funct3[14:12] | imm[4:1] | imm[11] | opcode[6:0]`

- opcode = `1100011`, funct3 = `000`
- imm[12]=`0`, imm[10:5]=`000000`, imm[4:1]=`1000`, imm[11]=`1`
- rs1 = x1 → `00001`, rs2 = x2 → `00010`

0 000000 00010 00001 000 1000 1 1100011

**Hex: `0x00208863`**

---

### 5. `lui x9, 0x12345` — U-type
**Format:** `imm[31:12] | rd[11:7] | opcode[6:0]`

- opcode = `0110111`
- imm = `00010010001101000101`
- rd = x9 → `01001`

00010010001101000101 01001 0110111

**Hex: `0x123454B7`**

---

### 6. `jal x10, 0x100` — J-type
**Format:** `imm[20] | imm[10:1] | imm[11] | imm[19:12] | rd[11:7] | opcode[6:0]`

- rd = x10 → `01010`
- opcode = `1101111`

| Field | Value |
|---|---|
| imm[20] | `0` |
| imm[19:12] | `00000000` |
| imm[11] | `0` |
| imm[10:1] | `0100000000` |

0 0100000000 0 00000000 01010 1101111

**Hex: `0x200005EF`**

