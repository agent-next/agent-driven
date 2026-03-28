---
name: metrics
description: Query agent outcome metrics. Summarize success rates, costs, time, and quality trends from session logs.
user-invocable: true
argument-hint: "[summary|session|trends|failures]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# /metrics — Agent Outcome Dashboard

Query and display metrics from `.claude/metrics/outcomes.jsonl` and `.claude/traces/`.

**Subcommand:** $ARGUMENTS (default: summary)

## Data Sources

| File | Format | Written By |
|------|--------|------------|
| `.claude/metrics/outcomes.jsonl` | JSON-lines | subagent-stop-metrics hook |
| `.claude/metrics/context-rotation.jsonl` | JSON-lines | pre-compact-rotation hook |
| `.claude/traces/session-*.jsonl` | JSON-lines | post-tool-use-trace hook |

### Outcome Record Schema
```json
{
  "ts": "2026-03-28T12:00:00Z",
  "status": "success|empty|test_failure|timeout",
  "commits": 3,
  "files_changed": 5,
  "tests_added": 12,
  "test_result": "pass|fail|skipped"
}
```

### Trace Record Schema
```json
{
  "ts": "2026-03-28T12:00:00Z",
  "agent": "implementer",
  "action": "edit|test|commit|route",
  "file": "src/auth.py",
  "lines_changed": 45
}
```

## Subcommands

### summary (default)

Overall statistics from all recorded outcomes:

```bash
# Read and aggregate
TOTAL=$(wc -l < .claude/metrics/outcomes.jsonl 2>/dev/null || echo 0)
if [ "$TOTAL" -eq 0 ]; then
  echo "No metrics recorded yet. Run some tasks first."
  exit 0
fi

SUCCESS=$(grep -c '"status":"success"' .claude/metrics/outcomes.jsonl 2>/dev/null || echo 0)
EMPTY=$(grep -c '"status":"empty"' .claude/metrics/outcomes.jsonl 2>/dev/null || echo 0)
FAILED=$(grep -c '"status":"test_failure"' .claude/metrics/outcomes.jsonl 2>/dev/null || echo 0)
TIMEOUT=$(grep -c '"status":"timeout"' .claude/metrics/outcomes.jsonl 2>/dev/null || echo 0)

RATE=$(echo "scale=0; $SUCCESS * 100 / $TOTAL" | bc 2>/dev/null || echo "N/A")

TOTAL_COMMITS=$(jq '.commits' .claude/metrics/outcomes.jsonl 2>/dev/null | awk '{s+=$1} END {print s}' || echo 0)
TOTAL_FILES=$(jq '.files_changed' .claude/metrics/outcomes.jsonl 2>/dev/null | awk '{s+=$1} END {print s}' || echo 0)
TOTAL_TESTS=$(jq '.tests_added' .claude/metrics/outcomes.jsonl 2>/dev/null | awk '{s+=$1} END {print s}' || echo 0)
```

Display:
```
Agent Metrics Summary
─────────────────────
Tasks:       N total
Success:     N (X%)
Empty:       N
Failed:      N
Timeout:     N

Output:
  Commits:       N
  Files changed: N
  Tests added:   N

Period: [first ts] → [last ts]
```

### session

Show the current or most recent session's activity:

```bash
# Find latest session trace
LATEST=$(ls -t .claude/traces/session-*.jsonl 2>/dev/null | head -1)
if [ -z "$LATEST" ]; then
  echo "No session traces found."
  exit 0
fi

# Count tool calls by type
TOOL_BREAKDOWN=$(jq -r '.tool // .action // "unknown"' "$LATEST" | sort | uniq -c | sort -rn)

# Count edits per file
FILE_BREAKDOWN=$(jq -r '.file // empty' "$LATEST" 2>/dev/null | grep -v '^$' | sort | uniq -c | sort -rn | head -10)
```

Display:
```
Session: [session-id]
Duration: [first ts] → [last ts]
Tool calls: N total

By tool:
  Edit:    N
  Bash:    N
  Read:    N
  ...

Top files:
  src/auth.py:       N edits
  tests/test_auth.py: N edits
```

### trends

Show success rate and output trends over time (by day):

```bash
# Aggregate by date
jq -r '.ts[:10] + " " + .status' .claude/metrics/outcomes.jsonl 2>/dev/null | \
  awk '
  {
    date=$1; status=$2
    total[date]++
    if (status == "success") ok[date]++
  }
  END {
    for (d in total) printf "%s  %d/%d  (%.0f%%)\n", d, ok[d]+0, total[d], (ok[d]+0)*100/total[d]
  }' | sort
```

Display:
```
Date         Success Rate   Trend
2026-03-26   3/5 (60%)      ──
2026-03-27   7/8 (88%)      ↑↑
2026-03-28   5/5 (100%)     ↑↑
```

### failures

Show detailed failure analysis:

```bash
# Extract failure records
grep -v '"status":"success"' .claude/metrics/outcomes.jsonl 2>/dev/null | \
  jq -r '[.ts, .status, .commits, .files_changed] | @tsv'
```

Display:
```
Failures (last 30 days)
───────────────────────
2026-03-27 14:30  test_failure  2 commits  3 files
2026-03-27 09:15  empty         0 commits  0 files
...
```

For each failure, suggest:
- test_failure → "Check test output. Common cause: agent didn't account for edge case."
- empty → "Agent stalled or couldn't make changes. Check: file permissions? branch conflicts?"
- timeout → "Agent hit maxTurns. Task may be too complex — consider splitting."

## Metrics File Maintenance

If `outcomes.jsonl` grows past 10000 lines:
```bash
# Keep last 5000 entries
tail -5000 .claude/metrics/outcomes.jsonl > /tmp/metrics-tmp.jsonl
mv /tmp/metrics-tmp.jsonl .claude/metrics/outcomes.jsonl
```

If `traces/` has files older than 7 days:
```bash
find .claude/traces/ -name "*.jsonl" -mtime +7 -delete
```
