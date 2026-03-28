# PLAN.md

## Milestones

### M1: Scaffold Structure
- [ ] Agent definitions (coordinator, implementer, reviewer, tester)
- [ ] Hook scripts (lint, branch-guard, stall-detect, verify, metrics)
- [ ] Rule files (quality, git, security, context)
- [ ] Directory structure (metrics, traces, memory)
- **Acceptance**: All files present, hooks executable, agents loadable

### M2: Observability Layer
- [ ] PostToolUse trace logging
- [ ] SubagentStop metrics + verification
- [ ] PreCompact context rotation
- [ ] Session episodic memory
- **Acceptance**: Hooks produce correct JSON-lines, metrics queryable

### M3: Context Management
- [ ] 4-file doc pattern (PROMPT, PLAN, PROGRESS, CONVENTIONS)
- [ ] Structured memory (episodic, procedural, pitfalls)
- [ ] 65% rotation protocol
- **Acceptance**: PreCompact hook enforces rotation, handover works

### M4: /init-project Skill
- [ ] Stack detection (Python, React, mixed)
- [ ] CLAUDE.md template generation (<80 lines)
- [ ] AGENTS.md template generation
- [ ] Agent-readiness scoring
- **Acceptance**: Skill runs on fresh dir, generates correct config

### M5: Settings Integration
- [ ] Wire all hooks to lifecycle events
- [ ] Verify hook execution order
- [ ] Cross-engine review setup
- **Acceptance**: settings.json valid, hooks fire on correct events

## Current Wave
Phase 1: M1 → M2 → M3 → M4 → M5 (sequential, each depends on prior)
