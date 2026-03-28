#!/usr/bin/env bash
# SubagentStop hook: verify agent output and log outcome metrics
# Exit 2 = reject agent output (agent will be retried)
# Logs to .claude/metrics/outcomes.jsonl
# Requires: jq, git, date
# Optional: python3 (pytest), npm (npm test), sed, tr, wc

# shellcheck shell=bash

set -uo pipefail

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
METRICS_DIR=".claude/metrics"
TRACES_DIR=".claude/traces"
mkdir -p "$METRICS_DIR" "$TRACES_DIR"

# Check if agent produced any git changes
DIFF_STAT=$(git diff --stat HEAD 2>/dev/null || true)
# Fallback: try remote HEAD, then local main/master, then current branch
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' \
  || git rev-parse --verify main >/dev/null 2>&1 && echo "main" \
  || git rev-parse --verify master >/dev/null 2>&1 && echo "master" \
  || git branch --show-current 2>/dev/null \
  || echo "HEAD")
COMMITS=$(git log --oneline "$DEFAULT_BRANCH"..HEAD 2>/dev/null | wc -l | tr -d ' ')
FILES_CHANGED=$(git diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')

# Count tests (use ** glob for nested dirs, add Go/ruby patterns)
TESTS_ADDED=0
if [ -d "tests" ] || [ -d "test" ]; then
  TESTS_ADDED=$(git diff HEAD -- '**/test_*.py' '**/test_*.ts' '**/*_test.py' '**/*_test.ts' '**/*_test.go' 2>/dev/null | grep -cE '^\+def test_|^\+async def test_|^\+func Test|^\+it\(|^\+test\(' 2>/dev/null || echo "0")
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
    TEST_OUTPUT=$(python3 -m pytest --tb=line -q --no-header 2>&1) || true
    RC=$?
    # pytest exit 5 = no tests collected, not a failure
    if [ $RC -ne 0 ] && [ $RC -ne 5 ]; then
      STATUS="test_failure"
      REJECT_REASON="Tests failing: $TEST_OUTPUT"
      TEST_RESULT="fail"
    else
      TEST_RESULT="pass"
    fi
  elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
    npm test > /tmp/agent-npm-test-$$.txt 2>&1
    RC=$?
    TEST_OUTPUT=$(tail -1 /tmp/agent-npm-test-$$.txt)
    rm -f /tmp/agent-npm-test-$$.txt
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
