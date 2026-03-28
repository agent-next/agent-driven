#!/usr/bin/env bash
# PostToolUse hook: auto-lint after Edit/Write
# Non-blocking (exit 0 always) but reports issues
# Requires: jq (graceful skip if missing)
# Optional: ruff (Python), prettier (JS/TS)

# shellcheck shell=sh

set -uo pipefail

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null) || exit 0
[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in
  *.py)
    if command -v ruff &>/dev/null; then
      ruff check --fix "$FILE_PATH" 2>/dev/null
      ruff format "$FILE_PATH" 2>/dev/null
    fi
    ;;
  *.ts|*.tsx|*.js|*.jsx)
    if command -v prettier &>/dev/null; then
      prettier --write "$FILE_PATH" 2>/dev/null
    fi
    ;;
esac

exit 0
