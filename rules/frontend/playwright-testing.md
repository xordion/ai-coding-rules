# Playwright Test Generation

Frontend projects must use browser-level tests for critical user journeys and
for OpenSpec scenarios that cannot be proven by unit tests alone.

## When To Generate Playwright Tests

Generate or update Playwright tests when a change affects:

- navigation, routing, or deep links
- forms, validation, submission, or duplicate-submit prevention
- document viewers, canvas, selection, search, zoom, drag, or keyboard behavior
- loading, empty, error, retry, offline, or permission-denied states
- accessibility, focus movement, dialogs, menus, or keyboard-only operation
- regressions listed in `impact-review.md`

## Test Design

- Derive test names from user-visible behavior, not implementation details.
- Map each E2E test back to an OpenSpec scenario or acceptance criterion.
- Prefer role, label, and visible text selectors before test ids.
- Keep tests deterministic by mocking unstable networks or external services.
- Capture screenshots only when visual behavior is part of the requirement.
- Include keyboard and focus assertions for interactive controls.

## Frontend Gate

For frontend changes, the implementation plan must include:

- unit or component tests for pure logic and components
- Playwright tests for critical flows and regression risks
- manual browser verification steps when visual inspection is required
