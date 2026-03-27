# agent-driven

> One person + this system = a top-level R&D team.

A portable agent-driven development scaffold built on Claude Code + OpenAI Codex. COMPOSE existing tools (superpowers, gstack), don't rebuild. Initialize any project in minutes.

## Quick Start

```bash
git clone https://github.com/agent-next/agent-driven.git
cd your-project
claude "/init-project"   # Detect stack, generate config
claude "/plan Add auth"  # Plan feature with review gates
claude "/dispatch"       # Parallel agent dispatch
claude "/ship"           # Ship via gstack pipeline
```

## Architecture

```
.claude/
├── agents/        coordinator, implementer, reviewer, tester
├── skills/        /init-project, /plan, /dispatch, /ship
├── rules/         quality, git, security, context mgmt
├── hooks/         8 hooks covering full lifecycle (exit-2 blocking)
├── docs/          PROMPT, PLAN, PROGRESS, CONVENTIONS
├── templates/     CLAUDE.md + AGENTS.md by stack type
├── metrics/       Agent outcome logs (JSON-lines)
├── traces/        Action traces per session
└── memory/        episodic, procedural, pitfalls
```

## Quality Gates

1. **Spec Review** — brainstorm → plan → 3 reviewers → approve
2. **Step Verify** — lint after edit (hook), test after commit (hook), stall detection
3. **PR Review** — cross-engine review + CI
4. **Human Merge** — human decides. NEVER auto-merge.

## Design

See [docs/specs/DESIGN.md](docs/specs/DESIGN.md) for the full design spec (v2).

## License

MIT
