---
name: dispatch
description: Dispatch parallel agents to execute a plan. Reads PLAN.md, decomposes into tasks, routes to implementer/tester agents with wave ordering and dependency awareness.
user-invocable: true
argument-hint: "[plan-file or task description]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Agent
  - TaskCreate
  - TaskUpdate
  - TaskList
---

# /dispatch — Parallel Agent Dispatch

Dispatch agents to execute tasks from a plan. Handles wave ordering, dependency resolution, and parallel execution.

**Input:** $ARGUMENTS

## Protocol

### Step 1: Read the Plan

If a plan file is provided, read it. Otherwise, read `.claude/docs/PLAN.md`.
If no plan exists, ask the user to run `/plan` first.

### Step 2: Decompose into Tasks

For each milestone/task in the plan:
1. Identify files that will be changed
2. Identify dependencies between tasks (Task B needs Task A's types/interfaces)
3. Classify complexity: trivial (<1 file) / standard (1-3 files) / complex (4+ files)

### Step 3: Wave Planning

Group tasks into waves based on dependencies and file conflicts:

```
Wave 1: [independent tasks — no shared files, no dependencies]
  ├── All execute in parallel
  ├── Each in isolated worktree (isolation: worktree)
  └── Wait for ALL to complete

Merge Wave 1 results to main

Wave 2: [tasks that depend on Wave 1]
  ├── Rebase on updated main
  ├── Execute in parallel
  └── Wait for ALL to complete

Merge Wave 2 results
... repeat until done
```

**Conflict rule**: If two tasks edit the same file → put them in sequential waves, never parallel.

### Step 4: Dispatch

For each task in the current wave, create a TaskCreate entry and dispatch:

**1-3 tasks total**: Use CC native subagents with `isolation: worktree`
```
Agent(implementer, prompt="[task description]", isolation="worktree")
```

**4-6 tasks total**: Use CC Agent Teams
```
TaskCreate(subject="[task]", description="[full context]")
# Teammates claim and execute
```

**7+ tasks**: Dispatch sequentially in waves of 3 (merge between waves)

### Step 5: Verify Each Wave

After each wave completes:
1. SubagentStop hook verifies non-empty diff + tests pass
2. Merge completed branches to main (staged merging)
3. Run full test suite on main
4. If tests fail → dispatch fix agent → retry (max 2)
5. Log outcomes to `.claude/metrics/outcomes.jsonl`

### Step 6: Cross-Engine Review

After all waves complete:
1. Dispatch 3 reviewer agents in parallel (security, architecture, correctness)
2. If Codex was used for implementation → CC reviewer checks output
3. If CC was used → Codex reviews (via `cx exec`)
4. Collect findings as structured JSON
5. If any CRITICAL finding → block and report to human

### Step 7: Report

Update `.claude/docs/PROGRESS.md` with:
- Tasks dispatched: N
- Tasks succeeded: N
- Tasks failed: N (with reasons)
- Waves executed: N
- Total time: X minutes
- Review findings: [summary]

Suggest next action: `/ship` if all green, or fix remaining issues.
