# AI Coding Rules

Shared Codex rules, OpenSpec workflow skills, and frontend verification guidance for
team projects.

## Requirements

- Bash, `curl`, `sed`, `cp`, and other standard Unix shell tools.
- Codex reads user-level rules from `~/.codex/AGENTS.md` and project rules from
  `AGENTS.md` in the target project.
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
- `<project-root>/.codex/skills/*` when `--skills-target project` is used.
- `~/.codex/skills/*` when `--skills-target user` is used.

Existing `AGENTS.md` files are backed up before replacement with a timestamped
`.bak.YYYYMMDDHHMMSS` suffix. Skill directories are copied into the target
directory and may overwrite files with the same names.

## Install Options

Use the local script after cloning this repository:

```bash
bash scripts/install-codex-rules.sh --profile frontend
```

Run the local script from the target project root too, or add
`--project-root /path/to/project` when running it from another directory.

The rules installer accepts these options:

- `--project-root PATH`: project root where `AGENTS.md` is generated. Defaults
  to the current directory.
- `--codex-home PATH`: Codex home directory. Defaults to `$CODEX_HOME` or
  `~/.codex`.
- `--profile NAME`: `default`, `frontend`, or `all`. Defaults to `default`.
- `--skills-target TARGET`: `project`, `user`, or `none`. Defaults to
  `project`.
- `--raw-base-url URL`: raw file base URL. Useful for forks, pinned versions,
  or local tests.
- `--skip-global`: do not install user-level global rules.

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

To keep existing project rules and install only skills, use the skills-only
installer. To refresh project rules without touching user-level global rules,
use `--skip-global`.

## Git Commit Gate

The installed global rules require the agent to run a review pass before it
creates a commit. That review covers both staged and unstaged changes, with
attention to bugs, regressions, missing tests, unsafe behavior, and project rule
violations.

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
