# CLAUDE.md

## Project

React app with {bundler} + TypeScript.

## Commands

- Dev: `{dev_cmd}`
- Build: `{build_cmd}`
- Test: `{test_cmd}`
- Lint: `{lint_cmd}`
- Type check: `{typecheck_cmd}`

## Conventions

- TypeScript strict mode (no `any`, use `unknown`)
- Functional components with hooks (no class components)
- Tailwind CSS for styling (no inline styles)
- React Router for navigation
- Zustand or React Context for state (no Redux unless specified)

## File Structure

- `src/components/` — reusable UI components
- `src/pages/` — route-level components
- `src/hooks/` — custom hooks
- `src/lib/` — utilities and helpers
- `src/types/` — shared TypeScript types

## Testing

- Vitest for unit tests
- Playwright for E2E tests
- Testing Library for component tests
- Test files: `*.test.tsx` colocated with components

## Agent Instructions

- One task per agent, one commit per logical change
- Conventional commits: `feat(scope):`, `fix(scope):`, `test:`
- All work in git worktrees, never on main
- Run type check + lint + tests before every commit
