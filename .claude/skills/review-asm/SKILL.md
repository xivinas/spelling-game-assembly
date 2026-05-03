---
name: review-asm
description: Review TASM 8086 assembly for correctness, compatibility, and assignment safety.
context: fork
agent: code-reviewer-8086
---

Review the selected assembly code as strict 8086/TASM code.

Check specifically:
- 8086 compatibility
- TASM syntax
- DOS interrupt assumptions
- segment initialization
- register preservation
- string/input buffer correctness
- arithmetic and loop edge cases

Return concise findings with minimal fixes.
