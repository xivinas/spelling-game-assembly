---
name: implement-asm
description: Implement a TASM 8086 assembly routine or program safely and clearly.
---

Implement the requested assembly task for TASM 8086.

Required workflow:
1. Decide whether the task should be `.COM` or `.EXE` style and say why.
2. List assumptions about input, output, registers, segments, and DOS services.
3. Write only 8086-compatible instructions.
4. Use TASM-friendly syntax and structure.
5. After writing the code, perform a static review for:
   - unsupported instructions/registers
   - bad addressing modes
   - missing segment initialization
   - incorrect interrupt usage
6. End with a brief walkthrough of control flow and register usage.

When relevant, mention assemble/link/run steps for TASM.
