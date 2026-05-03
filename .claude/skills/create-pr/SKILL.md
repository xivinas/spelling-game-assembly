# Create PR Skill

---
name: create-pr
description: Creates a pull request for the current branch by summarizing changes, validating branch state, drafting a clear PR title/body, and using the GitHub CLI when the user wants to open a PR.
---

# Create Pull Request

Use this skill when the user wants to create a pull request, draft a PR, summarize a branch for review, or prepare a PR title/body from local changes and commit history.

## Goal

Produce a high-quality pull request with:

- a precise title
- a useful summary of the problem and solution
- testing notes
- risks or reviewer attention points
- file-level or behavior-level context when needed

If GitHub CLI is available and the user wants the PR opened, create it with `gh pr create`. Claude Code’s documented PR workflow supports asking Claude directly to create a PR, and PRs created with `gh pr create` can be linked back to the session. [web:2][web:73]

## Required workflow

1. Confirm the current branch and compare it against the likely base branch.
2. Inspect the diff and recent commits before drafting anything.
3. Summarize the change in plain language.
4. Identify:
   - what changed
   - why it changed
   - how it was validated
   - any risks, limitations, or follow-ups
5. Draft a PR title and PR body.
6. If the user explicitly wants the PR opened, use GitHub CLI to create it.
7. Report the final PR URL if creation succeeds.

## Branch and diff checks

Before drafting the PR:

- Run `git branch --show-current` to confirm the feature branch.
- Infer the base branch from repo conventions, usually `main` or `master`, unless the user specifies otherwise.
- Run a diff summary such as:
  - `git status --short`
  - `git log --oneline --decorate -n 10`
  - `git diff --stat <base>...HEAD`
  - `git diff --name-only <base>...HEAD`
- If there are uncommitted changes, warn the user that PR content may not match the pushed branch.
- If the branch has not been pushed, say so before attempting PR creation.

## PR title rules

Write a concise, review-friendly title:

- Use imperative style.
- Lead with the actual change.
- Prefer specificity over generic words like “update” or “fix stuff”.
- If the repo uses conventional commits, match that style.

Good examples:

- `fix: correct 8086 buffered input handling in menu flow`
- `refactor: simplify TASM string printing procedure`
- `feat: add array search routine for 8086 assignment`

Bad examples:

- `update code`
- `changes`
- `fixed bug`

## PR body template

Use this structure unless the repository already has a required PR template.

### Summary

Briefly explain the problem and the change.

### What changed

- Bullet the main implementation changes.
- Group related edits together.

### Validation

List what was checked:

- tests run
- manual verification
- builds/linters
- for assembly projects, note manual DOSBox/TASM checks if applicable

### Risks / reviewer focus

Call out:

- edge cases
- compatibility assumptions
- known limitations
- areas that deserve careful review

### Optional sections

Include these only when useful:

- Screenshots
- Migration notes
- Follow-ups
- Breaking changes

## Assembly-specific guidance

For 8086/TASM repositories, include:

- whether the code targets `.COM` or `.EXE`
- which DOS interrupts are involved
- register preservation assumptions
- any known edge cases around buffers, string terminators, segment setup, flags, overflow, or loop bounds
- how the code was manually tested, for example with TASM/TLINK/DOSBox or another emulator

Example assembly validation notes:

- Assembled with TASM successfully
- Linked with TLINK successfully
- Manually tested buffered keyboard input via INT 21h AH=0Ah
- Verified `$`-terminated output path for AH=09h
- Checked DS initialization and loop termination

## Creation behavior

If the user says “draft only”, do not run `gh pr create`; just output the proposed title/body.

If the user says “create the PR” or equivalent:

1. Check that `gh` is installed.
2. Check that the branch is pushed or can be pushed.
3. Create the PR with:
   - `gh pr create --title "<title>" --body-file <tempfile>`
4. Return the PR URL.

If `gh` is missing or auth fails:

- return the finished PR title/body
- explain the exact command the user can run manually

## Output format

Always return:

1. Proposed PR title
2. Proposed PR body
3. Branch/base branch used
4. Validation summary
5. PR URL if created

## Quality bar

The PR should let a reviewer understand the change quickly without rereading the whole diff. Avoid vague summaries, inflated claims, and copying raw commit messages verbatim.
