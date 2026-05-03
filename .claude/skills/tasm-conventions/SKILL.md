---
name: tasm-conventions
description: TASM 5.0 syntax conventions and 8086 real-mode bug patterns for the spelling-game project. Use this skill whenever writing, reviewing, or debugging .ASM files in this project, when uncertain whether a directive is TASM-compatible (vs MASM/NASM), when defining a PROC, when dealing with segment registers (DS/ES/CS), or when integrating modules across PUBLIC/EXTRN boundaries. Triggers on any assembly task in this repo — even simple ones — because TASM-specific conventions and the project's hard rules diverge from common LLM defaults toward NASM or MASM idioms.
---

# TASM 5.0 + 8086 Conventions

This project is **TASM 5.0** (Borland), `.MODEL SMALL`, real-mode 8086. Other dialects (NASM, MASM 6+, GAS) look superficially similar but miscompile or silently produce wrong code. Always apply this skill end-to-end when writing or reviewing assembly.

## File skeleton (every module except MAIN)

```asm
.MODEL SMALL
.DATA
    INCLUDE SHARED.INC
    ; private data here
    ; PUBLIC <symbol>      ← one line per exported data symbol

.CODE
    EXTRN <symbol>:PROC    ; or :BYTE, :WORD for data symbols

PROC_NAME PROC
    ; ...
    RET
PROC_NAME ENDP

END                        ; bare END, no entry label
```

`MAIN.ASM` differs: declares `.STACK 1024`, ends with `END MAIN_ENTRY` (or whatever the entry label is).

## TASM ≠ NASM ≠ MASM — quick translation

If you (or Claude) reach for any of these, stop:

| If you see this... | It's wrong. Use this. |
|---|---|
| `BITS 16` | (delete — `.MODEL SMALL` implies 16-bit) |
| `section .data` / `section .text` | `.DATA` / `.CODE` |
| `global SYM` | `PUBLIC SYM` |
| `extern SYM` | `EXTRN SYM:PROC` (or `:BYTE`, `:WORD`) |
| `org 0x100` | (not used — this is `.EXE`, not `.COM`) |
| `[BX+SI*2]` | 8086 has no scaled indexing; use `SHL AX, 1` then add |
| `db "string", 0` | `DB 'string', 0` (single quotes preferred) |
| Mixed-case `mov` / `Mov` | Project convention: UPPERCASE mnemonics, UPPERCASE labels |
| `db 0Ah` (without leading digit) | `DB 0Ah` is fine in TASM, but `0FFh` MUST start with a digit |

## PROC convention for this project

Every PROC starts with this header. No exceptions.

```asm
;-----------------------------------------------------------
; PROC_NAME — <one-line purpose>
; In:  AX = <what>, BX = <what>
; Out: CX = <what>             ; or "Out: (none)"
; Preserves: DX, SI, DI, BP    ; registers restored before RET
; Clobbers:  AX, BX, CX        ; registers NOT restored (incl. outputs)
;-----------------------------------------------------------
PROC_NAME PROC
    PUSH DX                   ; save each register listed in "Preserves"
    PUSH SI
    PUSH DI
    ; ... body ...
    POP DI                    ; restore in REVERSE order
    POP SI
    POP DX
    RET
PROC_NAME ENDP
```

**Verification rule:** `PUSH` count must equal `POP` count, and the order must mirror. A mismatched stack is the single most common silent crash. After writing any PROC, count them.

If a caller relies on a "Preserves" register and the body forgets to push/pop it, the bug surfaces three modules away in a way that looks unrelated. Always honor the contract.

## Segment register management

| Segment | Should point to | When |
|---|---|---|
| `CS` | code segment | always (auto) |
| `DS` | `@DATA` | from MAIN onward; restore after any routine that changes it |
| `ES` | varies | `A000h` for video, segment of buffer for file I/O, etc. |
| `SS` | stack segment | auto |

**Critical patterns:**

- **Setting DS at startup:** `MOV AX, @DATA / MOV DS, AX` — never `MOV DS, @DATA` directly (can't move immediate to seg reg).
- **String ops (`STOSB`, `MOVSB`, `LODSB`):** destination is `ES:DI`, source is `DS:SI`. If you set `ES=A000h` for a video write and forget to restore, the next `STOSB` to a local buffer corrupts video memory.
- **`INT 21h` file ops:** want `DS:DX` = pointer to filename or buffer. Setting `ES:DX` opens garbage.
- **Restoring DS:** if a routine sets `ES = A000h`, the convention is to set ES back to `@DATA` (or push/pop it) before returning, unless the contract says otherwise.

When reviewing a non-trivial routine, mentally tag each segment register at every line: `; DS=DATA, ES=A000h, SI=apple_sprite`.

## Bug pattern checklist (apply before declaring code done)

From spec Chapter 6.2 — walk this list mentally on every PROC:

1. ☐ DS set correctly at entry? (Inherited from MAIN; verify if you've touched it.)
2. ☐ All registers in "Preserves" actually pushed and popped, in mirror order?
3. ☐ ES correct for any string op or video write? Restored if changed?
4. ☐ Signed (`JG/JL`) vs unsigned (`JA/JB`) jump correct? Counts/sizes are unsigned.
5. ☐ Loop counter in CX, not clobbered by intermediate `CALL`s? Save CX if the callee might use it.
6. ☐ Sprite size math: `SPRITE_SIZE EQU 1024` (32×32). Global index = `DIFFICULTY*10 + CURRENT_WORD`.
7. ☐ `TIER_TABLE[DIFFICULTY*2]` (word-sized pointers) — `SHL AX, 1` before indexing.
8. ☐ Off-by-one on DI/SI advance? Strings are inclusive of null/`$` terminator.
9. ☐ `INT 10h, AX=0003h` (text mode restore) called before `INT 21h, AH=4Ch` exit?

## Common interrupts (most-used; full table in `@docs/SPEC.md` Appendix B)

- `INT 21h, AH=09h` — print `$`-terminated string at `DS:DX`
- `INT 21h, AH=4Ch` — exit with code in AL
- `INT 16h, AH=00h` — wait for key, returns AH=scancode, AL=ASCII
- `INT 16h, AH=01h` — non-blocking key check; ZF=1 means buffer empty
- `INT 10h, AX=0013h` — set Mode 13h (graphics)
- `INT 10h, AX=0003h` — restore text mode (call before exit, or terminal stays at 320×200)
- `INT 1Ah, AH=00h` — get tick count in CX:DX (18.2 Hz)

## When the assembler disagrees with you

TASM is ground truth. Its error messages reference line numbers and pass numbers (Pass 1 = symbol resolution, Pass 2 = code generation).

- Pass 1 errors: usually "symbol not defined" → check `EXTRN`/`PUBLIC` matching across modules
- Pass 2 errors: usually "operand types do not match" → wrong size (byte vs word) or wrong segment
- TLINK errors: unresolved external → a `PUBLIC` is missing somewhere, or a module wasn't added to the link line in `BUILD.BAT`

If a snippet looks suspicious and you're guessing, ask the user to paste the exact TASM/TLINK output verbatim before changing anything.
