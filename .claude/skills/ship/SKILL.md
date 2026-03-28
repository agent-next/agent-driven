---
name: ship
description: Ship the current work. Runs final checks, creates PR, and handles the merge pipeline. Integrates with gstack for CEO/eng review.
user-invocable: true
argument-hint: "[--draft|--ready|--force]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Agent
---

# /ship — Ship via Quality Pipeline

Ship current branch work through the quality pipeline to PR. Runs tests, lint, review, and creates a pull request.

**Arguments:** $ARGUMENTS

## Protocol

### Step 1: Pre-Flight Checks

Verify the branch is ready to ship:

```bash
# 1. Confirm we're not on main/master
BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "ERROR: Cannot ship from main. Create a feature branch first."
  exit 1
fi

# 2. Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "WARNING: Uncommitted changes detected. Commit first."
  git status -sb
  exit 1
fi

# 3. Check branch is pushed
if ! git rev-parse --verify "origin/$BRANCH" >/dev/null 2>&1; then
  echo "Branch not on remote. Pushing..."
  git push -u origin "$BRANCH"
fi
```

### Step 2: Test Suite

Run the full test suite:

**Python projects:**
```bash
if [ -f "uv.lock" ]; then
  uv run pytest --tb=short -q 2>&1
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  python3 -m pytest --tb=short -q 2>&1
fi
```

**Node projects:**
```bash
if [ -f "package.json" ] && grep -q '"test"' package.json; then
  npm test 2>&1
fi
```

If tests fail: **STOP**. Report failures and suggest fixes. Do not proceed.

### Step 3: Lint

Run linters:

```bash
# Python
if command -v ruff &>/dev/null; then
  ruff check . 2>&1
  ruff format --check . 2>&1
fi

# TypeScript/JavaScript
if [ -f "package.json" ] && grep -q '"lint"' package.json; then
  npm run lint 2>&1
fi
```

If lint fails: **STOP**. Auto-fix what's possible, report the rest.

### Step 4: Generate PR Content

Analyze the diff to create PR title and body:

```bash
# Get commit messages for title
git log origin/main..HEAD --oneline

# Get diff stats
git diff origin/main..HEAD --stat

# Get full diff for review
git diff origin/main..HEAD
```

Generate:
- **Title**: First commit message (conventional commit format)
- **Body**: Summarize all commits, list files changed, explain WHY not WHAT
- **Test plan**: Extract test files changed, describe how to verify

### Step 5: Cross-Engine Review (if available)

If Codex CLI (`cx` or `cxc`) is available, run a parallel review:

```bash
# Check if codex is available
if command -v cxc &>/dev/null; then
  cxc exec "Review the changes on branch $BRANCH for bugs, security issues, and code quality" -s read-only -o /tmp/ship-review.txt 2>/dev/null
fi
```

If Codex reports CRITICAL findings: **STOP** and report to user.

### Step 6: Create PR

Determine PR mode from arguments:
- `--draft`: Create as draft PR
- `--ready`: Create as ready for review (default)
- No args: Create as ready

```bash
# Determine base branch
BASE=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

# Create PR
gh pr create \
  --base "$BASE" \
  --title "[generated title]" \
  --body "[generated body with test plan]" \
  [--draft]
```

### Step 7: Update Docs

Update `.claude/docs/PROGRESS.md`:
```markdown
## [timestamp] - Shipped [branch name]
- PR #[number]: [title]
- Files changed: N
- Tests: [pass/fail count]
- Review findings: [summary]
```

Log outcome to `.claude/metrics/outcomes.jsonl`:
```json
{"ts":"...","event":"ship","branch":"...","pr":123,"files_changed":5,"test_result":"pass","review_findings":0}
```

### Step 8: Report

Show summary:
```
Shipped! PR #[number]
Branch: feat/xxx → main
Files: N changed, M added, D deleted
Tests: X passed, Y skipped
Review: 0 critical, 2 medium (acknowledged)
URL: https://github.com/org/repo/pull/123
```

### Failure Handling

| Failure | Action |
|---------|--------|
| Tests fail | Stop. Show failures. Suggest fixes. |
| Lint fails | Auto-fix if possible. Stop if not. |
| PR exists | Update existing PR with new commits. |
| Merge conflict | Report. Suggest rebase or human resolve. |
| Codex review critical | Stop. Show findings. Let human decide. |
