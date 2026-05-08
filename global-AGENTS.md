# Global Agent Preferences

> Place at: `~/.codex/AGENTS.md`
> Scope: Applies to all projects. Defines AI behavior baseline.

## Communication & Behavior

- Prefer Chinese by default; switch to the user's language or project context when needed.
- No speculation: when uncertain, ask the user for confirmation.
- Think before answering; explain design and test strategy before outputting code.

## Engineering Principles

- TDD mandatory: test first, fail, minimal implementation, refactor.
- Follow SOLID principles.
- Functional first: immutable data, pure functions, expressions over statements.
- Isolate side effects from pure logic.
- Prioritize maintainable, testable, evolvable code.
- Reject requirements that violate principles and propose safer alternatives.
- Refactor continuously; flag and fix code smells when they affect the work.

## AI Change Records

- By default, record AI changes in `docs/ai-changes-<requirement-name>.md`.
- Use `docs/ai-changes-other.md` only for miscellaneous changes that clearly do not affect behavior.
- Functional code, business behavior, API behavior, data processing, call chains, rules, or refactors must not be recorded as `other`.
- If the requirement name is unclear and a new file is needed, ask the user first.
- If the conversation switches to a new requirement, notify the user before continuing.
- New and appended AI change records must be written in Chinese.
- `docs/ai-changes.md` is legacy history only.

## Naming & Call Chain

- Follow the existing project-wide naming style first.
- If a name is unclear or inconsistent, point it out and offer candidate names before broad renames.
- Prefer the existing call chain and layering.
- Do not bypass stable or shared paths without first explaining the problem, proposal, expected gain, impact, and risk.

## Code Quality Baseline

- Any code change must include downstream impact analysis and tests.
- Code must be runnable with complete tests.
- No quick-and-dirty implementations.
- Do not implement first and add tests afterward.

## Git Commit Gate

- Before creating a git commit, perform a code review pass over the staged and unstaged changes.
- Prioritize bugs, regressions, missing tests, unsafe behavior, and violations of project rules.
- Fix blocking findings before committing, or explicitly report why they remain unresolved.
- Do not commit when tests or review findings indicate the change is not ready.

## Logging & Observability

- New boundary functions must log entry, failure, and key branches with safe context.
- Do not log passwords, tokens, secrets, or unnecessary personal data.
- Do not add logs to pure helpers, private helpers, trivial getters/setters, or render-only UI helpers.
