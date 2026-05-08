#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PROJECT_ROOT="$TMP_DIR/project"
BIN_DIR="$TMP_DIR/bin"
mkdir -p "$PROJECT_ROOT/openspec/changes/add-example" "$BIN_DIR"

cat > "$BIN_DIR/openspec" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${1:-}" == "list" && "${2:-}" == "--json" ]]; then
  printf '[{"name":"add-example"}]\n'
  exit 0
fi
if [[ "${1:-}" == "validate" ]]; then
  exit 0
fi
echo "unexpected openspec invocation: $*" >&2
exit 2
EOF
chmod +x "$BIN_DIR/openspec"

if PATH="$BIN_DIR:$PATH" bash "$ROOT_DIR/scripts/check-openspec.sh" --project-root "$PROJECT_ROOT"; then
  echo "OpenSpec gate should fail when impact-review.md is missing" >&2
  exit 1
fi

cat > "$PROJECT_ROOT/openspec/changes/add-example/impact-review.md" <<'EOF'
# Impact Review

## Verdict

Ready for implementation.
EOF

PATH="$BIN_DIR:$PATH" bash "$ROOT_DIR/scripts/check-openspec.sh" --project-root "$PROJECT_ROOT"
