# OpenSpec Workflow

Use OpenSpec for changes that affect user-visible behavior, public APIs,
business rules, data processing, shared architecture, or acceptance criteria.

## Lifecycle

1. Explore: clarify the problem, constraints, existing behavior, and acceptance criteria.
2. Propose: create `openspec/changes/<change-name>/proposal.md`, `design.md`, `tasks.md`, and spec deltas.
3. Review Impact Before Coding: create `openspec/changes/<change-name>/impact-review.md`.
4. Implement: work through `tasks.md` only after the impact review is ready.
5. Verify: run OpenSpec validation, lint, tests, and feature acceptance checks.
6. Archive: archive the completed change after verification and update base specs.

## Review Impact Before Coding

Before implementation, review the OpenSpec change and record the result in
`impact-review.md`.

The review must check:

- Whether the change modifies existing capabilities or introduces a new capability.
- Whether any spec delta could regress old behavior.
- Whether tasks include regression tests for affected behavior.
- Whether design risks, rollout risks, and rollback strategy are covered.
- Whether acceptance criteria are testable.

The impact review has one of these verdicts:

- `Ready for implementation.`
- `Needs revision before implementation.`

Implementation must not start while the verdict is `Needs revision before implementation.`

## Required Artifacts

Every active OpenSpec change should contain:

- `proposal.md`: user value, scope, acceptance criteria, and non-goals.
- `design.md`: approach, alternatives, risks, compatibility, and rollback.
- `tasks.md`: ordered implementation and verification tasks.
- `impact-review.md`: pre-implementation review findings and verdict.
- `specs/<capability>/spec.md`: requirement deltas with scenarios.

## Verification Gate

Run the repository OpenSpec gate before coding and before archiving:

```bash
bash scripts/check-openspec.sh --project-root .
```

The gate must validate OpenSpec files and fail when an active change lacks
`impact-review.md` or has a verdict that is not ready for implementation.
