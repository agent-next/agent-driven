#!/usr/bin/env bash
# SubagentStop hook: verify agent produced meaningful output
# Exit 2 = reject agent output (agent will be retried)
# Requires: jq, git, date
# Optional: python3 (pytest), npm (npm test)

# shellcheck shell=sh

set -uo pipefail

# Check if agent produced any git changes
DIFF_STAT=$(git diff --stat HEAD 2>/dev/null || true)
# Fallback: try remote HEAD, then local main/master, then current branch
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' \
  || git rev-parse --verify main >/dev/null 2>&1 && echo "main" \
  || git rev-parse --verify master >/dev/null 2>&1 && echo "master" \
  || git branch --show-current 2>/dev/null \
  || echo "HEAD")
COMMITS=$(git log --oneline "$DEFAULT_BRANCH"..HEAD 2>/dev/null | wc -l | tr -d ' ')

if [ -z "$DIFF_STAT" ] && [ "$COMMITS" = "0" ]; then
  # Check for staged but uncommitted changes too
  STAGED=$(git diff --stat --cached HEAD 2>/dev/null || true)
  if [ -z "$STAGED" ]; then
    echo "REJECTED: Agent produced no changes. Empty output detected."
    echo "The agent may have stalled or encountered an error it didn't report."
    exit 2
  fi
fi

# Check if tests still pass (if test runner exists)
if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  RESULT=$(python3 -m pytest --tb=line -q --no-header 2>&1) || true
  RC=$?
  # pytest exit 5 = no tests collected (not a failure), exit 2 = interrupted
  if [ $RC -ne 0 ] && [ $RC -ne 5 ]; then
    echo "REJECTED: Tests failing after agent changes: $RESULT"
    exit 2
  fi
elif [ -f "package.json" ] && grep -q '"test"' package.json 2>/dev/null; then
  npm test > /tmp/agent-npm-test-$$.txt 2>&1
  RC=$?
  RESULT=$(tail -1 /tmp/agent-npm-test-$$.txt)
  rm -f /tmp/agent-npm-test-$$.txt
  if [ $RC -ne 0 ]; then
    echo "REJECTED: Tests failing after agent changes: $RESULT"
    exit 2
  fi
fi

echo "ACCEPTED: Agent produced $COMMITS commit(s) with changes."
exit 0
