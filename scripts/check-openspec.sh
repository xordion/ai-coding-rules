#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(pwd)"
CHANGE_NAME=""

usage() {
  cat <<'EOF'
Usage: scripts/check-openspec.sh [--project-root PATH] [--change CHANGE_NAME]

Validates OpenSpec changes and requires an impact-review.md verdict before implementation.
EOF
}

extract_change_names() {
  openspec list --json \
    | tr '{' '\n' \
    | sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p'
}

check_impact_review() {
  local change_name="$1"
  local review_path="$PROJECT_ROOT/openspec/changes/$change_name/impact-review.md"

  if [[ ! -f "$review_path" ]]; then
    echo "Missing impact review: $review_path" >&2
    return 1
  fi

  if ! grep -Fq "Ready for implementation." "$review_path"; then
    echo "Impact review is not ready: $review_path" >&2
    return 1
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project-root)
      PROJECT_ROOT="$2"
      shift 2
      ;;
    --change)
      CHANGE_NAME="$2"
      shift 2
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

if ! command -v openspec >/dev/null 2>&1; then
  echo "openspec command not found. Install OpenSpec before running this gate." >&2
  exit 1
fi

cd "$PROJECT_ROOT"

if [[ -n "$CHANGE_NAME" ]]; then
  openspec validate "$CHANGE_NAME" --strict
  check_impact_review "$CHANGE_NAME"
  echo "OpenSpec gate passed for change: $CHANGE_NAME"
  exit 0
fi

change_names=()
while IFS= read -r change_name; do
  change_names+=("$change_name")
done < <(extract_change_names)

if [[ ${#change_names[@]} -eq 0 ]]; then
  openspec validate --strict
  echo "OpenSpec gate passed: no active changes."
  exit 0
fi

for change_name in "${change_names[@]}"; do
  openspec validate "$change_name" --strict
  check_impact_review "$change_name"
done

echo "OpenSpec gate passed for ${#change_names[@]} active change(s)."
