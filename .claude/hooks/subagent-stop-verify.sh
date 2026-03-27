#!/usr/bin/env bash
# SubagentStop hook: verify agent produced meaningful output
# Exit 2 = reject agent output (agent will be retried)

set -euo pipefail

# Check if agent produced any git changes
DIFF_STAT=$(git diff --stat HEAD 2>/dev/null)
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
COMMITS=$(git log --oneline "$DEFAULT_BRANCH"..HEAD 2>/dev/null | wc -l | tr -d ' ')

if [ -z "$DIFF_STAT" ] && [ "$COMMITS" = "0" ]; then
  echo "REJECTED: Agent produced no changes. Empty output detected."
  echo "The agent may have stalled or encountered an error it didn't report."
  exit 2
fi

# Check if tests still pass (if test runner exists)
if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  RESULT=$(python3 -m pytest --tb=line -q --no-header 2>&1 | tail -1)
  if echo "$RESULT" | grep -qE "failed|error"; then
    echo "REJECTED: Tests failing after agent changes: $RESULT"
    exit 2
  fi
elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  RESULT=$(npm test 2>&1 | tail -1)
  RC=$?
  if [ $RC -ne 0 ]; then
    echo "REJECTED: Tests failing after agent changes: $RESULT"
    exit 2
  fi
fi

echo "ACCEPTED: Agent produced $COMMITS commit(s) with changes."
exit 0
