---
description: Quality standards enforced on all code changes
---

# Quality Standards

## Code Quality Gates (enforced by hooks, not guidelines)

- Lint must pass before commit (ruff for Python, eslint for JS/TS)
- Type check must pass before commit (mypy/pyright for Python, tsc for TS)
- Tests must pass before PR
- No bare `except:` — always catch specific exceptions
- No `# type: ignore` without inline justification
- No `console.log` / `print()` in production code (use logging)

## Commit Standards

- Conventional commits required: `feat(scope):`, `fix(scope):`, `test:`, `docs:`, `ci:`, `chore:`, `refactor(scope):`
- One logical change per commit
- Commit message explains WHY, not WHAT (the diff shows WHAT)

## PR Standards

- One concern per PR
- Every PR with production code includes tests
- CI must pass all checks before merge
- Cross-engine review for implementation PRs (CC reviews Codex, vice versa)

## Testing Requirements

- Every public function has at least one test
- Both positive and negative test cases
- Edge cases: empty input, boundary values, unicode, very long strings
- Error paths tested explicitly
