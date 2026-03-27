# Agent-Driven Development System — Design Spec v2

> Date: 2026-03-27
> Version: 2.0 (addresses ccz review: 5/10 → target 8+/10)
> Repo: agent-next/agent-driven (new)
> Research: 20 parallel agents, 50+ OSS frameworks, 21 Anthropic + 15 OpenAI blog posts, cc-manager source audit, 14 days real dev data (427 commits, 80+ agents peak)

## Vision

**One person + this system = a top-level R&D team.**

A reusable, project-agnostic scaffold that makes any codebase agent-ready. Built on Claude Code + OpenAI Codex. COMPOSE existing tools (superpowers 118K★, gstack 52K★), don't rebuild. Custom only where no tool exists.

## Problem Statement

| Problem | Root Cause | Evidence |
|---------|-----------|----------|
| Agents crash mid-task | No checkpoint, no recovery | cc-manager: 43-50% success, 1.75x more logic errors than humans |
| Agents drift off-track | Fire-and-forget, no mid-step verification | 85% per-step = 20% over 10 steps (compound failure) |
| Guidelines ignored | CLAUDE.md = suggestions. Agents ignore ~15% of the time | Need hooks (exit code 2 = blocked, not warned) |
| Context degrades | No rotation protocol | Performance drops 15-47% as context fills. 65% = degradation threshold |
| No visibility | Can't measure success rate, cost, or quality | "You can't hit a target you can't see" |
| Scaffold not portable | CTO skill hardcoded to labclaw | Can't init a new project |

## Design Principles

1. **COMPOSE not BUILD** — Use superpowers (TDD, planning), gstack (QA, ship, review), existing CC hooks. Build ONLY what doesn't exist: coordination layer + observability.
2. **Guardrails not guidelines** — Hooks exit code 2 = blocked. CLAUDE.md = context only.
3. **Verify at every step** — lint after edit, test after commit, review after PR. Never batch verification.
4. **65% context rotation** — Rotate proactively at 60-65% usage, not at 80% auto-compaction. Structured handover.
5. **Observe everything** — Log agent actions, measure outcomes, track cost. No unmeasured targets.
6. **Map not manual** — CLAUDE.md < 200 lines. Structured docs/ directory. Path-scoped rules.
7. **Dual engine** — CC Opus (reasoning, review, coordination) + Codex GPT-5.4 (parallel implementation). Cross-engine review mandatory.

## Decision: COMPOSE, Not Rebuild

### What We USE (already installed, battle-tested)

| Tool | Stars | Covers | Our Action |
|------|-------|--------|-----------|
| superpowers | 118K★ | TDD, debugging, planning, brainstorming, code review, verification | USE as-is |
| gstack | 52K★ | Sprint lifecycle: CEO/eng/design review, QA, ship, deploy, retro | USE as-is |
| feature-dev | 89K installs | 7-phase guided feature dev with 3 agents | USE as-is |
| code-review | 50K installs | Multi-agent parallel PR review | USE as-is |
| pr-review-toolkit | installed | Silent-failure-hunter, type-design, test-analyzer | USE as-is |
| context7 | 72K installs | Live library docs in context | USE as-is |
| ralph-loop | 57K installs | Autonomous multi-hour coding sessions | USE for /overnight |

### What We BUILD (no existing tool covers this)

| Component | Why It Doesn't Exist | Effort |
|-----------|---------------------|--------|
| **Coordinator agent** | Routes tasks to right engine/model/skill. No tool does dual-engine routing. | 15h |
| **Observability hooks** | Agent outcome metrics, action tracing, cost tracking. CC hooks exist but nobody ships a pre-built observability kit. | 20h |
| **Context management protocol** | 65% rotation, handover docs, session boundaries. Research-backed but no tool implements it. | 10h |
| **AGENTS.md + CLAUDE.md templates** | Project-type-specific templates (Python/FastAPI, React/Next.js, etc.) with <200 line discipline. | 10h |
| **Event-driven triggers** | git post-receive → dispatch agent, CI failure → dispatch fixer. Simple shell hooks, not a framework. | 10h |
| **Structured agent memory** | Episodic (what worked/failed) + procedural (learned workflows). Beyond flat MEMORY.md. | 15h |

### What We FIX (cc-manager v2 — separate spec)

cc-manager v2 is a **separate project** with its own spec, not part of this scaffold. This scaffold works WITHOUT cc-manager. cc-manager is an optional acceleration layer for heavy parallel work (10+ tasks).

cc-manager v2 spec will be written separately and tracked at `agent-next/cc-manager`.

## Architecture: Single Layer + Optional Engine

```
┌─────────────────────────────────────────────────────────────────┐
│  agent-next/agent-driven                                         │
│  Portable scaffold — works for ANY project                       │
│                                                                  │
│  .claude/                                                        │
│  ├── agents/        Coordinator, Implementer, Reviewer, Tester   │
│  ├── skills/        /init, /plan (→superpowers), /review-all     │
│  │                  /dispatch, /ship (→gstack), /overnight        │
│  ├── rules/         Quality, git workflow, security, context mgmt │
│  ├── hooks/         Guardrails (12 hooks covering 8 lifecycle     │
│  │                  events, all exit-code-2 capable)              │
│  ├── docs/          Structured map (ARCHITECTURE, CONVENTIONS,    │
│  │                  WORKFLOW, PROGRESS)                           │
│  └── templates/     CLAUDE.md + AGENTS.md by project type        │
│                                                                  │
│  Observability Layer                                             │
│  ├── .claude/metrics/     Agent outcome logs (JSON-lines)        │
│  ├── .claude/traces/      Action traces per session              │
│  └── .claude/memory/      Structured episodic + procedural       │
│                                                                  │
│  Optional: cc-manager v2 (separate repo, separate spec)          │
│  └── Called via /dispatch skill when task count > threshold       │
└─────────────────────────────────────────────────────────────────┘
```

### Degraded Mode (without cc-manager)

The scaffold works standalone using CC native features:
- **1-3 tasks**: CC subagents with `isolation: worktree`
- **4-6 tasks**: CC Agent Teams with shared task list
- **7+ tasks**: Sequential waves (dispatch 3, wait, merge, dispatch next 3)
- **10+ tasks**: Requires cc-manager v2 (optional upgrade)

This resolves the ccz review's "what if cc-manager isn't available?" concern.

## Agent Definitions

### coordinator.md (the only new agent)
```yaml
name: coordinator
description: Routes tasks to the right engine, model, and skill. Manages dispatch and merge decisions.
model: opus
permissionMode: default
tools: [Read, Glob, Grep, Bash, Agent, TaskCreate, TaskUpdate, TaskList]
memory: project
skills: [superpowers:dispatching-parallel-agents, superpowers:writing-plans]
```
- Reads task/spec → classifies complexity → routes to implementer (Codex) or CC subagent
- Manages wave ordering (dependency-aware)
- Triggers cross-engine review after implementation
- Logs all decisions to `.claude/traces/`

### implementer.md
```yaml
name: implementer
description: Focused code implementation. One task per agent. Commits after each passing test.
model: inherit
isolation: worktree
maxTurns: 50
tools: [Read, Write, Edit, Bash, Glob, Grep]
hooks:
  PostToolUse:
    - matcher: "Edit|Write"
      hooks: [{type: command, command: "ruff check --fix $FILE && ruff format $FILE", timeout: 10}]
  Stop:
    - hooks: [{type: command, command: "pytest --tb=short -q 2>/dev/null; echo exit:$?"}]
```
- Runs lint after every edit (hook-enforced, not guideline)
- Runs tests on stop (hook-enforced)
- One focused task, one worktree

### reviewer.md
```yaml
name: reviewer
description: Code review for security, architecture, and correctness. Reports structured findings.
model: sonnet
permissionMode: plan
tools: [Read, Glob, Grep, WebSearch]
```
- 3 instances run in parallel (security, architecture, correctness)
- Reports findings as JSON: `{severity, file, line, issue, suggestion}`
- Cross-engine: CC reviewer checks Codex output, vice versa

### tester.md
```yaml
name: tester
description: Generate tests from specs, run test suite, report coverage gaps.
model: haiku
isolation: worktree
tools: [Read, Write, Edit, Bash, Glob, Grep]
```

## Quality Gate Pipeline

```
Gate 1: SPEC REVIEW (pre-implementation)
  Uses: superpowers:brainstorming → superpowers:writing-plans
  Hook: TaskCreated → validate spec has acceptance criteria
  Reviewers: 3 parallel (security, arch, feasibility)
  Block: ANY reviewer CRITICAL finding = redesign

Gate 2: STEP VERIFICATION (during implementation)
  Hook: PostToolUse(Edit|Write) → auto-lint + typecheck (exit 2 on failure)
  Hook: PostToolUse(Bash) → if git commit, run related tests
  Hook: stall-detector → 5min no meaningful output = kill + context-aware retry
  Hook: SubagentStop → verify non-empty diff + tests pass

Gate 3: PR REVIEW (post-implementation)
  Uses: code-review plugin + pr-review-toolkit
  Cross-engine: CC reviews Codex code, Codex reviews CC code
  CI: ALL checks must pass (merge-gate pattern)
  Hook: TaskCompleted → tests pass + lint clean + coverage not decreased

Gate 4: HUMAN MERGE (final)
  Human reviews: PR summary + agent findings + metrics
  One-click merge when all gates green
  NEVER auto-merge. Human decides.
```

## Observability (P0 — resolves "can't measure" problem)

### Agent Outcome Metrics
```
.claude/metrics/outcomes.jsonl
{"ts":"2026-03-27T15:00:00Z","agent":"implementer","task":"add-auth","status":"success","duration_s":340,"tokens":45000,"cost_usd":0.67,"commits":3,"tests_added":5,"files_changed":4}
```
Logged by: SubagentStop hook + TaskCompleted hook.

### Action Traces
```
.claude/traces/session-abc123.jsonl
{"ts":"...","agent":"coordinator","action":"route","task":"add-auth","decision":"codex-implementer","reason":"3 files, moderate complexity"}
{"ts":"...","agent":"implementer","action":"edit","file":"src/auth.py","lines_changed":45}
{"ts":"...","agent":"implementer","action":"test","result":"pass","coverage":"87%"}
```
Logged by: PostToolUse hook (lightweight, <5ms overhead).

### Cost Dashboard
```bash
# Built-in CLI in /metrics skill
claude "/metrics summary"
# Output: This week: 47 tasks, 38 success (81%), $12.40 total, avg $0.26/task
```

## Context Management Protocol (P0 — resolves "context rot")

### Session Boundaries
1. One feature per session (never mix unrelated work)
2. Start each session: read PROGRESS.md + feature_list.json
3. Monitor context usage via statusline (already configured)

### 65% Rotation Protocol
```
At 60% context usage:
  1. Write ROTATION-HANDOVER.md:
     - Completed: [list of done items]
     - In Progress: [current state, what's working, what's not]
     - Next Steps: [specific actionable items]
     - Blockers: [anything that needs human input]
  2. Commit all work
  3. Start fresh session with: "Read ROTATION-HANDOVER.md and continue"

Hook: PreCompact → warn at 60%, force handover at 70%
```

### CLAUDE.md Discipline
- Global CLAUDE.md: < 15 lines (identity + project context)
- Project CLAUDE.md: < 80 lines (stack, commands, conventions)
- Detailed rules: `.claude/rules/` with path-scoped frontmatter
- Total agent-visible instructions: < 200 lines / < 2000 tokens

### 4-File Memory Pattern (from OpenAI Codex long-horizon)
```
.claude/docs/
├── PROMPT.md          # Frozen spec (what to build, never edited mid-session)
├── PLAN.md            # Milestones with acceptance criteria (updated on completion)
├── PROGRESS.md        # Live audit log (who did what, when, result)
└── CONVENTIONS.md     # Coding conventions (updated when agent corrections happen)
```
- PROMPT.md created by `/plan` skill, frozen
- PLAN.md created by coordinator, updated on milestone completion
- PROGRESS.md append-only, updated by hooks
- CONVENTIONS.md living doc, updated on correction

## Structured Agent Memory (P0 — resolves "flat MEMORY.md")

### Three Memory Types
```
.claude/memory/
├── episodic/          # What happened in past sessions
│   ├── 2026-03-27-add-auth.md    # Session summary: what worked, what failed
│   └── 2026-03-28-fix-perf.md
├── procedural/        # Learned workflows
│   ├── python-fastapi-feature.md  # "When adding a FastAPI endpoint, always..."
│   └── react-component.md         # "When creating React components, always..."
└── pitfalls/          # Verified failure patterns (like refs/agent-pitfalls.md)
    ├── typescript-import-extensions.md
    └── pytest-async-fixtures.md
```
- **Episodic**: auto-generated by Stop hook from session trace
- **Procedural**: manually curated from recurring patterns
- **Pitfalls**: auto-appended when an agent fails + fix is found

## Anti-Pattern Coverage (resolves "6/20 addressed")

| Anti-Pattern | How Addressed |
|-------------|---------------|
| Kitchen sink session | Rule: one feature per session. Coordinator enforces. |
| Correction spiral | Rule: after 2 failed corrections, /clear and restart with better prompt. Hook monitors correction count. |
| Infinite exploration | architect.md is plan mode (read-only). maxTurns: 50 on implementer. |
| Over-specified CLAUDE.md | < 200 lines rule. Path-scoped rules in .claude/rules/. |
| Trust-then-verify gap | 4-gate pipeline. Verify at every step. |
| One-shotting projects | Task decomposition via coordinator. One task per agent. |
| Premature completion | SubagentStop hook verifies non-empty diff + tests pass. |
| No progress docs | PROGRESS.md append-only log. Updated by hooks. |
| Time blindness | Stall detection: 5min no output = kill. |
| Self-evaluation bias | Cross-engine review. Separate reviewer agents. |
| Reactive /clear | 65% rotation protocol. PreCompact hook warns at 60%. |
| Context pressure | Monitor via statusline. Proactive rotation, not reactive. |
| Over-specification | CLAUDE.md < 200 lines. Map not manual. |
| Generic defaults | Project-type templates (Python, React, etc.) |
| Ignoring skill context | Coordinator reads installed skills before routing. |
| 1.75x logic errors | Mandatory test gate. Cross-engine review. |
| DB schema decisions | architect.md designs schema. Never let implementer decide schema. |
| Agentic laziness | SubagentStop verifies meaningful output. Completion check mandatory. |
| Single-point testing | 3 parallel reviewers + CI + human. |
| Browser alerts | N/A (terminal-based). |

## Implementation Phases (revised estimates)

### Phase 1: Scaffold + Observability (2 weeks, ~60h)
**Deliverables**: agent-next/agent-driven repo with working scaffold
1. Create repo structure (agents, skills, rules, hooks, docs, templates) — 10h
2. Build coordinator agent + routing logic — 15h
3. Build observability hooks (metrics, traces, cost) — 15h
4. Build context management protocol (rotation, handover, memory) — 10h
5. Build `/init-project` skill (detect stack, generate config) — 10h
6. Test on 3 different projects (Python, React, mixed) — verify portability

**Exit criteria**: Fresh project runs `/init-project`, dispatches 3 agents in parallel, all 4 gates work, metrics logged.

### Phase 2: Integration + Event Triggers (2 weeks, ~50h)
**Deliverables**: Full skill suite integrated with existing plugins
1. Build `/dispatch` skill (wave planning, coordinator routing) — 15h
2. Build event-driven triggers (git hooks, CI failure → agent) — 10h
3. Build structured memory system (episodic, procedural, pitfalls) — 10h
4. Integrate with gstack /ship and /review — 5h
5. Build AGENTS.md + CLAUDE.md templates per project type — 5h
6. Test on labclaw Phase 0 work (real production tasks) — 5h

**Exit criteria**: labclaw Phase 0 tasks completed via scaffold. Event triggers fire correctly. Memory persists across sessions.

### Phase 3: cc-manager v2 (separate spec, ~100h)
**This phase has its own design spec at agent-next/cc-manager.**
Core fixes: staged merging, wave planning, error recovery, conflict resolution.
Only started AFTER Phase 1+2 are validated.

### Phase 4: Polish + Documentation (1 week, ~20h)
1. README with Day 1 walkthrough — 5h
2. `/overnight` skill (ralph-loop integration) — 5h
3. Agent Legibility Scorecard (agent-ready CI gate) — 5h
4. MetaBot integration (Telegram control plane) — 5h

**Total: ~130h (Phase 1+2+4) + ~100h (Phase 3, separate)**

## Day 1 Scenario (resolves "no user journey")

```bash
# 1. Clone the scaffold
git clone agent-next/agent-driven
cd my-new-project

# 2. Initialize (detects Python/FastAPI, generates config)
claude "/init-project"
# → Creates .claude/ with agents, skills, rules, hooks
# → Creates CLAUDE.md (<80 lines) + AGENTS.md
# → Creates .claude/docs/ (ARCHITECTURE, CONVENTIONS, WORKFLOW, PROGRESS)
# → Runs agent-ready check, reports score

# 3. Plan a feature
claude "/plan Add user authentication with JWT"
# → superpowers:brainstorming → spec → 3 reviewers → approved plan
# → Saves to .claude/docs/PROMPT.md (frozen) + PLAN.md (milestones)

# 4. Implement
claude "/dispatch"
# → Coordinator reads PLAN.md → decomposes into 4 tasks
# → Routes: 2 to Codex implementers (parallel worktrees), 1 to CC, 1 to tester
# → Each agent: implement → lint (hook) → test (hook) → commit
# → Cross-engine review on completion
# → PR created per task

# 5. Ship
claude "/ship"
# → gstack: run all tests → check CI → create PR → wait for human merge

# 6. Check metrics
claude "/metrics summary"
# → 4 tasks, 3 success, 1 retry+success, $2.10 total, 45min elapsed
```

## Failure Modes (resolves "no failure definition")

| Failure | Detection | Recovery | Escalation |
|---------|-----------|----------|-----------|
| Agent stalls (no output 5min) | stall-detector hook | Kill + retry with fresh context | After 2 retries → report to human |
| Agent drifts (wrong direction) | SubagentStop hook checks diff relevance | /clear + restart with tighter spec | Human reviews spec |
| Merge conflict | git merge exit code | Dispatch conflict-resolver agent | After 2 attempts → human resolves |
| Tests fail after edit | PostToolUse hook | Agent receives error, fixes in next turn | After 3 cycles → escalate |
| Budget exceeded | Cost tracking hook | Pause dispatch, report to human | Human decides: continue or abort |
| Context at 65% | PreCompact hook | Force rotation with ROTATION-HANDOVER.md | Automatic, no human needed |
| CI fails on PR | TaskCompleted hook | Dispatch fixer agent for CI errors | After 2 fixes → human reviews |
| Cross-repo dependency | Coordinator detects via ARCHITECTURE.md | Flag to human, don't auto-fix | Human decides scope |

## Task State Machine (resolves "no state definition")

```
PLANNED → DISPATCHED → RUNNING → VERIFYING → COMPLETED → MERGED
                         │          │            │
                         ▼          ▼            ▼
                      STALLED    FAILED      CONFLICT
                         │          │            │
                         ▼          ▼            ▼
                      RETRYING  ESCALATED    RESOLVING
                         │                       │
                         └───────→ RUNNING ←─────┘
```

Valid transitions:
- PLANNED → DISPATCHED (coordinator assigns agent)
- DISPATCHED → RUNNING (agent starts work)
- RUNNING → VERIFYING (agent completes, hooks run)
- RUNNING → STALLED (5min no output)
- VERIFYING → COMPLETED (all gates pass)
- VERIFYING → FAILED (gate fails)
- COMPLETED → MERGED (human approves)
- COMPLETED → CONFLICT (merge conflict detected)
- STALLED → RETRYING (auto-retry with fresh context)
- FAILED → RETRYING (retry with error context, max 2)
- FAILED → ESCALATED (after 2 retries)
- CONFLICT → RESOLVING (conflict-resolver agent)
- RESOLVING → RUNNING (conflict fixed, re-verify)
- RETRYING → RUNNING (fresh attempt)

## Success Metrics (with instrumentation)

| Metric | Current | Target | How Measured |
|--------|---------|--------|-------------|
| Task success rate | ~50% | 80%+ | `.claude/metrics/outcomes.jsonl` |
| Agent crash rate | ~15% | <5% | stall-detector + SubagentStop logs |
| Time to first PR (new project) | Hours | <30 min | `/init-project` → first `/dispatch` |
| Quality gate pass rate | Unknown | >90% | Gate pass/fail logged per task |
| Context rotation compliance | 0% | 100% | PreCompact hook logs |
| Cross-session knowledge reuse | 0% | >50% sessions | Memory read count at session start |
| Cost per successful task | Unknown | <$1 avg | metrics/outcomes.jsonl |

## Open Questions (resolved)

| Question | Decision | Rationale |
|----------|----------|-----------|
| cc-manager: Elixir or TypeScript? | **TypeScript** (keep) | Rewrite is 50-100h. Fix the 4 issues in existing TS. Elixir only if TS proves inadequate. |
| MetaSkill or own /init-project? | **Own /init-project** | MetaSkill generates generic configs. We need stack-specific templates with our observability hooks. |
| agent-ready as CI gate? | **Yes, Phase 4** | Low cost, high signal. `npx agent-ready check .` in CI. |
| Cross-repo dependencies? | **Manual for v1** | Coordinator flags via ARCHITECTURE.md. Human decides. Auto-detection is Phase 3+. |

## What We DON'T Build

- No custom LLM — use Claude + Codex as-is
- No custom IDE — terminal (CC) + any editor
- No custom TDD framework — superpowers handles this
- No custom QA/browser — gstack handles this
- No custom code review — code-review + pr-review-toolkit handle this
- No custom planning — superpowers brainstorming + writing-plans handle this
- No web dashboard for v1
- No multi-tenant — single user system
- No cc-manager v2 in this repo (separate spec, separate repo)
