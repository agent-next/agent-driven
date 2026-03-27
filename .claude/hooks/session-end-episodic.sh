#!/usr/bin/env bash
# Stop hook: generate episodic memory from session trace
# Runs at session end to auto-create session summary in .claude/memory/episodic/

set -euo pipefail

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
DATE=$(date +%Y-%m-%d)
EPISODIC_DIR=".claude/memory/episodic"
TRACES_DIR=".claude/traces"
METRICS_DIR=".claude/metrics"
mkdir -p "$EPISODIC_DIR"

# Find latest session trace
LATEST_TRACE=$(ls -t "$TRACES_DIR"/session-*.jsonl 2>/dev/null | head -1 || echo "")

if [ -z "$LATEST_TRACE" ]; then
  exit 0
fi

# Extract summary stats from trace
TOOL_COUNT=$(wc -l < "$LATEST_TRACE" | tr -d ' ')
EDIT_COUNT=$(grep -c '"tool":"Edit"' "$LATEST_TRACE" 2>/dev/null) || EDIT_COUNT=0
BASH_COUNT=$(grep -c '"tool":"Bash"' "$LATEST_TRACE" 2>/dev/null) || BASH_COUNT=0
FILES_TOUCHED=$(grep '"tool":"Edit"' "$LATEST_TRACE" 2>/dev/null | jq -r '.file' 2>/dev/null | sort -u | head -10 || echo "")

# Extract metrics
LATEST_METRICS=$(ls -t "$METRICS_DIR"/outcomes.jsonl 2>/dev/null | head -1 || echo "")
OUTCOMES=""
if [ -n "$LATEST_METRICS" ]; then
  OUTCOMES=$(tail -5 "$LATEST_METRICS" 2>/dev/null || echo "")
fi

# Generate episodic memory file
MEM_FILE="$EPISODIC_DIR/${DATE}-session.md"
{
  echo "---"
  echo "date: $DATE"
  echo "tools_used: $TOOL_COUNT"
  echo "edits: $EDIT_COUNT"
  echo "commands: $BASH_COUNT"
  echo "---"
  echo ""
  echo "# Session Summary $DATE"
  echo ""
  echo "## Activity"
  echo "- Tool calls: $TOOL_COUNT"
  echo "- File edits: $EDIT_COUNT"
  echo "- Shell commands: $BASH_COUNT"
  echo ""
  if [ -n "$FILES_TOUCHED" ]; then
    echo "## Files Modified"
    echo "$FILES_TOUCHED" | while read -r f; do
      [ -n "$f" ] && echo "- \`$f\`"
    done
    echo ""
  fi
  if [ -n "$OUTCOMES" ]; then
    echo "## Outcomes"
    echo '```json'
    echo "$OUTCOMES"
    echo '```'
  fi
} > "$MEM_FILE"

exit 0
