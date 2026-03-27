---
description: Git workflow rules for agent-driven development
---

# Git Workflow

## Iron Rules

- ALL development in git worktrees. NEVER commit to main directly.
- Every change reaches main through a PR. No exceptions.
- NEVER force push. NEVER use `--admin` merge. NEVER skip CI.
- NEVER auto-merge. Human reviews and merges every PR.

## Workflow

1. `git worktree add` with feature branch
2. Implement in worktree (small commits, each passes tests)
3. Push branch, create PR
4. CI + agent review + human review
5. Human merges
6. Clean up worktree

## Branch Naming

- `feat/<description>` — new features
- `fix/<description>` — bug fixes
- `test/<description>` — test additions
- `refactor/<description>` — refactoring
- `docs/<description>` — documentation
