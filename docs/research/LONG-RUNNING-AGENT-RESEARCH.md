# Long-Running Claude Code Agent Research
## Compiled 2026-03-27

Research from Anthropic blog posts, engineering articles, and community experience.

---

## 1. KEY BLOG POSTS & SOURCES

### Anthropic Official

| Title | URL | Date | Key Topic |
|-------|-----|------|-----------|
| Effective Harnesses for Long-Running Agents | https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents | 2026 | Two-agent architecture, feature list JSON |
| Long-Running Claude for Scientific Computing | https://www.anthropic.com/research/long-running-Claude | 2026 | HPC/SLURM, CHANGELOG as memory, 48h sessions |
| Harness Design for Long-Running Applications | https://www.anthropic.com/engineering/harness-design-long-running-apps | 2026-03-24 | Three-agent system, evaluator calibration |
| Building a C Compiler with Agent Teams | https://www.anthropic.com/engineering/building-c-compiler | 2026 | 16 agents, 100K lines, 2000 sessions |
| How Anthropic Teams Use Claude Code | https://claude.com/blog/how-anthropic-teams-use-claude-code | 2025 | Internal workflows, productivity metrics |
| How AI Is Transforming Work at Anthropic | https://www.anthropic.com/research/how-ai-is-transforming-work-at-anthropic | 2025 | 67% more PRs/day, 200K transcripts analyzed |
| Enabling Claude Code Autonomous Operation | https://www.anthropic.com/news/enabling-claude-code-to-work-more-autonomously | 2025 | Checkpoints, hooks, subagents, background tasks |
| Building Agents with Claude Agent SDK | https://claude.com/blog/building-agents-with-the-claude-agent-sdk | 2026 | SDK architecture, compaction, tool design |
| Agent Skills | https://claude.com/blog/equipping-agents-for-the-real-world-with-agent-skills | 2026 | Progressive disclosure, context-efficient loading |
| Best Practices for Claude Code | https://code.claude.com/docs/en/best-practices | 2026 | Official best practices, context management |
| Hooks Guide | https://code.claude.com/docs/en/hooks-guide | 2026 | All hook types, configuration patterns |

### Community / Third-Party

| Title | URL | Key Topic |
|-------|-----|-----------|
| Context Rot in Claude Code | https://vincentvandeth.nl/blog/context-rot-claude-code-automatic-rotation | Automatic context rotation at 65% |
| Claude Code: Keeping It Running for Hours | https://motlin.com/blog/claude-code-running-for-hours | 2+ hour autonomous sessions |
| Claude Code 2.0 Experience | https://sankalp.bearblog.dev/my-experience-with-claude-code-20-and-how-to-get-better-at-using-coding-agents/ | Real-world session management |
| Long-Running Agent Lessons (Google/Anthropic/Manus) | https://natesnewsletter.substack.com/p/i-read-everything-google-anthropic | Nine scaling principles, four-layer memory |

---

## 2. HARD METRICS & NUMBERS

### Anthropic Internal (from "How AI Is Transforming Work at Anthropic")
- Claude usage: 28% -> 59% of daily work over 12 months
- Productivity gains: +20% -> +50% year-over-year
- 14% of power users report >100% productivity boost
- **67% increase in merged PRs per engineer per day**
- 27% of Claude-assisted work = tasks that wouldn't have been done otherwise
- Human turns decreased 33% (6.2 -> 4.1 per transcript)
- Agent consecutive tool calls: ~10 -> ~20 without human input (6 months)
- Task complexity increased: 3.2 -> 3.8 on 5-point scale
- Study: 132 engineers surveyed, 53 interviews, 200,000 transcripts analyzed

### C Compiler Project (from "Building a C Compiler with Agent Teams")
- **16 agents** ran simultaneously
- **~2,000 Claude Code sessions** over nearly 2 weeks
- **~$20,000 in API costs**
- **100,000 lines** of Rust code produced
- 99% pass rate on GCC torture tests
- Built bootable Linux 6.9 on x86, ARM, RISC-V

### Harness Design Benchmarks (from "Harness Design for Long-Running Apps")
- Solo agent game maker: 20 min, $9 -> broken core gameplay
- Harness game maker: 6 hours, $200 -> working physics, playable levels
- DAW build: 3 hr 50 min, $124.70
- Frontend improvements visible over 5-15 evaluator iterations

### Agent Teams Economics
- 3-teammate team uses ~3-4x tokens of single session
- Teammates spawn in 20-30 seconds, produce results within 1 minute
- Plan mode saves ~53% tokens (38K -> 18K for code review)

### Context Degradation Research (from "Context Rot" article)
- Stanford "Lost in the Middle": Performance drops **15-47%** as context grows
- At 50% usage: quality stable
- At 65%: nuance loss begins in compacted regions
- At 75%: agent noticeably worse (re-reading files, contradictions)
- At 80%: auto-compaction fires
- **Sweet spot for rotation: 60-65%** (before degradation, not after)

### Anthropic Team Time Savings
- Debugging: 3x faster (10-15 min manual -> minutes)
- K8s incident diagnosis: saved 20 minutes during outage
- Documentation research: 80% reduction (1 hour -> 10-20 min)
- Ad generation: hundreds in minutes instead of hours

---

## 3. ARCHITECTURE PATTERNS FOR LONG-RUNNING AGENTS

### Pattern 1: Initializer + Coding Agent (Anthropic Official)
```
Session 0: Initializer Agent
  -> Creates init.sh (dev server startup)
  -> Generates feature_list.json (200+ features)
  -> Sets up git repo with baseline commit
  -> Creates claude-progress.txt

Session N: Coding Agent
  1. pwd -> confirm working directory
  2. Read git logs + claude-progress.txt
  3. Review feature_list.json, pick highest-priority incomplete
  4. Run smoke tests FIRST (catch bugs from previous session)
  5. Implement ONE feature per session
  6. Commit with descriptive message
  7. Update progress documentation
```

**Critical rules:**
- Feature list MUST be JSON (not Markdown) -- models less likely to modify JSON
- Agents modify ONLY the `passes` field in feature list
- ONE feature per session to prevent context exhaustion
- Run end-to-end tests BEFORE implementing new features

### Pattern 2: Three-Agent Harness (Planner/Generator/Evaluator)
```
Planner Agent:  Expand prompts into full specs
Generator Agent: Build features in sprints
Evaluator Agent: QA testing with browser automation
```

**Key insight:** Agents confidently praise their own work. Separating generation from evaluation is more effective than training generators toward self-criticism. "Out of the box, Claude is a poor QA agent" -- requires multiple tuning iterations.

### Pattern 3: Agent Teams (16-agent mesh)
```
Team Lead (main session)
  -> Spawns Teammates (independent context windows)
  -> Shared Task List (central work queue)
  -> Mailbox (peer-to-peer messaging, not hub-and-spoke)
```

Unlike subagents: teammates communicate directly with each other. Each teammate loads CLAUDE.md, MCP servers, skills independently.

### Pattern 4: Ralph Loop (Autonomous Completion)
```bash
# Ralph Wiggum technique: iterate until backlog empty
while true; do
  claude -p "Continue working on the next task from TASKS.md.
    Mark completed tasks. Stop when all done."
  if [ $? -eq 0 ]; then break; fi
done
```

Best for: clear completion criteria, mechanical execution, programmatic verification. Real results: YC teams shipped 6+ repos overnight (~$297 API), React v16->v19 migration in 14-hour autonomous session.

### Pattern 5: SLURM + tmux for Scientific Computing
```bash
# SLURM job launches Claude in detached tmux
srun --jobid=JOBID --overlap --pty tmux attach -t claude
# Monitor via GitHub on phone
# Detach without interrupting: Ctrl+B, D
```

48-hour GPU allocations. CHANGELOG.md as "portable long-term memory / lab notes." Agent actively edits CLAUDE.md as it discovers new information.

---

## 4. CONTEXT MANAGEMENT STRATEGIES

### The Compaction Lifecycle
1. Context fills during work (file reads, command outputs, conversations)
2. At ~95% capacity (or 25% remaining), auto-compaction triggers
3. Compaction summarizes earlier messages, preserving key decisions
4. CLAUDE.md survives -- re-read from disk and re-injected fresh
5. Nuance lost: 50-line architecture discussion -> single sentence

### Proactive Context Management
```
/clear          -- Reset between unrelated tasks (MOST IMPORTANT)
/compact <inst> -- Manual compaction with focus instructions
/btw            -- Side questions that never enter context
Esc+Esc         -- Rewind to checkpoint, optionally summarize from point
Subagents       -- Delegate research to separate context windows
```

### Context Rotation (from Vincent van Deth)
Automated 4-stage pipeline at 65% usage:
1. PreToolUse hook detects 65% threshold -> blocks agent
2. Agent writes ROTATION-HANDOVER.md (completed work, remaining tasks, next steps)
3. External script sends /clear via tmux send-keys
4. SessionStart hook re-injects task state

Config: `export VNX_CONTEXT_ROTATION_ENABLED=1`

### Re-inject Context After Compaction (Official Hook)
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing. Current sprint: auth refactor.'"
          }
        ]
      }
    ]
  }
}
```

### CLAUDE.md Best Practices
- Under 200 lines (500-2000 tokens per load)
- Only include things Claude gets WRONG without it
- Prune regularly -- test by observing behavior changes
- Use emphasis ("IMPORTANT", "YOU MUST") for critical rules
- Import files with @path/to/import syntax
- Check into git for team sharing
- If Claude ignores rules: file is too long, rules getting lost

### Subagent Delegation (Context Isolation)
```
# Research in separate context, report back summary
"Use subagents to investigate how our auth system handles token refresh"

# Post-implementation verification
"Use a subagent to review this code for edge cases"
```

Each subagent gets own context window. Reports back summaries only. Main context stays clean for implementation.

### Skills vs MCP for Context Efficiency
- Skills: 30-50 tokens initially (progressive disclosure)
- MCP: loads full schemas upfront (heavier)
- Prefer skills for frequently invoked operations

---

## 5. ANTI-PATTERNS TO AVOID

### Session Anti-Patterns
1. **Kitchen sink session** -- Mix unrelated tasks in one session. Fix: /clear between tasks.
2. **Correction spiral** -- 3+ corrections on same issue. Fix: /clear + better initial prompt after 2 failed corrections.
3. **Infinite exploration** -- Unscoped "investigate" that reads hundreds of files. Fix: scope narrowly or use subagents.
4. **Over-specified CLAUDE.md** -- Too long, Claude ignores half. Fix: ruthlessly prune. Keep under 200 lines.
5. **Trust-then-verify gap** -- Ship plausible-looking code without tests. Fix: always provide verification.

### Agent Architecture Anti-Patterns
6. **One-shotting entire project** -- No feature decomposition, context exhaustion mid-feature.
7. **Premature completion** -- Agent declares "done" without comprehensive feature list.
8. **No progress documentation** -- Next session has no idea what happened.
9. **Time blindness** -- Agent spends hours on one test instead of progressing (C compiler finding).
10. **Self-evaluation** -- Agent rates own work highly. Always use separate evaluator.

### Context Anti-Patterns
11. **Reactive /clear** -- Loses all state. Use structured rotation with handover instead.
12. **Waiting until 80%** -- Auto-compaction fires first, destroys nuance. Rotate at 60-65%.
13. **Over-specification in prompts** -- Errors in detailed specs cascade downstream. High-level specs with discovered details work better.
14. **Generic defaults** -- Without weighted criteria, agents produce "safe, predictable layouts" with "telltale AI signs like purple gradients."
15. **Ignoring skill context** -- Skills reload from scratch after /clear, losing in-session state.

### Code Quality Anti-Patterns
16. **1.75x more logic errors** than human-written code (ACM 2025) -- every output must be verified.
17. **Database schema decisions** -- Work fine at 100 rows, collapse at 100K.
18. **Agentic laziness** -- Agent finds excuse to stop before finishing entire task.
19. **Single-point testing** -- Only testing at fiducial parameter values.
20. **Browser-native alerts invisible** -- Puppeteer MCP can't see modal dialogs.

---

## 6. RECOVERY & CHECKPOINT STRATEGIES

### Git-Based Recovery
- Commit after every meaningful unit of work
- Run `pytest tests/ -x -q` before every commit
- Never commit code that breaks existing passing tests
- Git history = recoverable progress if session dies mid-work

### Checkpoint System
- Auto-checkpoints before each Claude edit
- Restore options: code only, conversation only, or both
- Persist across sessions (close terminal, rewind later)
- LIMITATION: Only tracks Write/Edit/NotebookEdit -- NOT Bash changes

### Structured Handover Documents
```markdown
# Context Rotation Handover
**Context Used**: 67%

## Completed Work
- [specific items with concrete metrics]

## Remaining Tasks
- [exact next steps with file paths]

## Next Steps for Incoming Context
1. [continuation point with PID, port numbers, etc.]
```

### Ralph Loop for Completion Guarantees
Orchestration iterates up to N times, agent continues until explicit "DONE" signal. Prevents premature conclusion. Install via /plugin.

### Manual Steering Mid-Session
- SSH into cluster to re-prompt agent
- Update CLAUDE.md to redirect work
- Use local Claude Code to execute remote commands

---

## 7. HOOK CONFIGURATIONS FOR RELIABILITY

### All Hook Event Types
| Event | When | Use For |
|-------|------|---------|
| SessionStart | Session begins/resumes | Inject context, recover state |
| UserPromptSubmit | Before prompt processing | Validate/transform prompts |
| PreToolUse | Before tool executes | Block dangerous operations |
| PostToolUse | After tool succeeds | Auto-format, run tests, log |
| PostToolUseFailure | After tool fails | Error handling |
| Notification | Claude needs attention | Desktop notifications |
| Stop | Claude finishes responding | Verify completion |
| PreCompact | Before compaction | Save state |
| PostCompact | After compaction | Re-inject critical context |
| SessionEnd | Session terminates | Cleanup |
| SubagentStart/Stop | Subagent lifecycle | Monitor agents |
| ConfigChange | Settings modified | Audit trail |
| FileChanged | Watched file changes | Environment reload |

### Critical Hook Patterns for Long Sessions

**Context pressure monitoring (PreToolUse):**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "/path/to/context_monitor.sh"
          }
        ]
      }
    ]
  }
}
```
Reads remaining_pct from hook input. Blocks at 65%.

**Post-compaction re-injection (SessionStart):**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "cat .claude/post-compact-context.txt"
          }
        ]
      }
    ]
  }
}
```

**Completion verification (Stop hook with agent):**
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify all unit tests pass. Run test suite and check results.",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

**Auto-test after edits (PostToolUse):**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "cd $CLAUDE_PROJECT_DIR && npm test 2>&1 | tail -5"
          }
        ]
      }
    ]
  }
}
```

### Hook Exit Codes
- **Exit 0**: Action proceeds. stdout added to context for SessionStart/UserPromptSubmit.
- **Exit 2**: Action BLOCKED. stderr sent to Claude as feedback.
- **Other**: Action proceeds. stderr logged but not shown.

### Hook Performance Warning
Each hook runs synchronously. If PostToolUse adds >500ms per file edit, session feels sluggish.

---

## 8. MEMORY & STATE MANAGEMENT

### Four-Layer Memory Model (from research synthesis)
1. **Working Context** -- Current decision information (context window)
2. **Session Layer** -- Within-session state (conversation history)
3. **Memory** -- Persistent records across sessions (CLAUDE.md, auto-memory)
4. **Artifacts** -- Stored outputs (git commits, files, progress logs)

### CLAUDE.md Hierarchy
```
~/.claude/CLAUDE.md          -- All sessions (global)
./CLAUDE.md                  -- Project root (team-shared via git)
./parent/CLAUDE.md           -- Monorepo parent
./child/CLAUDE.md            -- Loaded on demand when working in child
.claude/agents/*.md          -- Subagent definitions
.claude/skills/*/SKILL.md    -- Domain knowledge, loaded on demand
```

### Auto Memory
Claude writes notes based on corrections and preferences. Survives across sessions. "Auto dream" feature periodically reorganizes memories between sessions.

### Memory Tool (Agent SDK)
For long-running software projects spanning multiple sessions, memory files need deliberate bootstrapping -- not ad-hoc writing. This turns memory into structured recovery, so each new session picks up exactly where the last left off.

### Compaction + Memory Synergy
- Compaction keeps active context manageable without client bookkeeping
- Memory persists important information across compaction boundaries
- Together: nothing critical lost in summarization

### CHANGELOG.md as Lab Notes (Scientific Computing Pattern)
```markdown
## 2026-03-15
- Tried Tsit5 for perturbation ODE -- system too stiff. Switched to Kvaerno5.
- Accuracy table: [parameters] -> [0.1% target achieved for X, not Y]
- Known limitation: gauge convention errors in cosmological calculations
```

Prevents re-attempting dead ends. Tracks accuracy tables, current status, known limitations.

---

## 9. MULTI-AGENT COORDINATION

### Agent Teams (Experimental, shipped with Opus 4.6)
```bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

Components: Team Lead + Teammates + Shared Task List + Mailbox (peer-to-peer).

**vs Subagents:**
- Subagents: hub-and-spoke, report only to main agent
- Teammates: mesh communication, message each other directly

**Best for:** Research with competing hypotheses, independent modules, cross-layer work (frontend/backend/tests), architectural debates.

**NOT for:** Sequential tasks, same-file edits, tight dependencies.

### C Compiler Coordination Lessons
- **16 agents** via Docker containers with /upstream mount
- Task-specific lock files in current_tasks/ to prevent duplicates
- Logfiles structured for grep: "ERROR" flagged for discovery
- Continuous integration pipeline for validation
- "Most effort went into designing the environment around Claude"
- Autonomous systems require robust, easily-parseable feedback mechanisms

### Writer/Reviewer Pattern
```
Session A (Writer): Implement feature
Session B (Reviewer): Review with fresh context (no bias toward own code)
Session A: Address feedback
```

### Fan-Out Pattern
```bash
for file in $(cat files.txt); do
  claude -p "Migrate $file from React to Vue. Return OK or FAIL." \
    --allowedTools "Edit,Bash(git commit *)"
done
```

---

## 10. KEY INSIGHTS & LESSONS LEARNED

### From Anthropic's Research
1. "Harness design is key to performance at the frontier of agentic coding"
2. "Every token added to context competes for attention -- signal drowns in accumulation"
3. "Effective context windows are probably 50-60% of stated length" due to attention degradation
4. "The best time to rotate context is when you don't think you need to yet"
5. "Most effort went into designing the environment around Claude, not the core loop"
6. "Claude Code works best as a thought partner, not a code generator"

### From the C Compiler Project
7. Merge conflicts when multiple agents modify same code
8. New features often broke existing functionality
9. "Time blindness" -- agents spend hours on tests rather than progressing
10. Pre-compute aggregate statistics rather than requiring agents to recalculate
11. Structure test output minimally -- detailed logs stored separately

### From Scientific Computing
12. "Commit and push after every meaningful unit of work"
13. Agent commit logs function as "lab notes from a fast, hyper-literal postdoc"
14. Non-expert researchers absorbed domain knowledge by following incremental progress
15. Domain experts still needed -- agents spend hours on issues experts spot instantly

### From Context Rot Research
16. Performance drops 15-47% as context grows (Stanford "Lost in the Middle")
17. More context actively worsens output, even with perfect retrieval
18. Degradation accelerates in later portions of context window
19. Proactive rotation from position of strength > desperate reactive clearing

### From Community Experience
20. "First attempt will be 95% garbage" -- iterate with sharpened prompts
21. Two failed corrections = time to /clear and restart with better prompt
22. Session names with /rename help find and resume long-running work
23. Background agents for monitoring (logs, errors) while main agent implements
24. Multi-model verification: GPT-5.2-Codex for bug detection, Claude for implementation

---

## 11. CONFIGURATION CHECKLIST FOR LONG-RUNNING AGENTS

### Before Starting
- [ ] CLAUDE.md under 200 lines with project conventions
- [ ] .claudeignore configured (saves ~50% token budget)
- [ ] Hooks configured: notification, auto-format, file protection
- [ ] Skills created for domain-specific workflows
- [ ] Test suite available for self-verification
- [ ] Git repo initialized with clean baseline
- [ ] Feature list in JSON (not Markdown) if using initializer pattern
- [ ] Progress tracking file (claude-progress.txt or CHANGELOG.md)

### Session Management
- [ ] /clear between unrelated tasks
- [ ] Monitor context usage (status line or /context)
- [ ] Rotate at 60-65% usage, not 80%
- [ ] Use subagents for research/exploration
- [ ] One feature per session for long projects
- [ ] Commit after each completed feature
- [ ] Run tests before implementing new features

### Recovery Setup
- [ ] Post-compaction context re-injection hook
- [ ] Structured handover document template
- [ ] Stop hook for completion verification
- [ ] Git-based recovery (commit often)
- [ ] Session naming with /rename for resumability

### Quality Gates
- [ ] Separate evaluator agent (never self-evaluate)
- [ ] Browser automation for UI testing (not just curl)
- [ ] Test suite runs after each edit (hook or instruction)
- [ ] Multi-model verification for critical code
- [ ] Human review before shipping (trust-then-verify gap)
