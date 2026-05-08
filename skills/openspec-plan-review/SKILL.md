---
name: openspec-plan-review
description: Review an OpenSpec change before implementation and write the impact-review.md artifact.
---

# OpenSpec Plan Review

Use this skill immediately after an OpenSpec proposal is created and before any
implementation starts.

## Instruction

Review the OpenSpec change `<change-name>` before implementation.
Check whether it modifies existing capabilities, whether the spec delta could
regress old behavior, whether tasks include regression tests, and whether design
risks are covered. Do not implement yet.

## Inputs

- `openspec/project.md`
- `openspec/AGENTS.md` when present
- `openspec/specs/**/spec.md`
- `openspec/changes/<change-name>/proposal.md`
- `openspec/changes/<change-name>/design.md`
- `openspec/changes/<change-name>/tasks.md`
- `openspec/changes/<change-name>/specs/**/spec.md`

## Review Checks

1. Identify existing capabilities touched by the change.
2. Compare spec deltas against base specs and current behavior.
3. Check for compatibility, migration, rollout, and rollback risks.
4. Check whether tasks include unit, integration, E2E, and regression tests where relevant.
5. Check whether frontend changes include Playwright coverage for critical flows.
6. Check whether acceptance criteria are observable and testable.

## Output

Write or update `openspec/changes/<change-name>/impact-review.md`:

```markdown
# Impact Review

## Existing Capabilities Touched

## Potential Regressions

## Missing or Weak Tests

## Design Risks

## Required Plan Revisions

## Verdict

Ready for implementation.
```

If any blocking issue remains, use this verdict instead:

```markdown
Needs revision before implementation.
```

Do not implement yet.
