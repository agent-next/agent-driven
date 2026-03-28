---
name: plan
description: Plan a feature or fix with spec review. Decomposes a request into a structured plan with milestones, then dispatches reviewer agents for approval.
user-invocable: true
argument-hint: "[feature description or task]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Agent
---

# /plan — Feature Planning with Review Gates

Turn a feature request into an approved, actionable plan stored in `.claude/docs/PLAN.md`.

**Request:** $ARGUMENTS

## Protocol

### Step 1: Analyze Request

Parse the user's request. Classify:
- **Feature**: New functionality (needs design)
- **Fix**: Bug fix (needs investigation)
- **Refactor**: Code restructuring (needs scope)
- **Chore**: Maintenance task (simple decomposition)

Read existing context:
- `.claude/docs/ARCHITECTURE.md` if it exists (project structure)
- `.claude/docs/PROGRESS.md` (current state)
- `.claude/docs/CONVENTIONS.md` (project conventions)
- `CLAUDE.md` (project overview)

### Step 2: Investigate Codebase

Before writing the plan, investigate the relevant code:
- Find files that will be affected
- Identify existing patterns to follow
- Check for similar implementations (avoid reinventing)
- List dependencies and constraints

### Step 3: Write PLAN.md

Create `.claude/docs/PLAN.md` with this structure:

```markdown
# Plan: [Feature Name]

> Created: [date]
> Status: DRAFT → REVIEW → APPROVED
> Scope: [files/modules affected]

## Goal
[One paragraph: what this achieves and why]

## Investigation
[Key findings from codebase analysis]
- Files affected: [list]
- Patterns to follow: [references]
- Constraints: [dependencies, backwards compat, etc.]

## Milestones

### M1: [First milestone]
- Files: [which files change]
- Changes: [what to do]
- Tests: [what to test]
- Estimate: [S/M/L]

### M2: [Second milestone]
...

## Risks
- [Risk 1]: [mitigation]
- [Risk 2]: [mitigation]

## Dependencies
- [Milestone dependencies, if any]

## Review Checklist
- [ ] Scope is minimal (no gold-plating)
- [ ] Tests specified for each milestone
- [ ] No breaking changes without migration path
- [ ] Follows existing patterns
```

### Step 4: Review Gate

Dispatch 3 parallel reviewer agents for spec review:

**Security Reviewer:**
```
Agent(subagent_type="general-purpose", prompt="Review .claude/docs/PLAN.md for security concerns. Check: auth bypass, data leaks, injection risks, privilege escalation. Report as JSON: [{severity, concern, suggestion}]")
```

**Architecture Reviewer:**
```
Agent(subagent_type="general-purpose", prompt="Review .claude/docs/PLAN.md for architectural concerns. Check: coupling, cohesion, separation of concerns, naming. Report as JSON: [{severity, concern, suggestion}]")
```

**Correctness Reviewer:**
```
Agent(subagent_type="general-purpose", prompt="Review .claude/docs/PLAN.md for correctness. Check: edge cases, error handling, race conditions, data integrity. Report as JSON: [{severity, concern, suggestion}]")
```

### Step 5: Incorporate Feedback

1. Collect all reviewer findings
2. For each CRITICAL or HIGH finding: update the plan to address it
3. For MEDIUM/LOW findings: add to Risks section or acknowledge
4. Update plan status: DRAFT → REVIEWED

### Step 6: Present to User

Show the plan summary:
- N milestones, N files affected
- Review findings: X critical, Y high, Z medium
- Changes made based on review
- Estimated complexity

Ask: "Plan is ready. Run `/dispatch` to execute, or modify first."

### Anti-Patterns to Avoid

- Do NOT plan beyond what was asked (scope creep)
- Do NOT specify implementation details at code level (that's for implementer agents)
- Do NOT skip the investigation step (plans without codebase context are guesses)
- Do NOT skip review (fresh eyes catch 30% more issues)
