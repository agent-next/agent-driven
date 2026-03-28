#!/usr/bin/env bash
# PreCompact hook: enforce 65% context rotation protocol
# Warns at 55%, forces ROTATION-HANDOVER.md at 65%
# Exit 2 = block compaction, force handover instead
# Requires: jq, date

# shellcheck shell=sh

set -uo pipefail

INPUT=$(cat)
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Extract context usage percentage (CC provides this in PreCompact event)
# Default to 65 if not parseable. Truncate float to int for bash comparison.
CONTEXT_PCT=$(echo "$INPUT" | jq -r '.context_usage_percent // 65' 2>/dev/null || echo "65")
CONTEXT_INT=${CONTEXT_PCT%.*}
CONTEXT_INT=${CONTEXT_INT:-0}

METRICS_DIR=".claude/metrics"
mkdir -p "$METRICS_DIR"

# Log context event
echo "{\"ts\":\"$TS\",\"event\":\"pre_compact\",\"context_pct\":$CONTEXT_PCT}" >> "$METRICS_DIR/context-rotation.jsonl"

if [ "$CONTEXT_INT" -ge 65 ]; then
  echo "=== CONTEXT ROTATION REQUIRED (at ${CONTEXT_PCT}%) ==="
  echo "Write ROTATION-HANDOVER.md NOW with:"
  echo "  1. Completed: [list of done items]"
  echo "  2. In Progress: [current state, what's working, what's not]"
  echo "  3. Next Steps: [specific actionable items]"
  echo "  4. Blockers: [anything that needs human input]"
  echo ""
  echo "Then commit all work and start a fresh session:"
  echo "  'Read ROTATION-HANDOVER.md and continue'"
  echo ""
  echo "Do NOT let context auto-compact. Proactive rotation preserves quality."
  exit 2
elif [ "$CONTEXT_INT" -ge 55 ]; then
  echo "=== CONTEXT WARNING (at ${CONTEXT_PCT}%) ==="
  echo "Approaching rotation threshold. Consider wrapping up current subtask"
  echo "and preparing ROTATION-HANDOVER.md for a clean session handover."
  echo ""
  echo "At 65%: rotation becomes MANDATORY (hook will block)."
  exit 0
fi

exit 0
