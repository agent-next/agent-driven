#!/usr/bin/env bash
# PostToolUse hook: log all agent actions to session trace
# Lightweight (<5ms overhead). Appends JSON-lines to .claude/traces/
# Requires: jq

# shellcheck shell=bash

set -uo pipefail

INPUT=$(cat)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // "unknown"')
SESSION_ID="${CLAUDE_SESSION_ID:-session-$(date +%Y%m%d-%H%M%S)}"
TRACES_DIR=".claude/traces"
mkdir -p "$TRACES_DIR"

# Extract relevant fields per tool type
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .tool_input.command // empty' 2>/dev/null || echo "")
PATTERN=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty' 2>/dev/null || echo "")

# Build trace entry
ENTRY=$(jq -n \
  --arg ts "$TS" \
  --arg tool "$TOOL" \
  --arg file "$FILE_PATH" \
  --arg pattern "$PATTERN" \
  --arg session "$SESSION_ID" \
  '{ts: $ts, tool: $tool, session: $session, file: $file, pattern: $pattern}')

echo "$ENTRY" >> "$TRACES_DIR/session-${SESSION_ID}.jsonl"

exit 0
