#!/usr/bin/env bash
# PreToolUse hook: block dangerous git operations on main/master
# Exit 2 = block the tool call
# Requires: jq, git

# shellcheck shell=sh

set -uo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")
[ -z "$COMMAND" ] && exit 0

# Block commits/pushes on protected branches
if echo "$COMMAND" | grep -qE '^\s*git\s+(commit|push|merge|rebase|reset|checkout\s+(main|master))\b'; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    echo "BLOCKED: git operation on protected branch '$BRANCH'. Use a feature branch."
    exit 2
  fi
fi

# Block force-push everywhere
if echo "$COMMAND" | grep -qE '^\s*git\s+push.*(--force|-f)\b'; then
  echo "BLOCKED: Force-push is never allowed."
  exit 2
fi

exit 0
