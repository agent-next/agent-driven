---
name: init-project
description: Bootstrap agent-driven development scaffold for any project. Detects stack, generates CLAUDE.md, AGENTS.md, agents, rules, hooks, and docs.
user-invocable: true
argument-hint: "[project-path]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
---

# /init-project — Bootstrap Agent-Driven Development

Initialize any project with a complete agent-driven development scaffold.

**Request:** $ARGUMENTS

## Detection Phase

First, detect the project's tech stack:

```bash
CWD="${1:-.}"
cd "$CWD"

echo "=== Stack Detection ==="
[ -f "pyproject.toml" ] && echo "PYTHON: pyproject.toml found" && STACK="python"
[ -f "setup.py" ] && echo "PYTHON: setup.py found" && STACK="python"
[ -f "requirements.txt" ] && echo "PYTHON: requirements.txt found" && STACK="python"
[ -f "package.json" ] && echo "NODE: package.json found" && STACK="node"
[ -f "tsconfig.json" ] && echo "TYPESCRIPT: tsconfig.json found" && STACK="typescript"
[ -f "Cargo.toml" ] && echo "RUST: Cargo.toml found" && STACK="rust"
[ -f "go.mod" ] && echo "GO: go.mod found" && STACK="go"
[ -f "Dockerfile" ] && echo "DOCKER: Dockerfile found"
[ -f "docker-compose.yml" ] || [ -f "compose.yml" ] && echo "DOCKER_COMPOSE: found"
[ -d ".git" ] && echo "GIT: initialized" || echo "GIT: not initialized"
echo "STACK=$STACK"
```

## Generation Phase

Based on detected stack, generate:

### 1. CLAUDE.md (< 80 lines)
Include ONLY:
- Project name + one-line description
- Tech stack (language, framework, package manager)
- Build/test/lint commands
- Key conventions (import style, naming)
- Architecture overview (3-5 lines max)

Do NOT include:
- Generic coding advice
- Personality instructions
- Rules that a linter enforces
- Obvious things ("write clean code")

### 2. AGENTS.md (cross-tool standard, < 30 lines)
Include:
- Project overview (1 line)
- Build command
- Test command
- Lint command
- Key conventions (2-3 lines)

### 3. .claude/ directory
Copy from agent-driven scaffold:
- `agents/` (coordinator, implementer, reviewer, tester)
- `rules/` (quality, git-workflow, security, context-management)
- `hooks/` (branch-guard, post-edit-lint, subagent-stop-verify, task-completed-gate, stall-detector)
- `docs/` (WORKFLOW.md template)

### 4. .claude/docs/ structured docs
Create:
- `ARCHITECTURE.md` — generated from codebase analysis (directories, key files, data flow)
- `CONVENTIONS.md` — stack-specific conventions
- `PROGRESS.md` — empty, ready for agent updates
- `PROMPT.md` — empty, ready for feature specs

### 5. Verify
Run checks:
- All hook scripts are executable
- CLAUDE.md is under 80 lines
- AGENTS.md is under 30 lines
- Git is initialized

Report: "Scaffold initialized. Run `claude /dispatch` to start agent-driven development."
