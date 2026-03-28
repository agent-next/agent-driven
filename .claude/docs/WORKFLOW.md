# Agent Workflow

## Standard Flow

```
User Request
  │
  ▼
/plan (spec + BDD + review gate)
  │
  ▼
/dispatch (coordinator decomposes + routes)
  │
  ├─→ Implementer (Codex, worktree) ─→ lint hook ─→ test hook ─→ commit
  ├─→ Implementer (Codex, worktree) ─→ lint hook ─→ test hook ─→ commit
  └─→ Tester (Haiku, worktree) ─→ test generation ─→ commit
  │
  ▼
Cross-engine review (CC reviews Codex, vice versa)
  │
  ▼
/ship (CI + PR + human merge)
```

## Skills Used at Each Stage

| Stage | Skill | Source |
|-------|-------|--------|
| Plan | superpowers:brainstorming, superpowers:writing-plans | superpowers plugin |
| Review | superpowers:requesting-code-review, code-review plugin | superpowers + code-review |
| Implement | superpowers:test-driven-development | superpowers plugin |
| QA | gstack /qa | gstack plugin |
| Ship | gstack /ship | gstack plugin |
| Debug | superpowers:systematic-debugging, gstack /investigate | both |
| Retro | gstack /retro | gstack plugin |
