#!/usr/bin/env bash
# SubagentStop hook: verify agent output and log outcome metrics
# Exit 2 = reject agent output (agent will be retried)
# Logs to .claude/metrics/outcomes.jsonl

set -euo pipefail

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
METRICS_DIR=".claude/metrics"
TRACES_DIR=".claude/traces"
mkdir -p "$METRICS_DIR" "$TRACES_DIR"

# Check if agent produced any git changes
DIFF_STAT=$(git diff --stat HEAD 2>/dev/null || echo "")
COMMITS=$(git log --oneline main..HEAD 2>/dev/null | wc -l | tr -d ' ')
FILES_CHANGED=$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')

# Count tests
TESTS_ADDED=0
if [ -d "tests" ] || [ -d "test" ]; then
  TESTS_ADDED=$(git diff HEAD -- '*/test_*.py' '*/test_*.ts' '*_test.py' '*_test.ts' 2>/dev/null | grep -c "^+def test_\|^+async def test_\|^+it('\|^+test(" 2>/dev/null || echo "0")
fi

# Determine status
STATUS="success"
REJECT_REASON=""

if [ -z "$DIFF_STAT" ] && [ "$COMMITS" = "0" ]; then
  STATUS="empty"
  REJECT_REASON="No changes produced"
fi

# Check if tests pass (if test runner exists)
TEST_RESULT="skipped"
if [ "$STATUS" = "success" ]; then
  if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    TEST_OUTPUT=$(python3 -m pytest --tb=line -q --no-header 2>&1 | tail -1)
    if echo "$TEST_OUTPUT" | grep -qE "failed|error"; then
      STATUS="test_failure"
      REJECT_REASON="Tests failing: $TEST_OUTPUT"
      TEST_RESULT="fail"
    else
      TEST_RESULT="pass"
    fi
  elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
    TEST_OUTPUT=$(npm test 2>&1 | tail -1)
    RC=$?
    if [ $RC -ne 0 ]; then
      STATUS="test_failure"
      REJECT_REASON="Tests failing: $TEST_OUTPUT"
      TEST_RESULT="fail"
    else
      TEST_RESULT="pass"
    fi
  fi
fi

# Log outcome
OUTCOME=$(jq -n \
  --arg ts "$TS" \
  --arg status "$STATUS" \
  --arg commits "$COMMITS" \
  --arg files_changed "$FILES_CHANGED" \
  --arg tests_added "$TESTS_ADDED" \
  --arg test_result "$TEST_RESULT" \
  '{ts: $ts, status: $status, commits: ($commits | tonumber), files_changed: ($files_changed | tonumber), tests_added: ($tests_added | tonumber), test_result: $test_result}')

echo "$OUTCOME" >> "$METRICS_DIR/outcomes.jsonl"

# Reject if empty or tests fail
if [ "$STATUS" = "empty" ]; then
  echo "REJECTED: Agent produced no changes. Empty output detected."
  exit 2
fi

if [ "$STATUS" = "test_failure" ]; then
  echo "REJECTED: $REJECT_REASON"
  exit 2
fi

echo "ACCEPTED: $COMMITS commit(s), $FILES_CHANGED file(s) changed, $TESTS_ADDED test(s) added."
exit 0
