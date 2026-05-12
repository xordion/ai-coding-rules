# Global Agent Preferences

> Place at: `~/.codex/AGENTS.md`
> Scope: Applies to all projects. Defines AI behavior baseline.

## Communication & Behavior

- Prefer English by default; switch to the user's language or project context when needed.
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

- This gate is an agent workflow requirement, not an automatic Git hook.
- Treat any request containing `commit`, `git commit`, `提交`, or similar as a commit-gate request, not commit permission.

## Commit Gate Override

- Run the full gate every time a commit is requested unless the immediately previous assistant message already showed the review log, test results, OpenSpec archive status, and the exact three choices.
- Even after a complete immediately previous gate, commit only when the latest user message explicitly selects `commit`, the staged diff fingerprint has not changed, and no new unstaged changes affect the staged files.
- If any condition is false, rerun the gate and ask again.
- After showing the gate result, ask and stop.

## Git Commit Gate Is Two-Phase

### Phase 1: Prepare Gate

- Review staged and unstaged changes.
- Run relevant tests against staged content without relying on unstaged fixes.
- Report OpenSpec archive blockers.
- Show review log and test results.
- Ask for exactly `commit`, `commit & archive`, or `do nothing`.
- Ask and stop. Do not run `git commit`.

### Phase 2: Act On Explicit Choice

- Commit only when the latest user message explicitly selects `commit`.
- Archive and commit only when the latest user message explicitly selects `commit & archive`.
- Do nothing only when the latest user message explicitly selects `do nothing`.
- Do not commit while blocking findings, test failures, or unresolved archive blockers make the change unready.

## Commit Choice Recognition

- Finding clarification is not a choice.
- Examples that are not approval: `不是问题`, `这个不用改`, `继续`, `好的`, `looks good`, `resolved`.
- After such messages, restate the updated gate result and ask the three choices again.

## OpenSpec Commit Archive Rule

- OpenSpec decision point: if an active OpenSpec change is not archived, report it.
- For `commit & archive`, archive first and rerun OpenSpec validation.
- For `commit`, mention archive remains pending.

## Staged Fingerprint

- Before asking for a commit choice, record `git diff --cached --name-status`, `git diff --cached --stat`, `git status --short`, and test commands and results.
- Before executing the chosen action, re-check `git status --short` and `git diff --cached --name-status`.
- If the staged set changed, rerun the gate and ask again.
- If new unstaged changes affect staged files, rerun the gate or stop until the staged-only result can be trusted.

## Logging & Observability

- New boundary functions must log entry, failure, and key branches with safe context.
- Do not log passwords, tokens, secrets, or unnecessary personal data.
- Do not add logs to pure helpers, private helpers, trivial getters/setters, or render-only UI helpers.
