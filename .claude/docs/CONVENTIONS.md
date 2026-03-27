# CONVENTIONS.md

Living doc. Updated when agent corrections happen.

## File Structure
- `.claude/agents/` — Agent definitions (YAML frontmatter + markdown body)
- `.claude/hooks/` — Shell scripts, exit 0=pass, 2=block
- `.claude/rules/` — Markdown rules with path-scoped frontmatter
- `.claude/docs/` — 4-file pattern: PROMPT, PLAN, PROGRESS, CONVENTIONS
- `.claude/metrics/` — JSON-lines outcome data
- `.claude/traces/` — JSON-lines action traces per session
- `.claude/memory/` — episodic/, procedural/, pitfalls/
- `.claude/templates/` — Project-type templates
- `.claude/skills/` — Custom skills

## Naming
- Hooks: `kebab-case.sh`
- Agents: `kebab-case.md`
- Rules: `kebab-case.md`
- Memory: `YYYY-MM-DD-description.md` (episodic), `description.md` (procedural/pitfalls)
- Traces: `session-{ID}.jsonl`
- Metrics: `outcomes.jsonl`, `context-rotation.jsonl`

## JSON-lines Format
All metrics and traces use JSON-lines (one JSON object per line).
Required fields: `ts` (ISO 8601 UTC), `event` or `tool` (string).
Optional fields vary by hook.

## Commit Style
- Conventional commits: `feat(scope):`, `fix(scope):`, `test:`, `docs:`, `chore:`
- One logical change per commit
- Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>

## Hook Protocol
- Exit 0: pass (allow action)
- Exit 2: block (reject action, agent receives message)
- All hooks must be `#!/usr/bin/env bash` + `set -euo pipefail`
- All hooks read JSON from stdin via `$(cat)` or `jq`
- All hooks must complete in <10s (timeout enforced by CC)
