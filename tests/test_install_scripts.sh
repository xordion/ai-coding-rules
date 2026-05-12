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
grep -Fq "## Git Commit Gate Is Two-Phase" "$CODEX_HOME/AGENTS.md"
grep -Fq "### Phase 1: Prepare Gate" "$CODEX_HOME/AGENTS.md"
grep -Fq "### Phase 2: Act On Explicit Choice" "$CODEX_HOME/AGENTS.md"
grep -Fq "## Commit Choice Recognition" "$CODEX_HOME/AGENTS.md"
grep -Fq "## OpenSpec Commit Archive Rule" "$CODEX_HOME/AGENTS.md"
grep -Fq "## Commit Gate Override" "$CODEX_HOME/AGENTS.md"
grep -Fq "full gate every time" "$CODEX_HOME/AGENTS.md"
grep -Fq "immediately previous assistant message" "$CODEX_HOME/AGENTS.md"
grep -Fq "staged diff fingerprint has not changed" "$CODEX_HOME/AGENTS.md"
grep -Fq "no new unstaged changes affect the staged files" "$CODEX_HOME/AGENTS.md"
grep -Fq "## Staged Fingerprint" "$CODEX_HOME/AGENTS.md"
grep -Fq "git diff --cached --name-status" "$CODEX_HOME/AGENTS.md"
grep -Fq "git diff --cached --stat" "$CODEX_HOME/AGENTS.md"
grep -Fq "git status --short" "$CODEX_HOME/AGENTS.md"
grep -Fq "test commands and results" "$CODEX_HOME/AGENTS.md"
grep -Fq "If the staged set changed, rerun the gate" "$CODEX_HOME/AGENTS.md"
grep -Fq "commit-gate request, not commit permission" "$CODEX_HOME/AGENTS.md"
grep -Fq "Ask and stop" "$CODEX_HOME/AGENTS.md"
grep -Fq "latest user message explicitly selects" "$CODEX_HOME/AGENTS.md"
grep -Fq "Finding clarification is not a choice" "$CODEX_HOME/AGENTS.md"
grep -Fq "Examples that are not approval" "$CODEX_HOME/AGENTS.md"
grep -Fq "OpenSpec decision point" "$CODEX_HOME/AGENTS.md"
grep -Fq "Review staged and unstaged changes" "$CODEX_HOME/AGENTS.md"
grep -Fq "Run relevant tests against staged content without relying on unstaged fixes" "$CODEX_HOME/AGENTS.md"
grep -Fq "Report OpenSpec archive blockers" "$CODEX_HOME/AGENTS.md"
grep -Fq "Show review log and test results" "$CODEX_HOME/AGENTS.md"
grep -Fq '`commit`, `commit & archive`, or `do nothing`' "$CODEX_HOME/AGENTS.md"
grep -Fq "Do not commit while blocking findings, test failures, or unresolved archive blockers make the change unready." "$CODEX_HOME/AGENTS.md"
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
grep -Fq "## Git Commit Gate Is Two-Phase" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "### Phase 1: Prepare Gate" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "### Phase 2: Act On Explicit Choice" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "## Commit Choice Recognition" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "## OpenSpec Commit Archive Rule" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "## Commit Gate Override" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "full gate every time" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "immediately previous assistant message" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "staged diff fingerprint has not changed" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "no new unstaged changes affect the staged files" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "## Staged Fingerprint" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "git diff --cached --name-status" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "git diff --cached --stat" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "git status --short" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "test commands and results" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "If the staged set changed, rerun the gate" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "commit-gate request, not commit permission" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Ask and stop" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "latest user message explicitly selects" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Finding clarification is not a choice" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Examples that are not approval" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "OpenSpec decision point" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Review staged and unstaged changes" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Run relevant tests against staged content without relying on unstaged fixes" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Report OpenSpec archive blockers" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Show review log and test results" "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq '`commit`, `commit & archive`, or `do nothing`' "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Do not commit while blocking findings, test failures, or unresolved archive blockers make the change unready." "$REMOTE_CODEX_HOME/AGENTS.md"
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

UPDATE_PROJECT_ROOT="$TMP_DIR/update-project"
mkdir -p "$UPDATE_PROJECT_ROOT"

bash "$ROOT_DIR/scripts/install-codex-rules.sh" \
  --project-root "$UPDATE_PROJECT_ROOT" \
  --skip-global \
  --profile default \
  --skills-target project

printf '\nSTALE INSTALLED CONFIG\n' >> "$UPDATE_PROJECT_ROOT/AGENTS.md"

bash "$ROOT_DIR/scripts/install-codex-rules.sh" \
  --update \
  --project-root "$UPDATE_PROJECT_ROOT" \
  --skip-global \
  --profile frontend \
  --skills-target project

grep -Fq "Project profile: \`frontend\`" "$UPDATE_PROJECT_ROOT/AGENTS.md"
grep -Fq "Playwright Test Generation" "$UPDATE_PROJECT_ROOT/AGENTS.md"
if grep -Fq "STALE INSTALLED CONFIG" "$UPDATE_PROJECT_ROOT/AGENTS.md"; then
  echo "Update mode should replace installed project rules instead of appending stale content" >&2
  exit 1
fi
test -f "$UPDATE_PROJECT_ROOT/AGENTS.md".bak.*
test -f "$UPDATE_PROJECT_ROOT/.codex/skills/openspec-propose/SKILL.md"
