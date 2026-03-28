# CLAUDE.md

## Project

Full-stack: {backend} backend + {frontend} frontend.

## Commands

### Backend
- Test: `{backend_test_cmd}`
- Lint: `{backend_lint_cmd}`
- Run: `{backend_run_cmd}`

### Frontend
- Dev: `{frontend_dev_cmd}`
- Build: `{frontend_build_cmd}`
- Test: `{frontend_test_cmd}`
- Lint: `{frontend_lint_cmd}`

## Conventions

- Backend: Python 3.11+, FastAPI, SQLModel, Alembic
- Frontend: React 18, TypeScript, Tailwind, Vite
- API contract: OpenAPI spec (auto-generated from FastAPI)
- Shared types in `shared/` if monorepo

## Testing

- Backend: `pytest` + BDD (Given/When/Then)
- Frontend: Vitest + Playwright
- Integration: API contract tests between frontend/backend

## Agent Instructions

- One task per agent, one commit per logical change
- Never mix backend + frontend in one agent (separate dispatches)
- Conventional commits with scope: `feat(api):`, `feat(ui):`, `fix(db):`
- All work in git worktrees, never on main
