#!/usr/bin/env bash
set -euo pipefail

SCRIPT_SOURCE="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" 2>/dev/null && pwd || pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd || pwd)"
PROJECT_ROOT="$(pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
PROFILE="default"
SKILLS_TARGET="project"
INSTALL_GLOBAL=true
RAW_BASE_URL="${AI_CODING_RULES_RAW_BASE_URL:-https://raw.githubusercontent.com/xordion/ai-coding-rules/main}"
REMOTE_ROOT_DIR=""

usage() {
  cat <<'EOF'
Usage: scripts/install-codex-rules.sh [options]

Options:
  --project-root PATH       Project root where AGENTS.md should be generated.
  --codex-home PATH         Codex home directory. Defaults to $CODEX_HOME or ~/.codex.
  --profile NAME            default, frontend, or all. Defaults to default.
  --skills-target TARGET    project, user, or none. Defaults to project.
  --raw-base-url URL        Raw file base URL for curl-based installs.
  --skip-global             Do not install global AGENTS.md.
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

render_project_agents() {
  local output_path="$1"

  {
    sed "s/{{project_profile}}/$PROFILE/g" "$ROOT_DIR/AGENTS-template.md"
    printf '\n\n---\n\n'
    cat "$ROOT_DIR/rules/common/openspec-workflow.md"

    if [[ "$PROFILE" == "frontend" || "$PROFILE" == "all" ]]; then
      printf '\n\n---\n\n'
      cat "$ROOT_DIR/rules/frontend/playwright-testing.md"
    fi
  } > "$output_path"
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
    *)
      echo "Unknown --skills-target: $SKILLS_TARGET" >&2
      exit 1
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
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

if ! has_repository_files; then
  hydrate_repository_from_raw_url
fi

mkdir -p "$PROJECT_ROOT" "$CODEX_HOME"

if [[ "$INSTALL_GLOBAL" == true ]]; then
  backup_if_exists "$CODEX_HOME/AGENTS.md"
  cp "$ROOT_DIR/global-AGENTS.md" "$CODEX_HOME/AGENTS.md"
  echo "Installed global rules: $CODEX_HOME/AGENTS.md"
fi

backup_if_exists "$PROJECT_ROOT/AGENTS.md"
render_project_agents "$PROJECT_ROOT/AGENTS.md"
echo "Generated project rules: $PROJECT_ROOT/AGENTS.md"

install_skills
