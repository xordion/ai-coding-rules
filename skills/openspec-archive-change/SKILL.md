---
name: openspec-archive-change
description: Archive a completed OpenSpec change after implementation and verification.
---

# OpenSpec Archive Change

Use this skill when the user asks to archive, finalize, or close a completed
OpenSpec change.

## Preconditions

- All implementation tasks in `openspec/changes/<change-name>/tasks.md` are complete.
- The final verification gate has passed.
- Base specs reflect the implemented behavior.
- The AI change record has been updated.

## Workflow

1. Read the change proposal, design, tasks, impact review, and spec deltas.
2. Run `openspec validate <change-name> --strict`.
3. Confirm lint, tests, and required Playwright checks passed.
4. Run the OpenSpec archive command when available:

```bash
openspec archive <change-name> --yes
```

5. Run `openspec validate --strict` after archive.
6. Summarize the archived capability and verification results.

## Guardrails

- Do not archive changes with incomplete tasks.
- Do not archive if verification failed or was skipped without user approval.
- Do not silently drop spec deltas; base specs must preserve accepted behavior.
