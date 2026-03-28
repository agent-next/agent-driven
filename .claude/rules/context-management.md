---
description: Context window management rules for long-running agent sessions
---

# Context Management Protocol

## Session Boundaries

- One feature per session. Never mix unrelated work.
- Start each session: read PROGRESS.md + PLAN.md first.
- If continuing previous work: read ROTATION-HANDOVER.md.

## 65% Rotation Threshold

Context degrades at 65% usage (Stanford research: 15-47% performance drop as context fills).

At 60% context usage:
1. Write ROTATION-HANDOVER.md with: completed items, in-progress state, next steps, blockers
2. Commit all work
3. End session cleanly
4. Next session starts with: "Read ROTATION-HANDOVER.md and continue"

Do NOT wait for 80% auto-compaction. Proactive rotation preserves quality.

## CLAUDE.md Discipline

- Global: < 15 lines (identity + project type)
- Project: < 80 lines (stack, commands, conventions)
- Detailed rules: .claude/rules/ with path-scoped frontmatter
- Total agent-visible instructions: < 200 lines / < 2000 tokens

## Anti-Patterns to Avoid

- Kitchen sink sessions (mixing unrelated tasks)
- Correction spirals (after 2 failed attempts: /clear and restart)
- Over-specified prompts (give a map, not a manual)
- Self-evaluation (always use separate reviewer agent)
- Waiting until 80% compaction (rotate at 60-65%)
