# Agent-Driven Development System: Gap Analysis & Prioritized Feature List

**Date**: 2026-03-27
**Scope**: Best-in-class agent-driven development system based on CC (Opus) + Codex (GPT-5.4)
**Method**: Web research synthesis from 50+ sources including Anthropic's 2026 Agentic Coding Trends Report, competitor analysis, production case studies, and academic benchmarks

---

## What We Already Have

| Component | Status | Notes |
|-----------|--------|-------|
| .claude/ scaffold | Done | agents, skills, rules, hooks |
| CTO skill | Done | 9-phase tmux orchestration |
| cc-manager v0.1.7 | Done | REST API, worktree pool, scheduler, SQLite |
| my-coding-agent-config | Done | Bootstrap, hooks, CLI tools |
| superpowers plugin | Done | Brainstorming, TDD, debugging, planning |
| Multi-model dispatch | Done | cxc (GPT-5.4) + ccz (GLM-5.1) + CC (Opus) |
| Worktree isolation | Done | All dev in worktrees, never on main |
| CI/CD pipeline | Done | merge-gate, conventional commits, lint+type+test |
| CLAUDE.md context | Done | Project knowledge, model reference, API rules |
| MEMORY.md persistence | Done | Cross-session knowledge |

---

## 1. Feature Gap Analysis: Competitors vs. Our System

### 1.1 Devin (Cognition)

**What Devin has that we don't:**

| Feature | Devin | Our System | Gap Severity |
|---------|-------|------------|-------------|
| DeepWiki (auto-generated codebase docs) | Full codebase wiki with architecture diagrams, auto-updated every few hours | None -- CLAUDE.md is manual | HIGH |
| Devin Search (codebase Q&A) | Natural language queries against indexed codebase with cited code | grep/Glob only | MEDIUM |
| Visual input processing (Figma mockups, screenshots) | Processes UI mockups and video screen recordings | Not integrated | LOW |
| Fleet deployment (10+ parallel instances on same task pattern) | Orchestrated fleet of identical agents across repos | CTO skill does 10+ agents but not fleet-pattern | MEDIUM |
| PR merge rate tracking (34% to 67% YoY) | Built-in outcome metrics | No agent outcome metrics | HIGH |
| Dynamic re-planning on roadblocks | Agent alters strategy without human input | Agents stop and report | MEDIUM |
| Codebase knowledge graph (enterprise) | Uploadable docs form a knowledge graph the agent references | MEMORY.md is flat text | HIGH |

**Key lesson from Devin**: PR merge rate doubled (34% to 67%) by improving codebase understanding, not model quality. Their biggest wins are parallelizable junior tasks: security fixes (20x efficiency), framework migrations (10-14x), test generation.

### 1.2 OpenHands

**What OpenHands has that we don't:**

| Feature | OpenHands | Our System | Gap Severity |
|---------|-----------|------------|-------------|
| Event-sourced state with deterministic replay | Full replay/debug of every agent decision | No agent action replay | HIGH |
| Sandboxed Docker execution per agent | Each agent runs in isolated container | Worktree isolation only (shared OS) | MEDIUM |
| Software Agent SDK (composable Python library) | Typed tool system, immutable config, MCP integration | Ad-hoc shell scripts and skills | MEDIUM |
| Cloud-native scaling (1000s of agents) | Architected for horizontal scale | Max ~10 agents in tmux | LOW (for now) |
| Browser/VNC/VSCode interfaces for visual verification | Agents can see and interact with GUIs | CLI-only agents | LOW |
| Full MCP integration with OAuth | Standardized tool protocol with auth | Partial MCP (tools available but not systematized) | MEDIUM |

**Key lesson from OpenHands**: Event-sourced state is the architectural breakthrough -- it enables deterministic replay for debugging what went wrong, which is essential when agents run autonomously for hours.

### 1.3 Cursor

**What Cursor has that we don't:**

| Feature | Cursor | Our System | Gap Severity |
|---------|--------|------------|-------------|
| Background Agents (always-on, event-triggered) | Cloud sandbox agents triggered by commits, Slack, PagerDuty, timers | CTO skill is manual dispatch only | HIGH |
| Automations (event-driven agent triggers) | Agents fire on external events without human prompting | No event-driven triggers | HIGH |
| Agent memory across runs | Agents learn from past runs and improve with repetition | MEMORY.md is manual, no agent-level learning | HIGH |
| 8 parallel agents with model routing | Different models per agent based on task complexity | We do this (cxc/ccz routing) | DONE |
| Custom embedding model for codebase recall | Proprietary embeddings for large codebase understanding | No semantic search of codebase | HIGH |
| Cloud execution sandbox | Remote sandbox clones repo and runs agent | All local execution | MEDIUM |
| MCP Apps ecosystem | 100+ standardized MCP tool connections | Growing but smaller set | LOW |

**Key lesson from Cursor**: Event-driven automation is the next frontier. The shift from "human dispatches agents" to "events trigger agents automatically" is what separates an assistant from an autonomous system. Agent memory that improves with repetition is also a major differentiator.

### 1.4 GitHub Copilot (Coding Agent + Workspace)

**What Copilot has that we don't:**

| Feature | Copilot | Our System | Gap Severity |
|---------|---------|------------|-------------|
| Agent HQ (multi-provider orchestration) | Run Claude + Codex + Copilot agents from one interface | We combine CC + Codex but no unified dashboard | MEDIUM |
| Copilot Spaces (persistent context containers) | Curated repos + issues + docs + instructions as reusable context | CLAUDE.md + MEMORY.md is close but not containerized | MEDIUM |
| Next Edit Suggestions (predictive edits) | AI predicts next change across file based on previous edits | Not applicable (terminal-based) | LOW |
| GitHub Actions integration for agent execution | Agent runs in Actions compute with full CI/CD access | We use worktrees locally | MEDIUM |
| Issue-to-PR automation | Assign issue to Copilot, it produces a PR | CTO skill can do this but no issue-assignment trigger | MEDIUM |
| Multi-model picker (per-task model selection) | User selects model per task; Auto mode lets Copilot choose | We have manual routing rules | LOW |

**Key lesson from Copilot**: Copilot Spaces solve the context fragmentation problem -- instead of one CLAUDE.md, you curate context containers for different workflows (debugging, feature work, ops) that persist across sessions.

### 1.5 Augment Code (Context Engine)

**What Augment has that we don't:**

| Feature | Augment | Our System | Gap Severity |
|---------|---------|------------|-------------|
| Context Engine (semantic codebase index) | Real-time semantic index understanding code relationships across repos | grep/Glob text search | CRITICAL |
| Tasklist (auto-planning before coding) | Maps full implementation sequence before touching code | superpowers:writing-plans is manual | MEDIUM |
| Context Engine MCP (open to all agents) | 70%+ performance improvement on Claude Code, Cursor, Codex | No semantic search MCP | HIGH |
| ISO 42001 + SOC 2 Type II certification | Enterprise security compliance | None | LOW (for now) |
| Cross-repo architectural understanding | Understands relationships across services and repos | Single-repo context only | HIGH |
| Millisecond sync with code changes | Index updates within seconds of file changes | No code indexing | HIGH |

**Key lesson from Augment**: Their Context Engine MCP improved agent performance by 70%+ across Claude Code, Cursor, and Codex. This is the single highest-ROI investment: semantic codebase understanding makes every agent smarter. They made it available as an MCP server so any agent can use it.

---

## 2. Production Agent Patterns: Lessons from Scale

### 2.1 Architecture Patterns That Work

**Orchestrator-Worker (dominant pattern)**
- Lead agent analyzes requests, delegates subtasks to specialized subagents
- Reduces cost by 90% compared to using frontier models for everything
- Our CTO skill implements this well

**Plan-and-Execute (cost-efficient)**
- Generate complete plan upfront, execute sequentially
- 69% fewer tokens than ReAct (observe-reason-act loop)
- Best for structured workflows where conditions are stable

**Two-Agent System (Anthropic recommended)**
- Initializer Agent: creates feature list (JSON), writes init.sh, sets up progress tracking
- Coding Agent: reads progress, picks ONE highest-priority feature, implements, tests, commits
- Key: JSON over Markdown for state (reduces inappropriate modifications)

**Coordinator/Specialist/Verifier (Augment)**
- Three roles: planning, implementation, review
- Each role can be a different model at different cost tiers

### 2.2 What Companies Learned at Scale

**Zapier (800+ agents, 89% org adoption)**
- Success required treating AI adoption as business transformation, not tool deployment
- Governance and security frameworks were prerequisites, not afterthoughts

**TELUS (13,000+ custom AI solutions)**
- Engineering code shipped 30% faster
- Over 500,000 hours saved total
- Key: domain-specific agent specialization

**The Productivity Paradox (industry-wide)**
- Developers complete 21% more tasks and merge 98% more PRs
- BUT PR review time increases 91% -- review becomes the bottleneck
- AI-assisted code increases issue counts ~1.7x and security findings if not governed
- Code churn increases 9x with AI tools

**Security at Scale**
- An agent writing 1,000 PRs/week with 1% vulnerability rate = 10 new vulnerabilities weekly
- Standard security prompts improve secure code likelihood to 66% (vs 56% without)
- Traditional security scanning is insufficient for AI-generated code

### 2.3 Monitoring & Observability Requirements

From industry data: 89% of organizations with agents in production have implemented observability, with 62% having detailed step-level tracing.

**Essential observability stack:**

| Layer | What to Track | Tool Reference |
|-------|---------------|----------------|
| Agent Traces | Every decision/tool-call with input/output | Langfuse (open-source), Braintrust, LangSmith |
| Cost Tracking | Per-agent, per-task token spend with model breakdown | Built-in with prompt caching metrics |
| Outcome Metrics | PR merge rate, test pass rate, time-to-completion | Custom dashboard |
| Quality Scores | Automated eval of agent outputs (correctness, style, security) | Braintrust (CI/CD blocking on quality regression) |
| Error Patterns | Failure modes, retry counts, escalation frequency | Custom with alerting |
| Session Replay | Deterministic replay of agent decision chains | OpenHands event-sourced state pattern |

---

## 3. Missing Infrastructure

### 3.1 Context Management

**The problem**: Context windows are finite. Agents lose context between sessions. Multi-repo projects fragment knowledge.

**Best-in-class solutions:**
- **Augment Context Engine**: Real-time semantic index across repos, millisecond sync, MCP-accessible
- **Copilot Spaces**: Curated context containers (repos + issues + docs + instructions) persisted across sessions
- **Devin Knowledge Graph**: Uploadable docs forming a queryable knowledge graph

**What we need**: Move from flat CLAUDE.md/MEMORY.md files to a semantic index that agents can query. Context Engine MCP is the pattern to adopt.

### 3.2 Memory Systems

**The problem**: Agents start fresh each session. Learning from past successes/failures is lost.

**Memory taxonomy (from academic survey):**
- **Semantic memory**: Factual knowledge (what we know)
- **Episodic memory**: Past experiences (what happened)
- **Procedural memory**: How to do things (skills learned)

**Best-in-class solutions:**
- **Mem0**: Personal agent memory with automatic consolidation and conflict resolution
- **Zep**: Conversation history with entity extraction and temporal awareness
- **Cursor Automations**: Agent memory that improves with repetition (pattern: "this type of commit usually causes X error")

**What we need**: MEMORY.md is semantic memory only. We lack episodic memory (what worked/failed in past sessions) and procedural memory (learned workflows). Need structured, queryable memory -- not flat markdown.

### 3.3 Cost Optimization

**The problem**: Running 10+ agents on frontier models burns tokens fast.

**Industry benchmarks:**
- Multi-model routing alone delivers 40-60% savings
- Prompt caching (Anthropic): 90% discount on cache reads, breakeven at ~2 hits
- Output tokens cost 3-10x more than input tokens -- controlled output is critical
- Strategic caching + routing + infrastructure optimization = 70%+ cost reduction

**What we already do well**: cxc (GPT-5.4) for primary + ccz (GLM-5.1, free) for subagents
**What we need**: Per-task automatic model routing, prompt caching utilization tracking, cost dashboards

### 3.4 Evaluation Framework

**The problem**: How do you know if agents are getting better or worse?

**Key benchmarks to track:**
- **SWE-bench Verified**: Standard for issue-to-patch correctness
- **FeatureBench**: Complex feature development (Claude Opus 4.5 achieves only 11% vs 74% on SWE-bench)
- **Terminal-Bench**: Multi-step command-line workflows
- **Context-Bench**: Long-running context maintenance
- **DPAI Arena (JetBrains)**: Full multi-language engineering lifecycle

**What we need**: Internal eval suite measuring our specific agent quality: PR merge rate, test coverage of generated code, time-to-completion, human intervention rate, rework rate.

### 3.5 Safety & Guardrails

**The problem**: 48% of cybersecurity professionals identify agentic AI as the most dangerous attack vector of 2026.

**Essential guardrails (layered):**

| Layer | Purpose | Implementation |
|-------|---------|---------------|
| Ownership | Define who is responsible for each agent | Agent manifests with owner field |
| Permission Constraints | Limit each agent to required permissions only | Per-agent allowlists (we have this) |
| Action-Level Guards | Pre-execution validation of all destructive operations | Pre-commit hooks + /careful skill |
| Security Scanning | AI-aware vulnerability detection on generated code | CodeRabbit, Qodo PR-agent integration |
| Audit Trail | Complete log of every agent action | Event-sourced state (we lack this) |
| Budget Limits | Hard token/cost caps per agent per task | cc-manager scheduler (partial) |

---

## 4. Competitive Differentiation

### 4.1 What Makes It 10x Better Than Claude Code Alone

| Capability | Claude Code Raw | Our System Adds |
|------------|----------------|-----------------|
| Parallelism | Single session, manual subagents | 10+ coordinated agents via CTO skill |
| Model diversity | Claude models only | GPT-5.4 + GLM-5.1 + Gemini + Claude |
| Workflow automation | Manual dispatch | Skills, hooks, scheduled tasks |
| Quality gates | Trust the model | Multi-stage review pipeline (L1-L4) |
| Knowledge persistence | CLAUDE.md per session | MEMORY.md + refs/ knowledge base |
| Cost control | Full-price Opus for everything | Tiered routing (frontier for planning, free for subwork) |

### 4.2 What Makes It 10x Better Than Codex Alone

| Capability | Codex Raw | Our System Adds |
|------------|----------|-----------------|
| Interactive debugging | Async cloud-only, no live feedback | CC terminal for tight feedback loops |
| Deep reasoning | Strong but Claude Opus leads on complex architectural decisions | Opus for hard problems, GPT-5.4 for implementation |
| Local execution | Cloud sandbox only | Local worktree + local GPU (RTX 5090) |
| Custom tooling | Limited to predefined tools | Full MCP ecosystem + custom skills |
| CI integration | GitHub-native | Any CI system + custom merge gates |

### 4.3 Unique Value of CC + Codex Combined

The complementary strengths are well-documented in industry analysis:

- **CC (Opus) for interactive, local work**: Tight control, custom hooks, deep reasoning, complex debugging, production code quality
- **Codex (GPT-5.4) for autonomous, cloud-based delegation**: Large refactors, test generation, documentation, overnight parallel tasks
- **GLM-5.1 (free) for auxiliary work**: Code review, exploration, testing, analysis
- **Model consensus**: When CC and Codex agree on a solution, confidence is high. When they disagree, flag for human review.

No single vendor provides this. The unique moat is the orchestration layer that routes tasks to the right model and aggregates results with quality gates.

---

## 5. UX Patterns for Agent Systems

### 5.1 Smashing Magazine's 6 Core Patterns (2026)

1. **Intent Preview**: Show proposed actions before execution. Three buttons: Proceed / Edit Plan / Handle Myself. Target >85% acceptance without edits.
2. **Autonomy Dial**: Per-task-type settings (Observe / Plan+Propose / Act+Confirm / Fully Autonomous). Let users calibrate comfort level.
3. **Explainable Rationale**: Post-action transparency answering "why?" before users ask. Link to precedent.
4. **Confidence Signal**: Surface agent self-awareness (percentage scores + visual cues). Prevents automation bias.
5. **Action Audit & Undo**: Chronological timeline of all agent actions with undo buttons and time-limited windows.
6. **Escalation Pathway**: Request clarification with specific options rather than making confident guesses. Target 5-15% escalation frequency.

### 5.2 Progress Communication

**What works:**
- Dashboard showing agent status cards (idle / processing / stuck)
- Token velocity badges (burn rate per agent)
- Animated progress indicators for multi-step workflows
- Step-by-step breakdown with expandable detail panels

**Tools to reference:**
- NTM (Named Tmux Manager): Agent status cards with token velocity badges
- TmuxCC: Centralized monitoring of multiple AI coding assistants
- cmux: GPU-accelerated terminal with agent notification rings

### 5.3 Solo Developer ("One-Person Unicorn") Patterns

From the 2026 trend data:
- 36.3% of all new global startups are solo-founded
- Solo founders replace 70-80% of traditional salary burn ($200-500/month in AI tools)
- Daily routine: 2h reviewing outputs + 3h deep work + 2h shipping + 1h metrics

**Key pattern**: Vibe CEO -- delegate through natural language, agents work asynchronously, review outputs in batches. Human judgment is curation (selecting which AI outputs to ship), not creation.

---

## 6. Prioritized Feature List

### P0: Must Have for v1 (Essential Infrastructure)

| # | Feature | What It Does | Why It Matters | Reference Implementation |
|---|---------|-------------|---------------|-------------------------|
| 1 | **Agent Outcome Metrics Dashboard** | Track PR merge rate, test pass rate, time-to-completion, human intervention rate, rework rate, cost per task | Cannot improve what you cannot measure. Devin doubled PR merge rate by tracking it. Industry shows 62% of production teams plan to improve observability first. | Devin metrics, Faros AI engineering intelligence |
| 2 | **Event-Driven Agent Triggers** | Agents fire automatically on: git push, CI failure, issue assignment, schedule (cron), Slack message | Shifts from "human dispatches agents" to "events trigger agents." Cursor Automations is the breakout feature of 2026. | Cursor Automations, GitHub Copilot Coding Agent |
| 3 | **Agent Action Trace & Replay** | Log every agent decision, tool call, and output. Enable deterministic replay for debugging. | Essential for debugging autonomous failures. 89% of production agent teams have observability; 62% have step-level tracing. | OpenHands event-sourced state, Langfuse traces |
| 4 | **Structured Agent Memory** | Replace flat MEMORY.md with queryable structured memory: semantic (facts), episodic (what worked/failed), procedural (learned workflows). Auto-consolidation and conflict resolution. | Agents that learn from past sessions are dramatically more effective. Cursor's agent memory is a key differentiator. | Mem0, Zep, Cursor Automations memory |
| 5 | **Cost Tracking & Budget Limits** | Per-agent, per-task token spend tracking. Hard budget caps. Model routing cost display. | Running 10+ agents on frontier models without cost visibility is financially dangerous. Organizations report 40-60% savings from routing alone. | Built-in; reference Braintrust cost tracking |
| 6 | **Self-Healing Error Recovery** | Exponential backoff with jitter, circuit breakers, automatic model fallback, escalation chains (auto-fix then alert then human). | Agents running overnight WILL hit errors. Without recovery, they just stop. AWS research shows backoff+jitter reduces retry storms 60-80%. | AWS retry patterns, OpenHands recovery |

### P1: Should Have (Significant Improvement)

| # | Feature | What It Does | Why It Matters | Reference Implementation |
|---|---------|-------------|---------------|-------------------------|
| 7 | **Semantic Codebase Index** | Real-time semantic index understanding code relationships, queryable by any agent via MCP. | Augment's Context Engine improved agent performance 70%+ across Claude Code, Cursor, and Codex. Single highest-ROI investment. | Augment Context Engine MCP |
| 8 | **Auto-Generated Codebase Wiki** | Continuously updated documentation with architecture diagrams, dependency maps, source links. | Devin's DeepWiki handles repos with 5M lines of code. Eliminates manual CLAUDE.md maintenance for codebase knowledge. | Devin DeepWiki |
| 9 | **Agent Quality Eval Suite** | Internal benchmark measuring agent correctness, style compliance, security, and coverage on our specific codebase. Automated regression detection. | FeatureBench shows agents that score 74% on SWE-bench score only 11% on complex features. Generic benchmarks mask real-world performance. | FeatureBench, DPAI Arena, Braintrust evals |
| 10 | **Context Containers (Spaces)** | Curated bundles of repos + issues + docs + instructions for different workflows (debugging, feature dev, ops). Persist across sessions. | Solves context fragmentation. Instead of one CLAUDE.md, have specialized context for each workflow type. | GitHub Copilot Spaces |
| 11 | **AI-Aware Security Scanning** | Security scanning specifically designed for AI-generated code patterns. Integrated into agent PR workflow. | 1% vulnerability rate at 1000 PRs/week = 10 new vulnerabilities weekly. Traditional scanning misses AI-specific patterns. | CodeRabbit, Qodo PR-agent |
| 12 | **Dynamic Re-Planning** | Agent detects roadblocks and alters strategy without human intervention. Includes confidence-based escalation. | Devin v3.0 added this. Agents that stop at every obstacle require constant babysitting. Escalation at 5-15% is the healthy target. | Devin dynamic re-planning |

### P2: Nice to Have (Competitive Differentiation)

| # | Feature | What It Does | Why It Matters | Reference Implementation |
|---|---------|-------------|---------------|-------------------------|
| 13 | **Agent TUI Dashboard** | Real-time terminal dashboard showing all agent status cards, token velocity, progress bars, error states. | NTM and TmuxCC show this is the ergonomic improvement that makes managing 10+ agents pleasant instead of chaotic. | NTM, TmuxCC, cmux |
| 14 | **Cross-Repo Context** | Agents understand relationships across multiple repos in the ecosystem (lab-manager, labwork-web, labclaw-private, etc.). | Augment's killer feature. Our 16-repo ecosystem needs agents that understand cross-repo dependencies. | Augment Context Engine |
| 15 | **Model Consensus Verification** | When CC and Codex independently produce the same solution, auto-approve. When they disagree, flag for human review with diff. | Leverages our unique multi-model advantage. No single-vendor system can do this. Reduces human review burden by filtering high-confidence results. | Custom (our innovation) |
| 16 | **Agent Fleet Deployment** | Deploy N identical agents executing the same task pattern across repos in parallel (e.g., security fix fleet, test generation fleet). | Devin's fleet mode is their highest-ROI pattern: security fixes 20x faster, framework migrations 10-14x faster. | Devin fleet mode |
| 17 | **Codebase Q&A (Search)** | Natural language queries against indexed codebase with cited code references. | Devin Search converts vague ideas into executable tasks using codebase intelligence. Reduces time-to-context for any new task. | Devin Search |
| 18 | **Prompt Caching Optimization** | Automatically structure prompts to maximize cache hits. Track cache hit rates. Target 90% discount on repeated context. | Anthropic's prompt caching delivers 90% discount on reads. Breakeven at ~2 cache hits. Significant at our scale. | Anthropic prompt caching |

### P3: Future / Aspirational

| # | Feature | What It Does | Why It Matters | Reference Implementation |
|---|---------|-------------|---------------|-------------------------|
| 19 | **Cloud Execution Sandboxes** | Remote sandboxed environments where agents run in isolated containers with full toolchain. | OpenHands and Cursor both provide this. Enables true overnight autonomy without occupying local resources. | OpenHands Docker sandboxes, Cursor cloud agents |
| 20 | **Visual Input Processing** | Agents process UI mockups, screenshots, and video screen recordings as task input. | Devin processes Figma mockups and video recordings. Useful for frontend work and visual bug reports. | Devin visual input |
| 21 | **Agent-to-Agent Protocol (A2A)** | Standardized communication protocol between agents from different providers. | Google's A2A and MCP from Anthropic are converging. Future-proofing for ecosystem interoperability. | Google A2A, Anthropic MCP |
| 22 | **Autonomous Remediation** | Agents proactively scan codebase, identify issues, generate fixes, and open PRs without human prompting. | CodeRabbit and Qodo are pioneering this. Shifts from reactive to proactive code quality. | CodeRabbit, Pixee |
| 23 | **Enterprise Governance Framework** | Full audit trails, compliance reporting, SOC 2 readiness, access control per agent. | Required for selling to enterprise labs. Augment's ISO 42001 + SOC 2 Type II is a differentiator. | Augment enterprise compliance |
| 24 | **Living Documentation System** | Agent instruction files (CLAUDE.md) auto-update based on codebase changes. Stale docs flagged and refreshed weekly. | Industry consensus: outdated agent instructions make agents "actively counterproductive." | Solo founder best practices |

---

## 7. Implementation Sequencing

### Phase 1: Visibility (1-2 weeks)
- P0-1: Agent Outcome Metrics Dashboard
- P0-5: Cost Tracking & Budget Limits
- P0-3: Agent Action Trace (basic logging, not full replay yet)

### Phase 2: Autonomy (2-3 weeks)
- P0-2: Event-Driven Agent Triggers
- P0-6: Self-Healing Error Recovery
- P1-12: Dynamic Re-Planning

### Phase 3: Intelligence (2-3 weeks)
- P0-4: Structured Agent Memory
- P1-7: Semantic Codebase Index (via Augment Context Engine MCP or self-built)
- P1-10: Context Containers

### Phase 4: Quality (2-3 weeks)
- P1-9: Agent Quality Eval Suite
- P1-11: AI-Aware Security Scanning
- P2-15: Model Consensus Verification

### Phase 5: Scale (ongoing)
- P1-8: Auto-Generated Codebase Wiki
- P2-13: Agent TUI Dashboard
- P2-14: Cross-Repo Context
- P2-16: Agent Fleet Deployment

---

## 8. Sources

### Competitor Analysis
- [Devin 2025 Performance Review](https://cognition.ai/blog/devin-annual-performance-review-2025)
- [Devin AI Guide 2026](https://aitoolsdevpro.com/ai-tools/devin-guide/)
- [OpenHands Software Agent SDK Paper](https://arxiv.org/html/2511.03690v1)
- [OpenHands GitHub](https://github.com/OpenHands/OpenHands)
- [Cursor Beta Features 2026](https://markaicode.com/cursor-beta-features-2026/)
- [Cursor Automations](https://cursor.com/blog/automations)
- [GitHub Copilot Coding Agent](https://github.blog/news-insights/product-news/github-copilot-meet-the-new-coding-agent/)
- [GitHub Copilot Spaces](https://docs.github.com/en/copilot/get-started/features)
- [Augment Context Engine](https://www.augmentcode.com/context-engine)
- [Augment Context Engine MCP](https://www.augmentcode.com/blog/context-engine-mcp-now-live)
- [Best AI Coding Agents 2026 (Faros AI)](https://www.faros.ai/blog/best-ai-coding-agents-2026)

### Production Patterns
- [Anthropic 2026 Agentic Coding Trends Report](https://resources.anthropic.com/2026-agentic-coding-trends-report)
- [8 Trends Defining Software Engineering (Anthropic)](https://tessl.io/blog/8-trends-shaping-software-engineering-in-2026-according-to-anthropics-agentic-coding-report/)
- [AI Agent Architecture (Redis)](https://redis.io/blog/ai-agent-architecture/)
- [5 Agent Design Patterns (n1n.ai)](https://explore.n1n.ai/blog/5-ai-agent-design-patterns-master-2026-2026-03-21)
- [Enterprise AI Coding Adoption Scaling (Faros AI)](https://www.faros.ai/blog/enterprise-ai-coding-assistant-adoption-scaling-guide)
- [5 Production Scaling Challenges (MLM)](https://machinelearningmastery.com/5-production-scaling-challenges-for-agentic-ai-in-2026/)
- [Deploying AI Agents to Production (MLM)](https://machinelearningmastery.com/deploying-ai-agents-to-production-architecture-infrastructure-and-implementation-roadmap/)

### Observability & Evaluation
- [State of AI Agents (LangChain)](https://www.langchain.com/state-of-agent-engineering)
- [5 Best Agent Observability Tools (Braintrust)](https://www.braintrust.dev/articles/best-ai-agent-observability-tools-2026)
- [Top 5 Agent Observability Platforms (Maxim AI)](https://www.getmaxim.ai/articles/top-5-ai-agent-observability-platforms-in-2026/)
- [AI Agents in Production (Cleanlab)](https://cleanlab.ai/ai-agents-in-production-2025/)
- [FeatureBench (arXiv)](https://arxiv.org/html/2602.10975v1)
- [Code Review Agent Benchmark (arXiv)](https://arxiv.org/html/2603.23448)

### Memory & Context
- [6 Best Agent Memory Frameworks (MLM)](https://machinelearningmastery.com/the-6-best-ai-agent-memory-frameworks-you-should-try-in-2026/)
- [Memory for AI Agents (The New Stack)](https://thenewstack.io/memory-for-ai-agents-a-new-paradigm-of-context-engineering/)
- [AI-Native Memory (Ajith Prabhakar)](https://ajithp.com/2025/06/30/ai-native-memory-persistent-agents-second-me/)
- [Context Engineering for Personalization (OpenAI Cookbook)](https://cookbook.openai.com/examples/agents_sdk/context_personalization)

### Cost Optimization
- [AI Agent Cost Optimization 2026 (Moltbook)](https://moltbook-ai.com/posts/ai-agent-cost-optimization-2026)
- [AI Agent Token Cost Optimization (Fast.io)](https://fast.io/resources/ai-agent-token-cost-optimization/)
- [LLM Token Optimization (Redis)](https://redis.io/blog/llm-token-optimization-speed-up-apps/)
- [AI Agent Token Cost Multi-Model Routing (MindStudio)](https://www.mindstudio.ai/blog/ai-agent-token-cost-optimization-multi-model-routing)

### Safety & Security
- [Securing AI Agents (Bessemer)](https://www.bvp.com/atlas/securing-ai-agents-the-defining-cybersecurity-challenge-of-2026)
- [AI Agent Guardrails Production Guide (Authority Partners)](https://authoritypartners.com/insights/ai-agent-guardrails-production-guide-for-2026/)
- [AI Agent Security 2026 (Dark Reading)](https://www.darkreading.com/application-security/coders-adopt-ai-agents-security-pitfalls-lurk-2026)
- [AI Agent Guardrails Framework (Galileo)](https://galileo.ai/blog/ai-agent-guardrails-framework)

### UX & Developer Experience
- [Designing for Agentic AI UX Patterns (Smashing Magazine)](https://www.smashingmagazine.com/2026/02/designing-agentic-ai-practical-ux-patterns/)
- [AI UX Patterns](https://www.aiuxpatterns.com/)
- [One-Person Unicorn Guide (NxCode)](https://www.nxcode.io/resources/news/one-person-unicorn-context-engineering-solo-founder-guide-2026)
- [AI Coding Statistics (Panto)](https://www.getpanto.ai/blog/ai-coding-assistant-statistics)
- [METR AI Developer Productivity Study](https://metr.org/blog/2025-07-10-early-2025-ai-experienced-os-dev-study/)

### Agent Architecture & Tools
- [Claude Code Sub-Agent Best Practices](https://claudefa.st/blog/guide/agents/sub-agent-best-practices)
- [Claude Code Agent Teams Guide](https://claudefa.st/blog/guide/agents/agent-teams)
- [Claude Code Worktree Guide](https://claudefa.st/blog/guide/development/worktree-guide)
- [Claude Code vs Codex Comparison (Northflank)](https://northflank.com/blog/claude-code-vs-openai-codex)
- [Multi-Agent Development (VS Code)](https://code.visualstudio.com/blogs/2026/02/05/multi-agent-development)
- [Agent HQ (GitHub)](https://github.blog/news-insights/company-news/pick-your-agent-use-claude-and-codex-on-agent-hq/)
- [NTM Tmux Manager](https://vibecoding.app/blog/ntm-review)
- [TmuxCC Dashboard](https://github.com/nyanko3141592/tmuxcc)
- [cmux Terminal](https://github.com/manaflow-ai/cmux)

### Self-Healing & Error Recovery
- [AI Agent Retry Patterns (Fast.io)](https://fast.io/resources/ai-agent-retry-patterns/)
- [Self-Healing AI Agent System (DEV Community)](https://dev.to/the_bookmaster/how-to-build-a-self-healing-ai-agent-system-that-recovers-from-failures-automatically-4m6h)
- [7 Error Handling Patterns (DEV Community)](https://dev.to/techfind777/building-self-healing-ai-agents-7-error-handling-patterns-that-keep-your-agent-running-at-3-am-5h81)
- [AI Agent Rollback Strategy (Fast.io)](https://fast.io/resources/ai-agent-rollback-strategy/)
