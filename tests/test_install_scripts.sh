#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PROJECT_ROOT="$TMP_DIR/project"
CODEX_HOME="$TMP_DIR/codex"
mkdir -p "$PROJECT_ROOT" "$CODEX_HOME"

bash "$ROOT_DIR/scripts/install-codex-rules.sh" \
  --project-root "$PROJECT_ROOT" \
  --codex-home "$CODEX_HOME" \
  --profile frontend \
  --skills-target project

grep -Fq "Prefer English by default" "$CODEX_HOME/AGENTS.md"
if grep -Fq "## AI Change Records" "$CODEX_HOME/AGENTS.md"; then
  echo "Generated global AGENTS.md should not include AI Change Records" >&2
  exit 1
fi
grep -Fq "This gate is an agent workflow requirement, not an automatic Git hook." "$CODEX_HOME/AGENTS.md"
grep -Fq 'When the agent is asked to create a commit, perform a code review pass over the staged and unstaged changes before running `git commit`.' "$CODEX_HOME/AGENTS.md"
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

bash -s -- \
  --raw-base-url "file://$ROOT_DIR" \
  --project-root "$REMOTE_PROJECT_ROOT" \
  --codex-home "$REMOTE_CODEX_HOME" \
  --profile frontend \
  --skills-target project < "$ROOT_DIR/scripts/install-codex-rules.sh"

grep -Fq "Prefer English by default" "$REMOTE_CODEX_HOME/AGENTS.md"
if grep -Fq "## AI Change Records" "$REMOTE_CODEX_HOME/AGENTS.md"; then
  echo "Generated remote global AGENTS.md should not include AI Change Records" >&2
  exit 1
fi
grep -Fq "This gate is an agent workflow requirement, not an automatic Git hook." "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq 'When the agent is asked to create a commit, perform a code review pass over the staged and unstaged changes before running `git commit`.' "$REMOTE_CODEX_HOME/AGENTS.md"
grep -Fq "Playwright Test Generation" "$REMOTE_PROJECT_ROOT/AGENTS.md"
if grep -Fq "{{allowed_scope}}" "$REMOTE_PROJECT_ROOT/AGENTS.md"; then
  echo "Generated remote project AGENTS.md should not contain unresolved template placeholders" >&2
  exit 1
fi
test -f "$REMOTE_PROJECT_ROOT/.codex/skills/openspec-propose/SKILL.md"
test -f "$REMOTE_PROJECT_ROOT/.codex/skills/playwright-test-generator/SKILL.md"

REMOTE_SKILL_TMP="$TMP_DIR/remote-skill-only"
mkdir -p "$REMOTE_SKILL_TMP"

bash -s -- \
  --raw-base-url "file://$ROOT_DIR" \
  --target "$REMOTE_SKILL_TMP" \
  --all < "$ROOT_DIR/scripts/install-codex-skill.sh"

test -f "$REMOTE_SKILL_TMP/openspec-plan-review/SKILL.md"
test -f "$REMOTE_SKILL_TMP/playwright-test-generator/SKILL.md"
