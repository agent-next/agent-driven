#!/usr/bin/env bash
# Test suite for agent-driven hooks
# Run: bash tests/test_hooks.sh
# Exit: 0 = all pass, 1 = some fail

set -uo pipefail

PASS=0
FAIL=0
HOOKS_DIR=".claude/hooks"
TEST_DIR=$(mktemp -d)
ORIG_DIR=$(pwd)

cleanup() {
  rm -rf "$TEST_DIR"
  cd "$ORIG_DIR"
}
trap cleanup EXIT

pass() { PASS=$((PASS + 1)); echo "  PASS: $1"; }
fail() { FAIL=$((FAIL + 1)); echo "  FAIL: $1"; }

# --- Helper: run a hook with stdin, capture exit code ---
run_hook() {
  local hook="$1"
  local stdin="${2:-}"
  echo "$stdin" | bash "$HOOKS_DIR/$hook" 2>&1
  return $?
}

echo "=== Agent-Driven Hook Tests ==="
echo ""

# --- Test 1: pre-compact-rotation.sh handles float context ---
echo "Test 1: pre-compact-rotation.sh — float context percentage"
cd "$TEST_DIR"
mkdir -p .claude/metrics
# Simulate 72.5% context (float)
RESULT=$(echo '{"context_usage_percent": 72.5}' | bash "$ORIG_DIR/$HOOKS_DIR/pre-compact-rotation.sh" 2>&1) || RC=$? || true
RC=${RC:-0}
if [ $RC -eq 2 ] && echo "$RESULT" | grep -q "CONTEXT ROTATION REQUIRED"; then
  pass "rejects with exit 2 at 72.5% float"
else
  fail "expected exit 2 at 72.5%, got RC=$RC output=$RESULT"
fi
unset RC

# --- Test 2: pre-compact-rotation.sh passes at 40% ---
echo "Test 2: pre-compact-rotation.sh — below threshold passes"
RESULT=$(echo '{"context_usage_percent": 40}' | bash "$ORIG_DIR/$HOOKS_DIR/pre-compact-rotation.sh" 2>&1) || RC=$? || true
RC=${RC:-0}
if [ $RC -eq 0 ]; then
  pass "passes at 40%"
else
  fail "expected exit 0 at 40%, got RC=$RC"
fi
unset RC

# --- Test 3: pre-compact-rotation.sh warns at 58% ---
echo "Test 3: pre-compact-rotation.sh — warning at 58%"
cd "$TEST_DIR"
mkdir -p .claude/metrics
RESULT=$(echo '{"context_usage_percent": 58}' | bash "$ORIG_DIR/$HOOKS_DIR/pre-compact-rotation.sh" 2>&1) || RC=$? || true
RC=${RC:-0}
if [ $RC -eq 0 ] && echo "$RESULT" | grep -q "WARNING"; then
  pass "warns at 58%"
else
  fail "expected warning at 58%, got RC=$RC output=$RESULT"
fi
unset RC

# --- Test 4: post-edit-lint.sh always exits 0 ---
echo "Test 4: post-edit-lint.sh — always non-blocking"
echo '{}' | bash "$ORIG_DIR/$HOOKS_DIR/post-edit-lint.sh" 2>&1; RC=$?
if [ $RC -eq 0 ]; then
  pass "always exits 0"
else
  fail "expected exit 0, got $RC"
fi
unset RC

# --- Test 5: stall-detector.sh exits 0 and creates trace ---
echo "Test 5: stall-detector.sh — logs activity and exits 0"
cd "$TEST_DIR"
export CLAUDE_SESSION_ID="test-session-123"
echo '{"tool_name":"Edit"}' | bash "$ORIG_DIR/$HOOKS_DIR/stall-detector.sh" 2>&1; RC=$?
if [ $RC -eq 0 ] && [ -f ".claude/traces/session-test-session-123.jsonl" ]; then
  pass "creates trace file and exits 0"
else
  fail "expected trace file, got RC=$RC"
fi
unset RC
unset CLAUDE_SESSION_ID

# --- Test 6: subagent-stop-verify.sh rejects empty output ---
echo "Test 6: subagent-stop-verify.sh — rejects no changes"
cd "$TEST_DIR"
git init -q
git commit --allow-empty -m "init" -q
echo '{}' | bash "$ORIG_DIR/$HOOKS_DIR/subagent-stop-verify.sh" 2>&1; RC=$?
if [ $RC -eq 2 ]; then
  pass "rejects empty agent output"
else
  fail "expected exit 2, got $RC"
fi
unset RC

# --- Test 7: subagent-stop-verify.sh accepts with changes ---
echo "Test 7: subagent-stop-verify.sh — accepts with file changes"
cd "$TEST_DIR"
# Create a feature branch so commits ahead of main are detectable
git checkout -b feat/test-change -q
echo "test content" > test_file.txt
git add test_file.txt
git commit -m "add file" -q
bash "$ORIG_DIR/$HOOKS_DIR/subagent-stop-verify.sh" 2>&1; RC=$?
if [ $RC -eq 0 ]; then
  pass "accepts when changes exist"
else
  fail "expected exit 0, got $RC"
fi
unset RC

# --- Test 8: settings.json is valid JSON ---
echo "Test 8: settings.json — valid JSON with all hooks wired"
cd "$ORIG_DIR"
if jq empty .claude/settings.json 2>/dev/null; then
  HOOK_COUNT=$(jq '[.hooks | to_entries[] | .value[] | .hooks | length] | add' .claude/settings.json)
  if [ "$HOOK_COUNT" -ge 9 ]; then
    pass "settings.json valid with $HOOK_COUNT hook entries"
  else
    fail "expected >=9 hook entries, got $HOOK_COUNT"
  fi
else
  fail "settings.json is not valid JSON"
fi

# --- Test 9: all hooks are executable ---
echo "Test 9: all hooks — executable permission"
ALL_EXEC=true
for hook in "$HOOKS_DIR"/*.sh; do
  if [ ! -x "$hook" ]; then
    fail "$(basename $hook) not executable"
    ALL_EXEC=false
  fi
done
if $ALL_EXEC; then
  pass "all hooks are executable"
fi

# --- Test 10: branch-guard blocks main commits ---
echo "Test 10: pre-tool-branch-guard.sh — blocks git commit on main"
cd "$TEST_DIR"
rm -rf repo_test && mkdir repo_test && cd repo_test
git init -q
# Rename current branch to main
git checkout -b main 2>/dev/null || git branch -m main 2>/dev/null
git commit --allow-empty -m "init" -q
echo '{"tool_input":{"command":"git commit -m test"}}' | bash "$ORIG_DIR/$HOOKS_DIR/pre-tool-branch-guard.sh" 2>&1; RC=$?
if [ $RC -eq 2 ]; then
  pass "blocks commit on main"
else
  fail "expected exit 2 on main, got $RC"
fi
unset RC

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ $FAIL -eq 0 ] && exit 0 || exit 1
