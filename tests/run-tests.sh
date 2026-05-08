#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

bash "$ROOT_DIR/tests/test_repository_contract.sh"
bash "$ROOT_DIR/tests/test_install_scripts.sh"
bash "$ROOT_DIR/tests/test_openspec_gate.sh"

echo "All ai-coding-rules tests passed."
