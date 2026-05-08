---
name: openspec-apply-change
description: Implement an OpenSpec change after impact review has approved the plan.
---

# OpenSpec Apply Change

Use this skill when the user asks to implement, apply, continue, or finish an
approved OpenSpec change.

## Preconditions

- `openspec/changes/<change-name>/impact-review.md` exists.
- The impact review verdict is `Ready for implementation.`
- `openspec validate <change-name> --strict` passes.
- The tasks include regression tests for affected behavior.

If any precondition fails, stop and fix the OpenSpec artifacts first.

## Workflow

1. Read `proposal.md`, `design.md`, `tasks.md`, `impact-review.md`, and spec deltas.
2. Explain design, touched modules, downstream impact, and test strategy before editing.
3. Follow TDD: add or update failing tests first.
4. Implement the smallest change that satisfies the approved tasks.
5. Keep task status updated in `tasks.md`.
6. Run OpenSpec validation, lint, unit/component tests, and required E2E tests.
7. Add the AI change record required by the project rules.
8. Leave archive for a separate verification step unless the user explicitly asks to archive.

## Guardrails

- Do not expand scope beyond the approved OpenSpec change without user confirmation.
- Do not bypass stable shared call chains without documenting the risk and getting approval.
- Do not remove old behavior unless the spec explicitly requires it.
