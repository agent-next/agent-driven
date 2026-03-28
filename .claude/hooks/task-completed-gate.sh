#!/usr/bin/env bash
# TaskCompleted hook: quality gate before marking task as done
# Exit 2 = prevent completion (task stays in_progress)
# Requires: jq, git, date
# Optional: python3 (pytest), ruff, npm

# shellcheck shell=bash

set -uo pipefail

INPUT=$(cat)
TASK_ID=$(echo "$INPUT" | jq -r '.task_id // "unknown"' 2>/dev/null || echo "unknown")
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Ensure metrics directory exists
METRICS_DIR=".claude/metrics"
mkdir -p "$METRICS_DIR"

# Run tests if test runner exists
if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  TEST_OUTPUT=$(python3 -m pytest --tb=line -q --no-header 2>&1) || true
  RC=$?
  # pytest exit 5 = no tests collected (not a failure)
  if [ $RC -ne 0 ] && [ $RC -ne 5 ]; then
    echo "GATE FAILED: Tests not passing. Fix before completing task."
    echo "$TEST_OUTPUT" | tail -5
    echo "{\"ts\":\"$TS\",\"task_id\":\"$TASK_ID\",\"event\":\"task_completed_rejected\",\"reason\":\"tests_failing\"}" >> "$METRICS_DIR/outcomes.jsonl"
    exit 2
  fi
elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  TEST_OUTPUT=$(npm test 2>&1)
  RC=$?
  if [ $RC -ne 0 ]; then
    echo "GATE FAILED: Tests not passing. Fix before completing task."
    echo "$TEST_OUTPUT" | tail -5
    echo "{\"ts\":\"$TS\",\"task_id\":\"$TASK_ID\",\"event\":\"task_completed_rejected\",\"reason\":\"tests_failing\"}" >> "$METRICS_DIR/outcomes.jsonl"
    exit 2
  fi
fi

# Run lint if linter exists
if command -v ruff &>/dev/null && [ -f "pyproject.toml" ]; then
  LINT_OUTPUT=$(ruff check . 2>&1)
  RC=$?
  if [ $RC -ne 0 ]; then
    echo "GATE FAILED: Lint errors found. Fix before completing task."
    echo "$LINT_OUTPUT" | tail -5
    echo "{\"ts\":\"$TS\",\"task_id\":\"$TASK_ID\",\"event\":\"task_completed_rejected\",\"reason\":\"lint_errors\"}" >> "$METRICS_DIR/outcomes.jsonl"
    exit 2
  fi
elif [ -f "package.json" ] && grep -q '"lint"' package.json 2>/dev/null; then
  LINT_OUTPUT=$(npm run lint 2>&1)
  RC=$?
  if [ $RC -ne 0 ]; then
    echo "GATE FAILED: Lint errors found. Fix before completing task."
    echo "$LINT_OUTPUT" | tail -5
    echo "{\"ts\":\"$TS\",\"task_id\":\"$TASK_ID\",\"event\":\"task_completed_rejected\",\"reason\":\"lint_errors\"}" >> "$METRICS_DIR/outcomes.jsonl"
    exit 2
  fi
fi

# Log successful completion
echo "{\"ts\":\"$TS\",\"task_id\":\"$TASK_ID\",\"event\":\"task_completed\"}" >> "$METRICS_DIR/outcomes.jsonl"

exit 0
