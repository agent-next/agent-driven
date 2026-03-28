---
name: common-agent-failures
description: Verified failure patterns that agents should avoid
type: pitfalls
---

# Agent Failure Patterns

## Python
- **numpy int64/float64**: Not JSON serializable. Always `int()` / `float()` before `json.dumps()`
- **bare except**: `except:` catches KeyboardInterrupt. Always `except Exception:`
- **pathlib vs os.path**: Mixing both in same module causes bugs. Pick one.
- **async fixtures**: pytest-asyncio requires `@pytest.fixture` not `@pytest.mark.asyncio`

## TypeScript
- **import extensions**: Use `.js` extensions in imports for ESM (even for `.ts` files)
- **any type**: Never use `any`. Use `unknown` + type narrowing.
- **optional chaining**: Always use `?.` for potentially undefined nested properties

## Git
- **git diff --stat**: Empty on fresh branches with no main commits. Use `git diff --stat HEAD` instead.
- **merge conflicts in lock files**: Never resolve manually. Delete + regenerate.
