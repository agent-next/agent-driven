#!/usr/bin/env bash
# PostToolUse hook: auto-lint after Edit/Write
# Non-blocking (exit 0 always) but reports issues

FILE_PATH=$(jq -r '.tool_input.file_path // empty')
[ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in
  *.py)
    ruff check --fix "$FILE_PATH" 2>/dev/null
    ruff format "$FILE_PATH" 2>/dev/null
    ;;
  *.ts|*.tsx|*.js|*.jsx)
    prettier --write "$FILE_PATH" 2>/dev/null
    ;;
esac

exit 0
