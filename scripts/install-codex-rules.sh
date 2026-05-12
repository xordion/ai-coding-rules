#!/usr/bin/env bash
set -euo pipefail

SCRIPT_SOURCE="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" 2>/dev/null && pwd || pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd || pwd)"
PROJECT_ROOT="$(pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
PROFILE="default"
AGENT_TARGET="codex"
SKILLS_TARGET="auto"
INSTALL_GLOBAL="auto"
UPDATE_MODE=false
RAW_BASE_URL="${AI_CODING_RULES_RAW_BASE_URL:-https://raw.githubusercontent.com/xordion/ai-coding-rules/main}"
REMOTE_ROOT_DIR=""

usage() {
  cat <<'EOF'
Usage: scripts/install-codex-rules.sh [options]

Options:
  --agent TARGET            codex, cursor, claude, or all. Defaults to codex.
  --project-root PATH       Project root where AGENTS.md should be generated.
  --codex-home PATH         Codex home directory. Defaults to $CODEX_HOME or ~/.codex.
  --profile NAME            default, frontend, or all. Defaults to default.
  --skills-target TARGET    project, user, none, or auto. Defaults to auto.
  --raw-base-url URL        Raw file base URL for curl-based installs.
  --skip-global             Do not install Codex user-level global rules.
  --update                  Update installed project config by backing up and replacing generated files.
EOF
}

cleanup_remote_root() {
  if [[ -n "$REMOTE_ROOT_DIR" && -d "$REMOTE_ROOT_DIR" ]]; then
    rm -rf "$REMOTE_ROOT_DIR"
  fi
}

trap cleanup_remote_root EXIT

has_repository_files() {
  [[ -f "$ROOT_DIR/global-AGENTS.md" ]] &&
    [[ -f "$ROOT_DIR/AGENTS-template.md" ]] &&
    [[ -f "$ROOT_DIR/rules/common/openspec-workflow.md" ]] &&
    [[ -f "$ROOT_DIR/scripts/install-codex-skill.sh" ]] &&
    [[ -f "$ROOT_DIR/skills/openspec-propose/SKILL.md" ]]
}

download_repository_file() {
  local relative_path="$1"
  local destination="$REMOTE_ROOT_DIR/$relative_path"
  local base_url="${RAW_BASE_URL%/}"

  mkdir -p "$(dirname "$destination")"
  curl -fsSL "$base_url/$relative_path" -o "$destination"
}

hydrate_repository_from_raw_url() {
  REMOTE_ROOT_DIR="$(mktemp -d)"
  echo "Fetching ai-coding-rules resources from: ${RAW_BASE_URL%/}" >&2

  local files=(
    "global-AGENTS.md"
    "AGENTS-template.md"
    "rules/common/openspec-workflow.md"
    "rules/frontend/playwright-testing.md"
    "scripts/install-codex-skill.sh"
    "skills/openspec-apply-change/SKILL.md"
    "skills/openspec-archive-change/SKILL.md"
    "skills/openspec-plan-review/SKILL.md"
    "skills/openspec-propose/SKILL.md"
    "skills/playwright-test-generator/SKILL.md"
  )

  for file_path in "${files[@]}"; do
    download_repository_file "$file_path"
  done

  ROOT_DIR="$REMOTE_ROOT_DIR"
}

backup_if_exists() {
  local file_path="$1"
  if [[ -f "$file_path" ]]; then
    cp "$file_path" "$file_path.bak.$(date +%Y%m%d%H%M%S)"
  fi
}

append_section_separator() {
  local file_path="$1"
  printf '\n\n---\n\n' >> "$file_path"
}

install_source_file() {
  local source_path="$1"
  local destination_path="$2"
  local create_message="$3"
  local append_message="$4"

  if [[ -f "$destination_path" ]]; then
    backup_if_exists "$destination_path"
    if [[ "$UPDATE_MODE" == true ]]; then
      cp "$source_path" "$destination_path"
      echo "$create_message: $destination_path"
      return
    fi
    append_section_separator "$destination_path"
    cat "$source_path" >> "$destination_path"
    echo "$append_message: $destination_path"
    return
  fi

  cp "$source_path" "$destination_path"
  echo "$create_message: $destination_path"
}

render_project_agents_content() {
  sed "s/{{project_profile}}/$PROFILE/g" "$ROOT_DIR/AGENTS-template.md"
  printf '\n\n---\n\n'
  cat "$ROOT_DIR/rules/common/openspec-workflow.md"

  if [[ "$PROFILE" == "frontend" || "$PROFILE" == "all" ]]; then
    printf '\n\n---\n\n'
    cat "$ROOT_DIR/rules/frontend/playwright-testing.md"
  fi
}

install_project_agents() {
  local destination_path="$PROJECT_ROOT/AGENTS.md"

  if [[ -f "$destination_path" ]]; then
    backup_if_exists "$destination_path"
    if [[ "$UPDATE_MODE" == true ]]; then
      render_project_agents_content > "$destination_path"
      echo "Updated project rules: $destination_path"
      return
    fi
    append_section_separator "$destination_path"
    render_project_agents_content >> "$destination_path"
    echo "Appended project rules: $destination_path"
    return
  fi

  render_project_agents_content > "$destination_path"
  echo "Generated project rules: $destination_path"
}

render_cursor_rules_content() {
  cat <<'EOF'
---
description: Shared AI coding rules for Cursor
alwaysApply: true
---

EOF
  render_project_agents_content
}

render_claude_memory_content() {
  cat <<'EOF'
# Claude Code Project Instructions

@AGENTS.md
EOF
}

install_generated_content() {
  local destination_path="$1"
  local create_message="$2"
  local append_message="$3"
  local renderer="$4"

  if [[ -f "$destination_path" ]]; then
    backup_if_exists "$destination_path"
    if [[ "$UPDATE_MODE" == true ]]; then
      "$renderer" > "$destination_path"
      echo "$create_message: $destination_path"
      return
    fi
    append_section_separator "$destination_path"
    "$renderer" >> "$destination_path"
    echo "$append_message: $destination_path"
    return
  fi

  "$renderer" > "$destination_path"
  echo "$create_message: $destination_path"
}

install_cursor_rules() {
  local destination_dir="$PROJECT_ROOT/.cursor/rules"
  mkdir -p "$destination_dir"
  install_generated_content \
    "$destination_dir/ai-coding-rules.mdc" \
    "Generated Cursor rules" \
    "Appended Cursor rules" \
    render_cursor_rules_content
}

install_claude_memory() {
  install_generated_content \
    "$PROJECT_ROOT/CLAUDE.md" \
    "Generated Claude Code rules" \
    "Appended Claude Code rules" \
    render_claude_memory_content
}

agent_enabled() {
  local agent_name="$1"
  [[ "$AGENT_TARGET" == "all" || "$AGENT_TARGET" == "$agent_name" ]]
}

install_skills() {
  case "$SKILLS_TARGET" in
    project)
      bash "$ROOT_DIR/scripts/install-codex-skill.sh" --target "$PROJECT_ROOT/.codex/skills" --all
      ;;
    user)
      bash "$ROOT_DIR/scripts/install-codex-skill.sh" --target "$CODEX_HOME/skills" --all
      ;;
    none)
      ;;
    auto)
      if agent_enabled codex; then
        bash "$ROOT_DIR/scripts/install-codex-skill.sh" --target "$PROJECT_ROOT/.codex/skills" --all
      fi
      ;;
    *)
      echo "Unknown --skills-target: $SKILLS_TARGET" >&2
      exit 1
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent)
      AGENT_TARGET="$2"
      shift 2
      ;;
    --project-root)
      PROJECT_ROOT="$2"
      shift 2
      ;;
    --codex-home)
      CODEX_HOME="$2"
      shift 2
      ;;
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --skills-target)
      SKILLS_TARGET="$2"
      shift 2
      ;;
    --raw-base-url)
      RAW_BASE_URL="$2"
      shift 2
      ;;
    --skip-global)
      INSTALL_GLOBAL=false
      shift
      ;;
    --update)
      UPDATE_MODE=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "$PROFILE" in
  default|frontend|all)
    ;;
  *)
    echo "Unknown --profile: $PROFILE" >&2
    exit 1
    ;;
esac

case "$AGENT_TARGET" in
  codex|cursor|claude|all)
    ;;
  *)
    echo "Unknown --agent: $AGENT_TARGET" >&2
    exit 1
    ;;
esac

if ! has_repository_files; then
  hydrate_repository_from_raw_url
fi

mkdir -p "$PROJECT_ROOT"

if [[ "$UPDATE_MODE" == true && "$INSTALL_GLOBAL" == auto ]]; then
  INSTALL_GLOBAL=false
fi

if [[ "$INSTALL_GLOBAL" == auto ]]; then
  if agent_enabled codex; then
    INSTALL_GLOBAL=true
  else
    INSTALL_GLOBAL=false
  fi
fi

if [[ "$INSTALL_GLOBAL" == true ]]; then
  mkdir -p "$CODEX_HOME"
  install_source_file \
    "$ROOT_DIR/global-AGENTS.md" \
    "$CODEX_HOME/AGENTS.md" \
    "Installed global rules" \
    "Appended global rules"
fi

install_project_agents

if agent_enabled cursor; then
  install_cursor_rules
fi

if agent_enabled claude; then
  install_claude_memory
fi

install_skills
