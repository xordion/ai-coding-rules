#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

require_file() {
  local file_path="$1"
  if [[ ! -f "$ROOT_DIR/$file_path" ]]; then
    echo "Missing required file: $file_path" >&2
    exit 1
  fi
}

require_contains() {
  local file_path="$1"
  local expected="$2"
  if ! grep -Fq -- "$expected" "$ROOT_DIR/$file_path"; then
    echo "Expected '$file_path' to contain: $expected" >&2
    exit 1
  fi
}

require_not_contains() {
  local file_path="$1"
  local unexpected="$2"
  if grep -Fq -- "$unexpected" "$ROOT_DIR/$file_path"; then
    echo "Expected '$file_path' not to contain: $unexpected" >&2
    exit 1
  fi
}

require_file "global-AGENTS.md"
require_file "AGENTS-template.md"
require_file "rules/common/openspec-workflow.md"
require_file "rules/frontend/playwright-testing.md"
require_file "skills/openspec-propose/SKILL.md"
require_file "skills/openspec-plan-review/SKILL.md"
require_file "skills/openspec-apply-change/SKILL.md"
require_file "skills/openspec-archive-change/SKILL.md"
require_file "skills/playwright-test-generator/SKILL.md"

require_contains "global-AGENTS.md" "Prefer English by default"
require_contains "global-AGENTS.md" "TDD mandatory"
require_contains "global-AGENTS.md" "This gate is an agent workflow requirement, not an automatic Git hook."
require_contains "global-AGENTS.md" 'When asked to commit, run the gate in order: review staged and unstaged changes for bugs, regressions, missing tests, unsafe behavior, and rule violations; run every relevant test against the staged commit content without relying on unstaged fixes; archive any completed OpenSpec change after verification; then run `git commit`.'
require_contains "global-AGENTS.md" "Fix blocking findings before committing, or explicitly report why they remain unresolved."
require_contains "global-AGENTS.md" "Do not commit when tests or review findings indicate the change is not ready."
require_not_contains "global-AGENTS.md" "## AI Change Records"
require_not_contains "global-AGENTS.md" "ai-changes"
require_contains "AGENTS-template.md" "Project profile"
require_contains "AGENTS-template.md" "Global rules still apply"
require_contains "AGENTS-template.md" "Shared Rule Materialization"
require_not_contains "AGENTS-template.md" "{{allowed_scope}}"
require_not_contains "AGENTS-template.md" "Before creating a git commit"
require_contains "rules/common/openspec-workflow.md" "Review Impact Before Coding"
require_contains "rules/common/openspec-workflow.md" "impact-review.md"
require_contains "rules/frontend/playwright-testing.md" "Playwright"
require_contains "skills/openspec-propose/SKILL.md" "trigger plan review"
require_contains "skills/openspec-plan-review/SKILL.md" "Do not implement yet"
require_contains "skills/openspec-apply-change/SKILL.md" "impact-review.md"
require_contains "skills/openspec-archive-change/SKILL.md" "archive"
require_contains "skills/playwright-test-generator/SKILL.md" "Generate Playwright"
require_contains "README.md" "curl -fsSL https://raw.githubusercontent.com/xordion/ai-coding-rules/main/scripts/install-codex-rules.sh"
require_contains "README.md" "Run from your target project root:"
require_contains "README.md" "bash -s -- --profile frontend"
require_contains "README.md" "What gets installed"
require_contains "README.md" "--skills-target project"
require_contains "README.md" "--agent TARGET"
require_contains "README.md" "Cursor"
require_contains "README.md" "Claude Code"
require_contains "README.md" 'Existing `AGENTS.md` files are backed up and appended to, not replaced.'
require_contains "README.md" "bash tests/run-tests.sh"
require_contains "README.md" "openspec command not found"
require_contains "README.md" "Git Commit Gate"
require_contains "README.md" "This is an agent workflow requirement, not a Git hook."
require_contains "README.md" 'The required order is review staged and unstaged changes, run every relevant test against staged commit content without relying on unstaged fixes, archive completed OpenSpec changes after verification, then `git commit`.'
