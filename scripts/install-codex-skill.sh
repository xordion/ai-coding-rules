#!/usr/bin/env bash
set -euo pipefail

SCRIPT_SOURCE="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_SOURCE")" 2>/dev/null && pwd || pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd || pwd)"
TARGET="${CODEX_HOME:-$HOME/.codex}/skills"
INSTALL_ALL=false
SKILLS=()
RAW_BASE_URL="${AI_CODING_RULES_RAW_BASE_URL:-https://raw.githubusercontent.com/xordion/ai-coding-rules/main}"
REMOTE_ROOT_DIR=""

usage() {
  cat <<'EOF'
Usage: scripts/install-codex-skill.sh [--target PATH] [--raw-base-url URL] [--all] [skill-name ...]

Options:
  --target PATH       Directory where skills should be installed.
  --raw-base-url URL  Raw file base URL for curl-based installs.
  --all               Install every skill in this repository.
EOF
}

cleanup_remote_root() {
  if [[ -n "$REMOTE_ROOT_DIR" && -d "$REMOTE_ROOT_DIR" ]]; then
    rm -rf "$REMOTE_ROOT_DIR"
  fi
}

trap cleanup_remote_root EXIT

has_repository_files() {
  [[ -d "$ROOT_DIR/skills" ]] &&
    [[ -f "$ROOT_DIR/skills/openspec-propose/SKILL.md" ]] &&
    [[ -f "$ROOT_DIR/skills/playwright-test-generator/SKILL.md" ]]
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
  echo "Fetching ai-coding-rules skills from: ${RAW_BASE_URL%/}" >&2

  local files=(
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --raw-base-url)
      RAW_BASE_URL="$2"
      shift 2
      ;;
    --all)
      INSTALL_ALL=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      SKILLS+=("$1")
      shift
      ;;
  esac
done

if ! has_repository_files; then
  hydrate_repository_from_raw_url
fi

if [[ "$INSTALL_ALL" == true ]]; then
  while IFS= read -r skill_name; do
    SKILLS+=("$skill_name")
  done < <(find "$ROOT_DIR/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
fi

if [[ ${#SKILLS[@]} -eq 0 ]]; then
  echo "No skills selected. Use --all or pass skill names." >&2
  exit 1
fi

mkdir -p "$TARGET"

for skill_name in "${SKILLS[@]}"; do
  source_dir="$ROOT_DIR/skills/$skill_name"
  destination_dir="$TARGET/$skill_name"

  if [[ ! -f "$source_dir/SKILL.md" ]]; then
    echo "Unknown or invalid skill: $skill_name" >&2
    exit 1
  fi

  mkdir -p "$destination_dir"
  cp -R "$source_dir/." "$destination_dir/"
  echo "Installed skill: $skill_name -> $destination_dir"
done
