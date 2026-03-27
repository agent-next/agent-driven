# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

agent-driven: portable scaffold for agent-driven development using Claude Code + OpenAI Codex.

## Stack

- Shell scripts (hooks), Markdown (agents, skills, rules, docs)
- No runtime dependencies — this is a config/scaffold repo

## Commands

```bash
# Validate all hooks are executable
find .claude/hooks -name "*.sh" -exec test -x {} \; -print

# Test a hook manually
echo '{"tool_input":{"command":"git commit"}}' | bash .claude/hooks/pre-tool-branch-guard.sh

# Check scaffold structure
find .claude -type f | sort
```

## Architecture

- `.claude/agents/` — agent definitions (YAML frontmatter + system prompt)
- `.claude/skills/` — workflow automations (SKILL.md format)
- `.claude/hooks/` — lifecycle guardrails (bash, exit 2 = block)
- `.claude/rules/` — auto-loaded quality rules (markdown)
- `.claude/templates/` — CLAUDE.md/AGENTS.md per-stack templates
- `docs/specs/` — design spec
- `docs/research/` — research reports informing the design

## Conventions

- Hooks: bash, `set -euo pipefail`, exit 0/2, <5ms for tracing hooks
- Agents: YAML frontmatter + markdown body
- Rules: markdown with optional `paths:` frontmatter for scoping
- Conventional commits required
