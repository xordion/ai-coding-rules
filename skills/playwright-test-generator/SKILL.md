---
name: playwright-test-generator
description: Generate Playwright tests for frontend OpenSpec scenarios, regression risks, and critical user journeys.
---

# Playwright Test Generator

Use this skill when a frontend change needs browser-level verification or when
`impact-review.md` calls out E2E regression risk.

## Workflow

1. Read the active OpenSpec change and `impact-review.md`.
2. Identify acceptance criteria and scenarios that require real browser behavior.
3. Inspect the existing Playwright setup, scripts, fixtures, and selector style.
4. Generate Playwright tests before implementation when possible.
5. Prefer deterministic fixtures and local assets over remote services.
6. Run the smallest relevant Playwright command and confirm the failure before coding.
7. After implementation, rerun the same command and any broader frontend gate.

## Test Selection

Generate Playwright tests for:

- navigation, routing, and deep links
- viewer interactions such as search, selection, zoom, canvas, or drag
- keyboard-only workflows and focus movement
- loading, empty, error, retry, and permission states
- regressions identified in `impact-review.md`

## Output

- Add or update Playwright spec files using the project's existing location.
- Name tests by user-visible behavior.
- Add comments only when mapping a test to an OpenSpec scenario is otherwise unclear.
- Report the command used and whether it failed or passed.
