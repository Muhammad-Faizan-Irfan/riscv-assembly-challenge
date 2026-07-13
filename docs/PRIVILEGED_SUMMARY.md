# RISC-V Privileged Architecture — Summary

## Why Privilege Levels Exist
A processor that only ran user code with unrestricted hardware access would have no way
to protect itself, other programs, or the operating system from a buggy or malicious
program. Privilege levels solve this by creating a hierarchy of trust: code running at
a lower privilege level cannot directly touch resources reserved for a higher one (e.g.
it cannot rewrite page tables, disable interrupts globally, or access arbitrary physical
memory). Instead, it must ask a higher-privileged layer to do it on its behalf, via a
trap. This is the same idea as an OS running in "kernel mode" while applications run in
"user mode" on x86, RISC-V just formalizes it with clean, well-defined levels.

## The Three Privilege Levels
- **Machine Mode (M-mode):** The highest and only *mandatory* privilege level: every
  RISC-V implementation has it. Code here has completely unrestricted access to all
  hardware: memory, CSRs, interrupts, everything. This is where firmware and the
  bootloader run, before anything resembling an OS exists. Think of it as the
  "root of trust" for the whole chip.
- **Supervisor Mode (S-mode):** Optional, only implementations that intend to run a
  full operating system (like Linux) include it. The OS kernel runs here. S-mode can
  manage virtual memory (page tables), handle system calls from user programs, and
  service most interrupts, but it still cannot touch certain machine-level state that
  M-mode reserves for itself.
- **User Mode (U-mode):** Optional, but present alongside S-mode in any general-purpose
  system. Ordinary applications run here with the most restricted access: no direct
  hardware control, no arbitrary memory access outside what the OS has mapped for it.
  If a U-mode program tries something it isn't allowed to do (e.g. dereference an
  invalid pointer, execute a privileged instruction), the hardware raises a trap and
  hands control back to a higher level.


## Key Control and Status Registers (CSRs)
CSRs are special registers (separate from the 32 general-purpose registers) that the
hardware uses to track processor state and communicate about traps. The important ones
for understanding trap handling are:

- **mstatus:** A bitfield register holding global state, most importantly, whether
  interrupts are currently enabled, and what privilege mode the processor was in before
  the current trap. The trap handler reads this to know how to safely return control.
- **mtvec (Machine Trap Vector):** Holds the address the processor jumps to whenever a
  trap occurs. Think of it as "the phone number the CPU calls when something goes
  wrong." Firmware sets this once, early in boot, to point at the trap handler.
- **mepc (Machine Exception PC):** When a trap fires, hardware automatically saves the
  PC of the instruction that caused it (or the next instruction to execute, for
  interrupts) into mepc. This is what makes it possible to resume execution afterward
  as if nothing happened.
- **mcause:** A code identifying *why* the trap happened, was it an illegal
  instruction, a page fault, a timer interrupt, an explicit ECALL? The handler branches
  on this value to decide what to do.
- **mtval:** Carries extra diagnostic information depending on the trap type for
  example, the faulting address for a memory access violation. Not always meaningful
  (e.g. it's often 0 for a plain ECALL).

## Trap Handling Flow, Step by Step
1. **Something trap-worthy happens.** This could be an *exception* (something the
   currently executing instruction caused, like an illegal opcode or an ECALL), or an
   *interrupt* (something external, like a timer or device signaling the CPU
   asynchronously).
2. **Hardware reacts automatically, with no software involvement yet:** it copies the
   current PC into `mepc`, writes a code describing what happened into `mcause`, updates
   `mstatus` to record the previous privilege mode, and then sets the PC to the address
   stored in `mtvec`.
3. **The trap handler (written in M-mode, typically part of firmware or the OS) now
   runs.** It reads `mcause` to figure out what kind of trap this was, and reads `mtval`
   if it needs more detail. It does whatever handling is appropriate — this might mean
   servicing a system call, emulating an unsupported instruction, or terminating a
   misbehaving program.
4. **The handler executes `MRET`** (machine return). This restores the PC from `mepc`
   and restores the privilege mode from `mstatus`, so execution resumes exactly where
   it left off (or wherever the handler decided execution should continue, such as the
   instruction after a syscall).

## Why This Matters
This mechanism is the foundation that makes multitasking operating systems possible on
RISC-V. It's how a system call from a user program safely reaches the kernel, how a
timer interrupt lets the OS preempt a running process to schedule another one, and how
the OS can catch and terminate a program that tries to do something illegal all
without any single piece of user code ever being able to seize control of the machine.
