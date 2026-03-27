# CLAUDE.md

## Project

Python project using {framework}.

## Commands

- Test: `{test_cmd}`
- Lint: `{lint_cmd}`
- Format: `{format_cmd}`
- Run: `{run_cmd}`

## Conventions

- Python 3.11+, type hints required
- Pydantic v2 for schemas (not v1)
- SQLModel for database models (not raw SQLAlchemy)
- Alembic for migrations
- `src/` layout with namespace packages

## Testing

- `pytest` with `pytest-asyncio` for async
- BDD style: Given/When/Then for features
- Test files: `tests/test_{module}.py`
- Fixtures in `tests/conftest.py`
- Target: 20%+ test LOC ratio

## Agent Instructions

- One task per agent, one commit per logical change
- Write failing test FIRST, then implement
- Conventional commits: `feat(scope):`, `fix(scope):`, `test:`
- All work in git worktrees, never on main
- Run test suite before every commit
