#!/usr/bin/env bash
# TaskCompleted hook: quality gate before marking task as done
# Exit 2 = prevent completion (task stays in_progress)

# Log the completion attempt
TASK_ID=$(jq -r '.task_id // "unknown"' 2>/dev/null || echo "unknown")
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Ensure metrics directory exists
METRICS_DIR=".claude/metrics"
mkdir -p "$METRICS_DIR"

# Log task outcome
echo "{\"ts\":\"$TS\",\"task_id\":\"$TASK_ID\",\"event\":\"task_completed\"}" >> "$METRICS_DIR/outcomes.jsonl"

exit 0
