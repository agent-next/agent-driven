# agent-driven

> One person + this system = a top-level R&D team.

A portable agent-driven development scaffold built on Claude Code + OpenAI Codex. COMPOSE existing tools (superpowers, gstack), don't rebuild. Initialize any project in minutes with parallel agent dispatch, strict quality gates, and automated review pipelines.

## Quick Start

```bash
# Clone the scaffold
git clone https://github.com/agent-next/agent-driven.git
cd your-project

# Initialize (detects stack, generates config)
claude "/init-project"

# Plan a feature
claude "/plan Add user authentication"

# Dispatch parallel agents
claude "/dispatch"

# Ship
claude "/ship"
```

## What It Does

1. **Detects your stack** (Python, TypeScript, React, etc.) and generates appropriate `.claude/` config
2. **Provides 4 specialized agents**: coordinator (routes), implementer (codes), reviewer (audits), tester (QA)
3. **Enforces quality gates** via hooks: lint after every edit, tests before merge, cross-engine review
4. **Tracks everything**: agent outcomes, action traces, cost, session memory
5. **Manages context**: 65% rotation protocol, structured handover, anti-pattern prevention

## Architecture

```
.claude/
├── agents/       4 specialized agents (coordinator, implementer, reviewer, tester)
├── skills/       Workflow skills (/init-project, /dispatch)
├── rules/        Auto-loaded quality standards, git workflow, security, context mgmt
├── hooks/        9 lifecycle hooks (guardrails enforced by exit code 2)
├── docs/         Structured project docs (WORKFLOW, PROGRESS, PLAN, PROMPT)
├── templates/    CLAUDE.md + AGENTS.md templates per stack
├── memory/       Episodic + procedural + pitfalls (structured, not flat)
├── metrics/      Agent outcome logs (JSON-lines)
└── traces/       Action traces per session (JSON-lines)
```

## Composed From

| Tool | Stars | What It Handles |
|------|-------|----------------|
| [superpowers](https://github.com/obra/superpowers) | 118K | TDD, debugging, planning, brainstorming, verification |
| [gstack](https://github.com/garrytan/gstack) | 52K | Sprint lifecycle: review, QA, ship, deploy, retro |
| [code-review plugin](https://github.com/anthropics/claude-plugins-official) | 50K+ | Multi-agent parallel PR review |
| [feature-dev plugin](https://github.com/anthropics/claude-plugins-official) | 89K+ | 7-phase guided feature development |

We build ONLY what doesn't exist: coordination layer + observability + context management.

## Quality Gates

Every piece of work passes 4 gates:

1. **Spec Review** -- 3+ reviewer agents check spec before coding starts
2. **Step Verification** -- lint after edit (hook), test after commit (hook), stall detection (5min)
3. **PR Review** -- cross-engine review (CC reviews Codex, vice versa) + CI
4. **Human Merge** -- human reviews summary + agent findings. NEVER auto-merge.

## Prerequisites

- [Claude Code](https://claude.ai/code) installed
- [Codex CLI](https://github.com/openai/codex) installed (optional, for dual-engine)
- Plugins: superpowers, gstack, code-review, feature-dev

## Design

See [docs/specs/DESIGN.md](docs/specs/DESIGN.md) for the full design spec (v2).

## Research

See [docs/research/](docs/research/) for 20 agent research reports covering 50+ frameworks.

## License

MIT
