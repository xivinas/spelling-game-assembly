# Spelling Game — 8086 Assembly

Educational toddler spelling game for Intel 8086 real mode via DOSBox.
Full design spec: `@docs/SPEC.md` (chapters are authoritative — reference by section number).

## Toolchain — DO NOT DEVIATE

- **Assembler:** TASM 5.0 (Borland Turbo Assembler) — **NOT MASM, NOT NASM**
- **Linker:** TLINK
- **Runtime:** DOSBox (16-bit real mode, 8086)
- **Memory model:** `.MODEL SMALL` (one 64KB code seg + one 64KB data seg)
- **Graphics:** VGA Mode 13h (320×200, 256 colors, framebuffer at A000h)
- **Audio:** PC speaker via ports 42h/43h/61h (NOT Sound Blaster)

If a snippet uses `BITS 16`, `section .data`, `global`, or `extern` — it's NASM, it's wrong. TASM uses `.MODEL SMALL`, `.DATA`, `.CODE`, `PUBLIC`, `EXTRN`.

## Project layout

```
src/      — module .ASM source
tests/    — per-module standalone smoke-test mains
build/    — .OBJ output (gitignored)
bin/      — final .EXE (gitignored)
docs/     — full design spec, study notes
BUILD.BAT — TASM + TLINK pipeline (runs inside DOSBox)
```

Build runs **inside DOSBox**, not on the host. Workflow: edit on host → switch to DOSBox → `BUILD.BAT` → `bin\SPELL.EXE` → iterate.

**Claude Code cannot run TASM or DOSBox.** When the user pastes build errors, treat them as ground truth — don't guess at what the assembler "probably" meant.

## Hard rules (from spec Chapter 6.2 bug list)

1. **Set DS at every module entry.** Always `MOV AX, @DATA / MOV DS, AX` before touching `.DATA`.
2. **Preserve registers across calls.** Every PROC has a header comment listing `Preserves:` — push at entry, pop at exit, in mirrored order. Anything declared as "output" is the only register allowed to change.
3. **Track ES carefully.** Sprite routines need `ES = A000h`. File routines (INT 21h) need `DS:DX = filename`. Annotate which segment register holds what at every non-trivial juncture.
4. **Signed vs unsigned jumps.** `JG/JL` are signed; `JA/JB` are unsigned. Counts/sizes/indices are unsigned.
5. **ASCII uppercase only** for character comparisons. Toddler input is force-uppered.
6. **Sprite math.** `SPRITE_SIZE EQU 1024` (32×32). Global sprite index = `DIFFICULTY * 10 + CURRENT_WORD`. Don't confuse tier-local with global.
7. **TIER_TABLE indexing requires `SHL AX, 1`** (entries are word-sized pointers). Skipping the shift gives the wrong tier — silent bug.

## Module ownership

| File            | Owner           | Public exports                                                              |
| --------------- | --------------- | --------------------------------------------------------------------------- |
| `MAIN.ASM`      | Dev 1           | (entry point)                                                               |
| `STATE.ASM`     | Dev 1           | `GAME_TICK`                                                                 |
| `DATA.ASM`      | spriter + Dev 1 | `EASY_WORDS`, `MED_WORDS`, `HARD_WORDS`, `SPRITE_TABLE`, `SOUND_TABLE`      |
| `GFX.ASM`       | Dev 2           | `GFX_INIT`, `GFX_CLEAR`, `GFX_DRAW_SPRITE`, `GFX_DRAW_TEXT`, `GFX_SHUTDOWN` |
| `INPUT.ASM`     | Dev 2           | `INP_WAIT_KEY`, `INP_CHECK_KEY`, `INP_READ_STRING`                          |
| `AUDIO.ASM`     | Dev 3           | `SND_PLAY_PATTERN`, `SND_SILENCE`                                           |
| `FILEIO.ASM`    | Dev 3           | `FILE_LOAD_SCORES`, `FILE_SAVE_SCORES`                                      |
| `SCR_INTRO.ASM` | Dev 1           | `SCR_TITLE_RUN`, `SCR_NAME_RUN`, `SCR_DIFF_RUN`, `SCR_INSTR_RUN`            |
| `SCR_GAME.ASM`  | Dev 1           | `SCR_ROUND_RUN`, `SCR_JUDGE_RUN`                                            |
| `SCR_END.ASM`   | Dev 1           | `SCR_END_RUN`                                                               |
| `SHARED.INC`    | Dev 1           | EQU constants, EXTRN declarations                                           |

Detailed per-module specs in `@docs/SPEC.md` chapters 3–5.

## Workflow expectations

- **Plan Mode for every module.** Read the relevant spec chapter, propose a plan, get approval, then code. Use `/module <NAME>` to start.
- **Smoke test before integration.** Each module has a standalone test main in `tests/` that exercises only its public procs. Build & run that before declaring the module done.
- **One module per Claude Code session.** Run `/clear` between unrelated modules — context bloat degrades instruction-following.
- **Update BUILD.BAT only when adding a new .ASM file.** No silent changes to the link line.
- **Commit after each smoke test passes.** Small commits make Day 5 integration tractable.
- If debugging, **first explain the likely fault(s)** in terms of registers, memory, flags, or DOS API usage.
- After writing code, do a static review for 8086/TASM compatibility.
- End with a compact explanation of the register/data flow.

## Review checklist

Always verify:

1. 8086 instruction compatibility.
2. Correct segment initialization where needed.
3. Correct DOS interrupt usage.
4. Register preservation assumptions.
5. Edge cases for signed/unsigned arithmetic.
6. Loop termination and off-by-one errors.
7. String terminators and buffer lengths.
8. Whether the solution matches TASM syntax rather than MASM/NASM-specific syntax.

## NOT in scope (push back if asked)

- Sound Blaster / DAC audio
- More than 30 sprites total (10 per tier × 3 tiers)
- 32-bit / protected mode / DPMI
- Any feature not in the spec until Day 5+ — log "wouldn't it be cool" ideas to `POLISH_IDEAS.txt` and revisit only after MVP integration is green.

## Status (update this file)

- [ ] Day 1 — repo skeleton + hello-world MAIN.ASM builds and prints HELLO
- [ ] Day 2 — GFX standalone (1 sprite from each tier renders)
- [ ] Day 3 — AUDIO standalone (one pattern plays in DOSBox)
- [ ] Day 4 — INPUT + FILEIO standalone (name read, scores persist across runs)
- [ ] Day 5 — full integration: title → name → diff → instr → round → end (playable)
- [ ] Day 6 — bug-fix pass on Day 5 findings; all 3 tiers complete without crash
- [ ] Day 7 — polish + demo prep
