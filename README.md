# AI Coding Rules

Shared AI agent rules, OpenSpec workflow skills, and frontend verification
guidance for team projects.

## Requirements

- Bash, `curl`, `sed`, `cp`, and other standard Unix shell tools.
- Codex reads user-level rules from `~/.codex/AGENTS.md` and project rules from
  `AGENTS.md` in the target project.
- Cursor can use the generated `AGENTS.md` and `.cursor/rules` adapter.
- Claude Code can use the generated `CLAUDE.md` adapter.
- OpenSpec projects should have the `openspec` command available before running
  the OpenSpec gate.

## Quick Start

Install directly from GitHub without cloning this repository.
Run from your target project root:

```bash
curl -fsSL https://raw.githubusercontent.com/xordion/ai-coding-rules/main/scripts/install-codex-rules.sh \
  | bash -s -- --profile frontend
```

This installs global Codex rules, generates project rules in the current
directory, and installs all included skills under the project-local
`.codex/skills` directory.

Install for Cursor only:

```bash
curl -fsSL https://raw.githubusercontent.com/xordion/ai-coding-rules/main/scripts/install-codex-rules.sh \
  | bash -s -- --agent cursor --profile frontend
```

Install for Claude Code only:

```bash
curl -fsSL https://raw.githubusercontent.com/xordion/ai-coding-rules/main/scripts/install-codex-rules.sh \
  | bash -s -- --agent claude --profile frontend
```

Install adapters for Codex, Cursor, and Claude Code together:

```bash
curl -fsSL https://raw.githubusercontent.com/xordion/ai-coding-rules/main/scripts/install-codex-rules.sh \
  | bash -s -- --agent all --profile frontend
```

If you need to install into a different project directory, pass it explicitly:

```bash
curl -fsSL https://raw.githubusercontent.com/xordion/ai-coding-rules/main/scripts/install-codex-rules.sh \
  | bash -s -- --project-root /path/to/project --profile frontend
```

## What gets installed

The full rules installer writes these files:

- `~/.codex/AGENTS.md` from `global-AGENTS.md`, unless `--skip-global` is used.
- `<project-root>/AGENTS.md` from `AGENTS-template.md` plus the selected rule
  profile.
- `<project-root>/.cursor/rules/ai-coding-rules.mdc` when `--agent cursor` or
  `--agent all` is used.
- `<project-root>/CLAUDE.md` when `--agent claude` or `--agent all` is used.
- `<project-root>/.codex/skills/*` when `--skills-target project` is used.
- `~/.codex/skills/*` when `--skills-target user` is used.

Existing `AGENTS.md` files are backed up and appended to, not replaced. The
backup uses a timestamped `.bak.YYYYMMDDHHMMSS` suffix, then the installer adds
a separator and the generated rules to the end of the existing file. Skill
directories are copied into the target directory and may overwrite files with
the same names.

## Install Options

Use the local script after cloning this repository:

```bash
bash scripts/install-codex-rules.sh --profile frontend
```

Run the local script from the target project root too, or add
`--project-root /path/to/project` when running it from another directory.

The rules installer accepts these options:

- `--agent TARGET`: `codex`, `cursor`, `claude`, or `all`. Defaults to `codex`.
- `--project-root PATH`: project root where `AGENTS.md` is generated. Defaults
  to the current directory.
- `--codex-home PATH`: Codex home directory. Defaults to `$CODEX_HOME` or
  `~/.codex`.
- `--profile NAME`: `default`, `frontend`, or `all`. Defaults to `default`.
- `--skills-target TARGET`: `project`, `user`, `none`, or `auto`. Defaults to
  `auto`; `auto` installs Codex skills for `codex` and `all`, and skips skills
  for `cursor` and `claude`.
- `--raw-base-url URL`: raw file base URL. Useful for forks, pinned versions,
  or local tests.
- `--skip-global`: do not install Codex user-level global rules.
- `--update`: update installed project config by backing up and replacing
  generated files instead of appending another copy.

## Profiles

- `default`: common delivery and OpenSpec workflow rules.
- `frontend`: `default` rules plus Playwright test generation guidance.
- `all`: all shared rules and skills.

Choose `frontend` for browser, UI, or visual verification work. Choose `default`
for backend or general projects that do not need frontend-specific guidance.

## Skills Only

Install every skill without generating `AGENTS.md` files:

```bash
curl -fsSL https://raw.githubusercontent.com/xordion/ai-coding-rules/main/scripts/install-codex-skill.sh \
  | bash -s -- --target "$HOME/.codex/skills" --all
```

Install selected skills after cloning:

```bash
bash scripts/install-codex-skill.sh --target "$HOME/.codex/skills" openspec-propose playwright-test-generator
```

The skills installer accepts these options:

- `--target PATH`: directory where skills are installed. Defaults to
  `$CODEX_HOME/skills` or `~/.codex/skills`.
- `--raw-base-url URL`: raw file base URL for remote installs.
- `--all`: install every skill in this repository.
- `skill-name`: install one or more named skills when `--all` is not used.

## OpenSpec Gate

Run the OpenSpec gate before implementation and before archive:

```bash
bash scripts/check-openspec.sh --project-root /path/to/project
```

The gate validates active OpenSpec changes and requires an `impact-review.md`
artifact for every active change. A change is considered ready only when its
impact review contains:

```text
Ready for implementation.
```

Check one change explicitly:

```bash
bash scripts/check-openspec.sh --project-root /path/to/project --change add-example
```

If you see `openspec command not found`, install OpenSpec or make sure the
`openspec` executable is on `PATH` before running the gate.

## Verification

Run the repository test suite after changing rules, scripts, skills, or this
README:

```bash
bash tests/run-tests.sh
```

The suite checks repository structure, install script behavior, remote install
behavior, generated rule contents, skill installation, and the OpenSpec gate.

## Updating Existing Projects

Re-run the installer when this repository changes or when you want a different
profile. Review the generated `AGENTS.md` diff in the target project before
committing it.

## Update Current Project

Run this from the target project root to refresh the already installed project
rules and project-local skills:

```bash
curl -fsSL https://raw.githubusercontent.com/xordion/ai-coding-rules/main/scripts/install-codex-rules.sh \
  | bash -s -- --update --skip-global --profile frontend --skills-target project
```

`--update` creates a timestamped backup, replaces generated project config, and
leaves user-level global rules untouched when used with `--skip-global`.

To keep existing project rules and install only skills, use the skills-only
installer. To refresh project rules without touching user-level global rules,
use `--skip-global`.

## Git Commit Gate

The installed global rules require the agent to run a commit gate before it
creates a commit. A commit request is a commit-gate request, not commit permission:

Git Commit Gate Is Two-Phase:

1. Phase 1 prepares the gate: review changes, run relevant tests against staged content,
   report OpenSpec archive blockers, always show the review log and test results,
   ask for `commit`, `commit & archive`, or `do nothing`, then ask and stop.
2. Phase 2 acts only when the latest message explicitly selects one of those choices.

Commit Gate Override: the agent runs the full gate every time unless the
immediately previous assistant message already showed the complete gate result.
Even then, it may act only when the latest message explicitly selects a choice,
the staged diff fingerprint has not changed, and no new unstaged changes affect
the staged files.

Staged Fingerprint records `git diff --cached --name-status`,
`git diff --cached --stat`, `git status --short`, and test commands/results.
Before acting, the agent re-checks status and staged file names; changed staged
sets rerun the gate.

Finding clarification is not a choice; after a clarification, the agent restates
the gate result and asks again. An unarchived active OpenSpec change is an
OpenSpec archive decision point. Blocking findings, test failures, or unresolved
archive blockers stop the commit.

This is an agent workflow requirement, not a Git hook. If you run `git commit`
yourself in a terminal, Git will not automatically enforce these rules.

## Troubleshooting

- Unknown `--profile`: use `default`, `frontend`, or `all`.
- Unknown `--skills-target`: use `project`, `user`, or `none`.
- Unknown skill name: check the directories under `skills/`.
- Remote install fails: verify network access to the raw base URL, or pass
  `--raw-base-url` for a fork or local mirror.
- Generated files appear in the wrong project: re-run with an explicit
  `--project-root /path/to/project`.
