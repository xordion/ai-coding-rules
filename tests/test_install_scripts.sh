#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PROJECT_ROOT="$TMP_DIR/project"
CODEX_HOME="$TMP_DIR/codex"
mkdir -p "$PROJECT_ROOT" "$CODEX_HOME"
cat > "$CODEX_HOME/AGENTS.md" <<'EOF'
# Existing Global Rules

Keep existing global rule.
EOF
cat > "$PROJECT_ROOT/AGENTS.md" <<'EOF'
# Existing Project Rules

Keep existing project rule.
EOF

bash "$ROOT_DIR/scripts/install-codex-rules.sh" \
  --project-root "$PROJECT_ROOT" \
  --codex-home "$CODEX_HOME" \
  --profile frontend \
  --skills-target project

grep -Fq "Keep existing global rule." "$CODEX_HOME/AGENTS.md"
grep -Fq "Prefer English by default" "$CODEX_HOME/AGENTS.md"
if grep -Fq "## AI Change Records" "$CODEX_HOME/AGENTS.md"; then
  echo "Generated global AGENTS.md should not include AI Change Records" >&2
  exit 1
fi
grep -Fq "This gate is an agent workflow requirement, not an automatic Git hook." "$CODEX_HOME/AGENTS.md"
grep -Fq 'When asked to commit, run the gate in order: review staged and unstaged changes for bugs, regressions, missing tests, unsafe behavior, and rule violations; run every relevant test against the staged commit content without relying on unstaged fixes; archive any completed OpenSpec change after verification; then run `git commit`.' "$CODEX_HOME/AGENTS.md"
grep -Fq "Fix blocking findings before committing, or explicitly report why they remain unresolved." "$CODEX_HOME/AGENTS.md"
grep -Fq "Do not commit when tests or review findings indicate the change is not ready." "$CODEX_HOME/AGENTS.md"
grep -Fq "Keep existing project rule." "$PROJECT_ROOT/AGENTS.md"
grep -Fq "Review Impact Before Coding" "$PROJECT_ROOT/AGENTS.md"
grep -Fq "Playwright Test Generation" "$PROJECT_ROOT/AGENTS.md"
if grep -Fq "{{allowed_scope}}" "$PROJECT_ROOT/AGENTS.md"; then
  echo "Generated project AGENTS.md should not contain unresolved template placeholders" >&2
  exit 1
fi
test -f "$PROJECT_ROOT/.codex/skills/openspec-propose/SKILL.md"
test -f "$PROJECT_ROOT/.codex/skills/openspec-plan-review/SKILL.md"
test -f "$PROJECT_ROOT/.codex/skills/openspec-apply-change/SKILL.md"
test -f "$PROJECT_ROOT/.codex/skills/openspec-archive-change/SKILL.md"
test -f "$PROJECT_ROOT/.codex/skills/playwright-test-generator/SKILL.md"
test ! -f "$PROJECT_ROOT/.cursor/rules/ai-coding-rules.mdc"
test ! -f "$PROJECT_ROOT/CLAUDE.md"

CURSOR_PROJECT_ROOT="$TMP_DIR/cursor-project"
mkdir -p "$CURSOR_PROJECT_ROOT"

bash "$ROOT_DIR/scripts/install-codex-rules.sh" \
  --agent cursor \
  --project-root "$CURSOR_PROJECT_ROOT" \
  --profile frontend

grep -Fq "Review Impact Before Coding" "$CURSOR_PROJECT_ROOT/AGENTS.md"
grep -Fq "Playwright Test Generation" "$CURSOR_PROJECT_ROOT/.cursor/rules/ai-coding-rules.mdc"
grep -Fq "Shared AI coding rules for Cursor" "$CURSOR_PROJECT_ROOT/.cursor/rules/ai-coding-rules.mdc"
test ! -d "$CURSOR_PROJECT_ROOT/.codex"
test ! -f "$CURSOR_PROJECT_ROOT/CLAUDE.md"

CLAUDE_PROJECT_ROOT="$TMP_DIR/claude-project"
mkdir -p "$CLAUDE_PROJECT_ROOT"

bash "$ROOT_DIR/scripts/install-codex-rules.sh" \
  --agent claude \
  --project-root "$CLAUDE_PROJECT_ROOT" \
  --profile default

grep -Fq "Review Impact Before Coding" "$CLAUDE_PROJECT_ROOT/AGENTS.md"
grep -Fq "@AGENTS.md" "$CLAUDE_PROJECT_ROOT/CLAUDE.md"
test ! -d "$CLAUDE_PROJECT_ROOT/.codex"
test ! -d "$CLAUDE_PROJECT_ROOT/.cursor"

ALL_PROJECT_ROOT="$TMP_DIR/all-project"
ALL_CODEX_HOME="$TMP_DIR/all-codex"
mkdir -p "$ALL_PROJECT_ROOT" "$ALL_CODEX_HOME"

bash "$ROOT_DIR/scripts/install-codex-rules.sh" \
  --agent all \
  --project-root "$ALL_PROJECT_ROOT" \
  --codex-home "$ALL_CODEX_HOME" \
  --profile frontend

grep -Fq "Prefer English by default" "$ALL_CODEX_HOME/AGENTS.md"
grep -Fq "Playwright Test Generation" "$ALL_PROJECT_ROOT/AGENTS.md"
grep -Fq "Playwright Test Generation" "$ALL_PROJECT_ROOT/.cursor/rules/ai-coding-rules.mdc"
grep -Fq "@AGENTS.md" "$ALL_PROJECT_ROOT/CLAUDE.md"
test -f "$ALL_PROJECT_ROOT/.codex/skills/openspec-propose/SKILL.md"

SKILL_TMP="$TMP_DIR/skill-only"
mkdir -p "$SKILL_TMP"
bash "$ROOT_DIR/scripts/install-codex-skill.sh" \
  --target "$SKILL_TMP" \
  --all

test -f "$SKILL_TMP/openspec-plan-review/SKILL.md"
test -f "$SKILL_TMP/openspec-apply-change/SKILL.md"
test -f "$SKILL_TMP/openspec-archive-change/SKILL.md"
test -f "$SKILL_TMP/playwright-test-generator/SKILL.md"

REMOTE_PROJECT_ROOT="$TMP_DIR/remote-project"
REMOTE_CODEX_HOME="$TMP_DIR/remote-codex"
mkdir -p "$REMOTE_PROJECT_ROOT" "$REMOTE_CODEX_HOME"
cat > "$REMOTE_CODEX_HOME/AGENTS.md" <<'EOF'
# Existing Remote Global Rules

Keep existing remote global rule.
EOF
cat > "$REMOTE_PROJECT_ROOT/AGENTS.md" <<'EOF'
# Existing Remote Project Rules

Keep existing remote project rule.
EOF

bash -s -- \
  --raw-base-url "file://$ROOT_DIR" \
  --project-root "$REMOTE_PROJECT_ROOT" \
  --codex-home "$REMOTE_CODEX_HOME" \
  --profile frontend \
  --skills-target project < "$ROOT_DIR/scripts/install-codex-rules.sh"

grep -Fq "Keep existing remote global rule." "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Prefer English by default" "$REMOTE_CODEX_HOME/AGENTS.md"
if grep -Fq "## AI Change Records" "$REMOTE_CODEX_HOME/AGENTS.md"; then
  echo "Generated remote global AGENTS.md should not include AI Change Records" >&2
  exit 1
fi
grep -Fq "This gate is an agent workflow requirement, not an automatic Git hook." "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq 'When asked to commit, run the gate in order: review staged and unstaged changes for bugs, regressions, missing tests, unsafe behavior, and rule violations; run every relevant test against the staged commit content without relying on unstaged fixes; archive any completed OpenSpec change after verification; then run `git commit`.' "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Fix blocking findings before committing, or explicitly report why they remain unresolved." "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Do not commit when tests or review findings indicate the change is not ready." "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Keep existing remote project rule." "$REMOTE_PROJECT_ROOT/AGENTS.md"
grep -Fq "Playwright Test Generation" "$REMOTE_PROJECT_ROOT/AGENTS.md"
if grep -Fq "{{allowed_scope}}" "$REMOTE_PROJECT_ROOT/AGENTS.md"; then
  echo "Generated remote project AGENTS.md should not contain unresolved template placeholders" >&2
  exit 1
fi
test -f "$REMOTE_PROJECT_ROOT/.codex/skills/openspec-propose/SKILL.md"
test -f "$REMOTE_PROJECT_ROOT/.codex/skills/playwright-test-generator/SKILL.md"

REMOTE_CLAUDE_PROJECT_ROOT="$TMP_DIR/remote-claude-project"
mkdir -p "$REMOTE_CLAUDE_PROJECT_ROOT"

bash -s -- \
  --raw-base-url "file://$ROOT_DIR" \
  --agent claude \
  --project-root "$REMOTE_CLAUDE_PROJECT_ROOT" \
  --profile frontend < "$ROOT_DIR/scripts/install-codex-rules.sh"

grep -Fq "Playwright Test Generation" "$REMOTE_CLAUDE_PROJECT_ROOT/AGENTS.md"
grep -Fq "@AGENTS.md" "$REMOTE_CLAUDE_PROJECT_ROOT/CLAUDE.md"
test ! -d "$REMOTE_CLAUDE_PROJECT_ROOT/.codex"

REMOTE_SKILL_TMP="$TMP_DIR/remote-skill-only"
mkdir -p "$REMOTE_SKILL_TMP"

bash -s -- \
  --raw-base-url "file://$ROOT_DIR" \
  --target "$REMOTE_SKILL_TMP" \
  --all < "$ROOT_DIR/scripts/install-codex-skill.sh"

test -f "$REMOTE_SKILL_TMP/openspec-plan-review/SKILL.md"
test -f "$REMOTE_SKILL_TMP/playwright-test-generator/SKILL.md"
