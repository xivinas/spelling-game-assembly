---
description: Diagnose a TASM or TLINK build error. Paste the full error output after the command.
---

The user is reporting a build failure from DOSBox. Their pasted output follows below.

Diagnose it methodically:

## Step 1 — Classify

Identify the error class:

- **TASM Pass 1 error** (symbol resolution): "Undefined symbol", "Forward reference"
- **TASM Pass 2 error** (code generation): "Operand types do not match", "Argument needs type override", "Relative jump out of range"
- **TLINK error**: "Unresolved external", "Symbol defined in multiple modules", "No stack"

State which class it is in one line.

## Step 2 — Localize

TASM errors include filename, line number, and pass number. Open the cited file:

- Read the cited line ±10 lines of context
- For "Undefined symbol", grep across `src/*.ASM` for any `PUBLIC` of that symbol
- For "Operand types do not match", check whether the issue is byte-vs-word size, or seg-reg vs general reg
- For TLINK "Unresolved external", check whether the defining module is in `BUILD.BAT`'s link line

## Step 3 — Apply the tasm-conventions skill

Run through the most likely causes in order:

1. **NASM-ism leaked in** — `BITS 16`, `section .data`, `global`, `extern` (lowercase), `org`, etc.
2. **Missing PROC/ENDP pair** — every `PROC` needs a matching `ENDP` with the same name
3. **Wrong segment directive** — `.DATA` directives placed inside `.CODE` or vice versa
4. **`MOV DS, immediate`** — illegal; must go through a general register
5. **Missing `EXTRN`** — symbol defined in another module but not declared `EXTRN` here
6. **`PUBLIC` without `EXTRN` (or vice versa)** — declare on both sides
7. **Module missing from BUILD.BAT** — `tlink` doesn't see it, so its `PUBLIC`s look unresolved
8. **Operand size ambiguity** — `MOV [BX], 5` is ambiguous; needs `MOV BYTE PTR [BX], 5` or `MOV WORD PTR [BX], 5`
9. **Numeric literal without leading digit** — `0FFh` not `FFh`

## Step 4 — Propose ONE concrete fix

Provide:

- The exact file and line to change
- Before/after using a clear diff format
- A one-sentence explanation of why this fixes it

Do not shotgun multiple speculative changes. If the cause is genuinely ambiguous, ask **one** targeted clarifying question before guessing — for example:

- "Is line 47 of GFX.ASM inside a PROC, or is it in the `.DATA` section?"
- "Does `BUILD.BAT` currently reference all 10 modules in the tlink line? Paste the line if unsure."

Never guess silently. The user only sees results when they go back to DOSBox, so a wrong guess costs them a full edit-build-run cycle.

---

User's pasted error output:

$ARGUMENTS
