# RISC-V Assembly Programming Challenge — MEDS Module 3

## Overview
This repository is my submission for the MEDS Lab Module 3 Grand Assignment. It
demonstrates hands-on fluency with the RV32I base instruction set: array processing
functions that follow the calling convention, a recursive memoized Fibonacci
implementation with properly managed stack frames, and a runtime instruction-field
decoder that mirrors the manual bit-level encoding work done by hand. Everything here
was written and verified in the Venus simulator (https://venus.cs61c.org/).

## Repository Structure
```
riscv-assembly-challenge/
├── README.md                    # This file — overview and instructions
├── .gitignore                   # Ignores build artifacts, OS/editor junk
├── part1_array_ops.s            # Part 1: array processing functions
├── part2_recursion.s            # Part 2: memoized recursive Fibonacci
├── part3_encoding.s             # Part 3: instruction field decoder
├── screenshots/                 # Venus output proving each program runs correctly
└── docs/
├── ENCODING_WORKSHEET.md    # Hand-worked instruction encodings
├── PRIVILEGED_SUMMARY.md    # Self-study: privileged architecture
└── EXTENSION_SUMMARY.md     # Self-study: one RISC-V extension
```
Each `.s` file is self-contained and can be assembled and run independently in Venus —
none of them depend on each other.

## How to Run Each Program
1. Open [Venus](https://venus.cs61c.org/) in a browser — no installation required, it
   runs entirely client-side.
2. Copy the full contents of the `.s` file you want to run into the Editor tab.
3. Click **Assemble & Simulate** to switch to the Simulator view.
4. Use **Step** to execute one instruction at a time and watch the Registers/Memory
   panels update, or **Run** to execute to completion and see console output directly.
5. Compare the printed output against what's described below for each part.

## Part 1: Array Processing (`part1_array_ops.s`)
Defines a `.data` array of 12 signed integers (`-10, 20, -30, 40, -50, 60, 10, -20, 30,
-40, 50, -65`), deliberately mixing positive and negative values so every function has
something meaningful to work on. Implements four functions, each taking `a0 = array
pointer` and `a1 = size` (12, via the `.equ SIZE, 12` constant) and returning its
result in `a0`:
- `sum_array` — sums every element (loops with `t0` as accumulator, `t1` as index)
- `find_min` — returns the smallest (signed) value, using `bge` to skip non-smaller
  elements
- `find_max` — returns the largest (signed) value, using `ble` to skip non-larger
  elements
- `count_neg` — counts how many elements are negative, using `bge t2, zero` to skip
  non-negative elements

`main` calls each function in turn and prints its result with a label using ecall 4
(print string) followed by ecall 1 (print int) — e.g. `Sum: 5` then a newline before
the next label. Each function saves and restores `s0` (the only callee-saved register
it uses, as the array pointer) around its loop, so the caller's register state survives
the call.

**Expected output**, given the array above:
- `Sum:` the total of all 12 elements
- `Minimum Number:` the smallest value in the array
- `Maximum Number:` the largest value in the array
- `Negative Count:` how many elements are negative

## Part 2: Recursive Algorithm (`part2_recursion.s`)
Implements **memoized recursive Fibonacci** (Option C). A 50-word `.data` array
(`cache`) is initialized to `-1` (a sentinel meaning "not yet computed") by
`initilize_array` before `fib` is ever called. `fib(n)`:
- Checks the two base cases (`n == 0` and `n == 1`) first, writing the answer directly
  into `cache[0]` / `cache[1]`.
- Otherwise, computes the array address for `cache[n]` and checks whether it's already
  been computed (`!= -1`); if so, returns the cached value immediately (`cache_hit`).
- Otherwise, recursively computes `fib(n-1)` and `fib(n-2)`, stores their sum into
  `cache[n]`, and returns it.

This exercises genuine recursion — each call issues an actual `call fib` and builds a
new 32-byte stack frame — with `s0` holding `n` and `s1`–`s6` holding cache
pointer/index/address/intermediate values, all callee-saved so they correctly survive
both recursive calls. `ra` and all seven saved registers are pushed in the prologue and
popped in the epilogue, keeping the 16-byte stack alignment required by the ABI.

`main` calls `initilize_array`, then `fib(20)`, and prints the result via ecall 1.

**Expected output:** `fib(20) = 6765`

## Part 3: Instruction Encoding (`part3_encoding.s`)
Loads the six hex values hand-encoded in `docs/ENCODING_WORKSHEET.md` as `.word` data —
one instruction from each RV32I format (R, I, S, B, U, J):
inst_1 = 0x403100B3   # R-type (sub x1, x2, x3)
inst_2 = 0x0FF36293   # I-type (ori x5, x6, 0xFF)
inst_3 = 0x00742423   # S-type (sw x7, 8(x8))
inst_4 = 0x00208863   # B-type (beq x1, x2, +16)
inst_5 = 0x123454B7   # U-type (lui x9, 0x12345)
inst_6 = 0x1000056F   # J-type (jal x10, 0x100)
For each, `decode_instr` extracts and prints the full instruction, then its `opcode`
field (via `andi t1, t0, 0x7F`), and — skipping fields that don't apply to that
format — its `rd`, `rs1`, and `funct3` fields, using shift-and-mask operations. S-type
and B-type instructions have no `rd` field, so those are skipped via an opcode check
before the `rd` extraction; U-type and J-type instructions have neither `rs1` nor
`funct3`, so those are skipped similarly.

**Expected output** (one block per instruction, printed field values matching what was
hand-computed in the encoding worksheet):
Instruction: 1077937331
opcode: 35
rd: 1
rs1: 2
func3: 0
...
(repeats for all six instructions, each followed by a newline)

## Self-Study Deliverables
- **`docs/PRIVILEGED_SUMMARY.md`** — covers the three RISC-V privilege levels, the key
  CSRs involved in trap handling, and the step-by-step trap handling flow, based on
  reading Sections 3.1–3.4 of the RISC-V Privileged Specification.
- **`docs/EXTENSION_SUMMARY.md`** — a summary of the C (Compressed Instructions)
  extension, covering what it adds to the base ISA, its key instructions, and why it
  matters in real systems.

