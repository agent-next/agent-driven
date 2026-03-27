#!/usr/bin/env bash
# PostToolUse hook: detect agent stalls
# Tracks last activity time. If called, agent is active (not stalled).
# The actual timeout is handled by maxTurns in agent definitions.
# This hook logs activity for observability.

set -uo pipefail

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
TOOL=$(jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
TRACES_DIR=".claude/traces"
mkdir -p "$TRACES_DIR"

# Append activity to current session trace
SESSION_ID="${CLAUDE_SESSION_ID:-unknown}"
echo "{\"ts\":\"$TS\",\"tool\":\"$TOOL\",\"event\":\"activity\"}" >> "$TRACES_DIR/session-$SESSION_ID.jsonl" 2>/dev/null

exit 0
