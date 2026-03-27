---
name: python-fastapi-feature
description: Workflow for adding a new FastAPI endpoint with tests
type: procedural
---

# Adding a FastAPI Endpoint

## Steps
1. Define SQLModel schema in `models/`
2. Create Pydantic request/response schemas in `schemas/`
3. Add route in `api/routes/`
4. Write tests in `tests/` (BDD style: Given/When/Then)
5. Run `pytest` → `ruff check` → `mypy`
6. Commit: `feat(api): add <resource> <action> endpoint`

## Rules
- Always use dependency injection for DB sessions
- Always add input validation via Pydantic schemas
- Always include error responses in the route decorator
- Test happy path + validation errors + auth errors

## Pitfalls
- Don't forget `response_model` in route decorator (OpenAPI won't generate correct docs)
- Don't use `from sqlalchemy import ...` — use `from sqlmodel import ...`
- Alembic migration must be created separately after model changes
