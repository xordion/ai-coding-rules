---
name: openspec-propose
description: Create a complete OpenSpec change proposal and trigger plan review preparation before implementation.
---

# OpenSpec Propose

Use this skill when the user asks to propose, plan, or start a feature using
OpenSpec.

## Workflow

1. Pick a concise kebab-case change name.
2. Read `openspec/project.md`, `openspec/AGENTS.md`, and related base specs.
3. Create `openspec/changes/<change-name>/proposal.md`.
4. Create `openspec/changes/<change-name>/design.md`.
5. Create `openspec/changes/<change-name>/tasks.md`.
6. Create spec deltas under `openspec/changes/<change-name>/specs/<capability>/spec.md`.
7. Create an initial `openspec/changes/<change-name>/impact-review.md`.
8. Run `openspec validate <change-name> --strict` when available.
9. Tell the user that the next step is plan review.

## Required Proposal Content

- Problem and user value
- Scope and non-goals
- Acceptance criteria
- Compatibility notes
- Rollback strategy

## Required Design Content

- Existing behavior
- Proposed behavior
- Alternatives considered
- Risks and mitigations
- Data, API, UX, security, and performance impact when relevant

## Required Tasks Content

- Review and regression-test tasks before implementation tasks
- Small implementation tasks in dependency order
- Verification tasks including OpenSpec validation, lint, tests, and manual checks
- Archive task

## Impact Review Stub

The initial `impact-review.md` must make it obvious that implementation has not
started yet. Use this structure:

```markdown
# Impact Review

## Existing Capabilities Touched

## Regression Risks

## Test Coverage Required

## Design Risks

## Verdict

Needs revision before implementation.
```

After proposal creation, trigger plan review by asking the agent to use
`openspec-plan-review` on the new change. Do not implement yet.
