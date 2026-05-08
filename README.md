# AI Coding Rules

Shared Codex rules, OpenSpec workflow skills, and frontend verification guidance for
team projects.

## Install

Install directly from GitHub without cloning this repository:

```bash
curl -fsSL https://raw.githubusercontent.com/xordion/ai-coding-rules/main/scripts/install-codex-rules.sh \
  | bash -s -- --project-root /path/to/project --profile frontend
```

Install skills only:

```bash
curl -fsSL https://raw.githubusercontent.com/xordion/ai-coding-rules/main/scripts/install-codex-skill.sh \
  | bash -s -- --target "$HOME/.codex/skills" --all
```

If you already cloned the repository, you can run the local script:

```bash
bash scripts/install-codex-rules.sh --project-root /path/to/project --profile frontend
```

This installs:

- `~/.codex/AGENTS.md` from `global-AGENTS.md`
- project `AGENTS.md` from `AGENTS-template.md` and selected rules
- project-local Codex skills under `.codex/skills`

## Profiles

- `default`: common delivery and OpenSpec workflow rules
- `frontend`: default rules plus Playwright test generation guidance
- `all`: all shared rules and skills

## Gates

Run the OpenSpec gate before implementation and before archive:

```bash
bash scripts/check-openspec.sh --project-root /path/to/project
```

The gate validates active OpenSpec changes and requires an `impact-review.md`
artifact for every active change.
