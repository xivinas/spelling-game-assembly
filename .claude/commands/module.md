---
description: Start work on a single module per the spec. Pass the module name as argument (e.g. /module GFX). Forces plan-then-execute workflow.
---

You are starting work on the **$ARGUMENTS.ASM** module of the spelling game.

Follow this workflow precisely. Do not skip steps.

## Step 1 — Acknowledge plan mode

If the user is not already in Plan Mode, remind them once:

> "I'd recommend Plan Mode for this — hit `Shift+Tab` to cycle into it. I'll proceed in normal mode if you'd rather, but for a new module the planning step prevents me from coding the wrong thing."

Then continue regardless of their choice.

## Step 2 — Read context, in this order

1. `@CLAUDE.md` — project rules and toolchain
2. `@docs/SPEC.md` — find the chapter that owns `$ARGUMENTS.ASM`:
   - Chapter 3 if it's `MAIN`, `STATE`, or `DATA`
   - Chapter 4 if it's `GFX`, `INPUT`, `AUDIO`, or `FILEIO`
   - Chapter 5 if it's `SCR_INTRO`, `SCR_GAME`, or `SCR_END`
3. `@SHARED.INC` if it exists — current EQU constants and EXTRN declarations
4. `@src/$ARGUMENTS.ASM` if it exists — the current state (may be a stub from Day 1)
5. `@BUILD.BAT` — verify this module is in the link line

## Step 3 — Produce a plan

The plan must contain:

1. **Public procedures.** A table copied from the spec (do not invent contracts):

   | Procedure | In | Out | Preserves |
   |---|---|---|---|

2. **Required EXTRNs.** Which symbols from other modules does this need? Must match what those modules `PUBLIC`.

3. **Internal data layout.** Any `.DATA` this module owns privately (buffers, scratch space, lookup tables).

4. **Smoke test plan.** A standalone `tests/test_$ARGUMENTS.asm` containing a tiny `MAIN` that:
   - Initializes whatever this module needs (e.g., calls `GFX_INIT` if testing graphics)
   - Calls each public procedure with representative inputs
   - Provides a way to verify visually (renders sprite, plays sound, prints result, etc.)
   - Cleanly exits via `INT 21h, AH=4Ch`

5. **BUILD.BAT delta.** If this module or its smoke test isn't in `BUILD.BAT`, the exact lines to add.

6. **Verification steps.** What the user should do in DOSBox after the build:
   - Run `bin\TEST_$ARGUMENTS.EXE` (or whatever the smoke-test EXE is named)
   - What they should see/hear
   - What "wrong" looks like

## Step 4 — STOP

Wait for user approval. Do not write code yet.

If the plan is approved with edits (the user uses `Ctrl+G` to edit it directly), incorporate the edits.

## Step 5 — Implement

Apply the **tasm-conventions skill** rigorously. For every PROC:

- Header comment with `In:`, `Out:`, `Preserves:`, `Clobbers:`
- DS verified at entry if the routine touches `.DATA`
- Push/pop count for "Preserves" registers verified — count them
- Segment register state annotated at every non-trivial line
- Walk the bug-pattern checklist before declaring the PROC done

Implement the **smoke test first**, then the module proper. The smoke test exists to validate the module, so writing it first forces you to think about the contract from the consumer side.

## Step 6 — Hand off to the user

After the code is written:

1. Tell the user exactly what to run in DOSBox: `BUILD.BAT` then `bin\TEST_$ARGUMENTS.EXE`.
2. Tell them what they should see/hear (the verification steps from the plan).
3. Ask them to paste any TASM/TLINK errors verbatim, or describe visual/audio anomalies.

## Step 7 — On success, suggest a commit

Once the smoke test passes, propose:

```
git add src/$ARGUMENTS.ASM tests/test_$ARGUMENTS.asm BUILD.BAT
git commit -m "$ARGUMENTS: <one-line summary of what works>"
```

Then suggest the user `/clear` and move to the next module.
