---
name: init-project
description: Initialize agent-driven development for a project. Detects stack, generates CLAUDE.md, AGENTS.md, docs/, hooks, and reports agent-readiness score. Use when setting up a new or existing project for agent-driven development.
---

You are running `/init-project` — the one-command setup that makes any project agent-ready.

## Step 1: Detect Project Stack

Scan the project root for these indicator files:

| File(s) Detected | Stack | Template |
|---|---|---|
| `pyproject.toml` or `setup.py` or `requirements.txt` | Python | `python` |
| `package.json` + `"next"` in deps | Next.js | `nextjs` |
| `package.json` + `"react"` in deps | React | `react` |
| `package.json` (no react/next) | Node.js | `node` |
| `go.mod` | Go | `go` |
| `Cargo.toml` | Rust | `rust` |
| `Makefile` + any of above | Mixed | `mixed` |
| `Dockerfile` or `docker-compose.yml` | Containerized | append `_docker` |
| `pyproject.toml` + `package.json` | Full-stack | `fullstack` |

Detection command:
```bash
ls -1 pyproject.toml setup.py requirements.txt package.json go.mod Cargo.toml Dockerfile docker-compose.yml 2>/dev/null
```

If `package.json` exists, check for react/next:
```bash
jq -r '.dependencies // {} | keys[]' package.json 2>/dev/null | grep -qE 'react|next'
```

## Step 2: Generate Configuration Files

### 2a. CLAUDE.md (<80 lines)

Generate based on detected stack. Use the template from `.claude/templates/claude-md-{stack}.md`.
If no template matches, generate a minimal one:

```markdown
# CLAUDE.md

## Project
{detected stack} project.

## Commands
{detected test/lint/format commands}

## Conventions
{language-specific conventions}

## Agent Instructions
- One task per agent, one commit per logical change
- Tests before implementation (BDD)
- Conventional commits required
```

### 2b. .claude/docs/ (4-file pattern)

Create if not exists:
- `PROMPT.md` — empty template
- `PLAN.md` — empty milestone template
- `PROGRESS.md` — initialized with timestamp
- `CONVENTIONS.md` — stack-specific conventions

### 2c. .claude/memory/ (structured memory)

Create directory structure:
- `episodic/` — auto-populated by hooks
- `procedural/` — empty (filled over time)
- `pitfalls/` — empty (filled over time)

### 2d. .claude/metrics/ and .claude/traces/

Create directories for observability data.

## Step 3: Detect Commands

Try to auto-detect the project's test, lint, and format commands:

| Indicator | Test Command | Lint Command | Format Command |
|---|---|---|---|
| `pyproject.toml` + `[tool.pytest]` | `pytest` | `ruff check .` | `ruff format .` |
| `pyproject.toml` + no pytest | `python -m pytest` | `ruff check .` | `ruff format .` |
| `package.json` + `"test"` script | `npm test` | `npx eslint .` | `npx prettier --write .` |
| `go.mod` | `go test ./...` | `golangci-lint run` | `gofmt -w .` |
| `Cargo.toml` | `cargo test` | `cargo clippy` | `cargo fmt` |

## Step 4: Agent Readiness Score

Check these criteria and compute a score (0-100):

| Criteria | Weight | Check |
|---|---|---|
| Test runner exists | 20 | `pytest`/`npm test`/`go test` runs successfully |
| Linter configured | 15 | `ruff`/`eslint`/`clippy` config found |
| CI configured | 15 | `.github/workflows/` exists |
| CLAUDE.md exists | 10 | File present |
| .claude/rules/ exists | 10 | Directory with rules |
| .claude/hooks/ exists | 10 | Directory with executable hooks |
| .claude/docs/ 4-file pattern | 10 | PROMPT+PLAN+PROGRESS+CONVENTIONS present |
| .claude/metrics/ exists | 5 | Directory present |
| .claude/traces/ exists | 5 | Directory present |

Output format:
```
=== Agent Readiness Score: 75/100 ===

PASS: Test runner (pytest), Linter (ruff), CLAUDE.md, Rules (4), Hooks (5), Docs (4), Metrics, Traces
FAIL: CI not configured (create .github/workflows/)

Recommendations:
1. Add CI workflow for automated testing
2. Add pre-commit hooks for lint enforcement
```

## Step 5: Report

Print a summary:
```
=== /init-project Complete ===

Stack: Python (FastAPI + SQLModel)
CLAUDE.md: generated (42 lines)
Docs: PROMPT.md, PLAN.md, PROGRESS.md, CONVENTIONS.md
Memory: episodic/, procedural/, pitfalls/
Metrics: .claude/metrics/
Traces: .claude/traces/

Commands detected:
  test:  uv run pytest
  lint:  ruff check src/ tests/
  format: ruff format src/ tests/

Agent Readiness: 80/100
Next step: Create a feature plan with /plan
```
