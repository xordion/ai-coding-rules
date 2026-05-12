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
require_contains "global-AGENTS.md" "## Git Commit Gate Is Two-Phase"
require_contains "global-AGENTS.md" "### Phase 1: Prepare Gate"
require_contains "global-AGENTS.md" "### Phase 2: Act On Explicit Choice"
require_contains "global-AGENTS.md" "## Commit Choice Recognition"
require_contains "global-AGENTS.md" "## OpenSpec Commit Archive Rule"
require_contains "global-AGENTS.md" "## Commit Gate Override"
require_contains "global-AGENTS.md" "full gate every time"
require_contains "global-AGENTS.md" "immediately previous assistant message"
require_contains "global-AGENTS.md" "staged diff fingerprint has not changed"
require_contains "global-AGENTS.md" "no new unstaged changes affect the staged files"
require_contains "global-AGENTS.md" "## Staged Fingerprint"
require_contains "global-AGENTS.md" "git diff --cached --name-status"
require_contains "global-AGENTS.md" "git diff --cached --stat"
require_contains "global-AGENTS.md" "git status --short"
require_contains "global-AGENTS.md" "test commands and results"
require_contains "global-AGENTS.md" "If the staged set changed, rerun the gate"
require_contains "global-AGENTS.md" "commit-gate request, not commit permission"
require_contains "global-AGENTS.md" "Ask and stop"
require_contains "global-AGENTS.md" "latest user message explicitly selects"
require_contains "global-AGENTS.md" "Finding clarification is not a choice"
require_contains "global-AGENTS.md" "Examples that are not approval"
require_contains "global-AGENTS.md" "OpenSpec decision point"
require_contains "global-AGENTS.md" "Review staged and unstaged changes"
require_contains "global-AGENTS.md" "Run relevant tests against staged content without relying on unstaged fixes"
require_contains "global-AGENTS.md" "Report OpenSpec archive blockers"
require_contains "global-AGENTS.md" "Show review log and test results"
require_contains "global-AGENTS.md" '`commit`, `commit & archive`, or `do nothing`'
require_contains "global-AGENTS.md" "Do not commit while blocking findings, test failures, or unresolved archive blockers make the change unready."
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
require_contains "README.md" "--update"
require_contains "README.md" "Update Current Project"
require_contains "README.md" "--agent TARGET"
require_contains "README.md" "Cursor"
require_contains "README.md" "Claude Code"
require_contains "README.md" 'Existing `AGENTS.md` files are backed up and appended to, not replaced.'
require_contains "README.md" "bash tests/run-tests.sh"
require_contains "README.md" "openspec command not found"
require_contains "README.md" "Git Commit Gate"
require_contains "README.md" "This is an agent workflow requirement, not a Git hook."
require_contains "README.md" "Git Commit Gate Is Two-Phase"
require_contains "README.md" "Phase 1"
require_contains "README.md" "Phase 2"
require_contains "README.md" "Commit Gate Override"
require_contains "README.md" "full gate every time"
require_contains "README.md" "staged diff fingerprint"
require_contains "README.md" "Staged Fingerprint"
require_contains "README.md" "git diff --cached --name-status"
require_contains "README.md" "commit-gate request, not commit permission"
require_contains "README.md" "ask and stop"
require_contains "README.md" "latest message explicitly selects"
require_contains "README.md" "Finding clarification is not a choice"
require_contains "README.md" "OpenSpec archive decision point"
require_contains "README.md" "review changes"
require_contains "README.md" "run relevant tests against staged content"
require_contains "README.md" "report OpenSpec archive blockers"
require_contains "README.md" 'always show the review log and test results'
require_contains "README.md" '`commit`, `commit & archive`, or `do nothing`'
