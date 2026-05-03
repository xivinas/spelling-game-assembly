---
name: debug-asm
description: Debug an 8086 TASM assembly bug by tracing state and checking DOS/TASM assumptions.
context: fork
agent: debugger-8086
---

Debug this TASM 8086 issue thoroughly.

Required workflow:
1. Determine whether the file is `.COM` or `.EXE` style.
2. Identify the most likely failure point.
3. Trace registers, relevant flags, and memory around that point.
4. Check segment register setup and DOS interrupt usage.
5. Propose the minimal 8086-compatible fix.
6. Return a short root-cause summary and corrected code snippet.
