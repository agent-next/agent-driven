# Claude Code Ecosystem Research Report

**Date**: 2026-03-27
**Scope**: Claude Code wrappers, harnesses, prompt engineering tools, agent-ready templates
**Purpose**: Research only -- identify gaps in our .claude/ scaffold and CTO skill

---

## Category 1: Claude Code Wrappers & Harnesses

### 1.1 gstack (garrytan/gstack) -- 52.1k stars
- **What**: Garry Tan's (YC President) opinionated 28-skill Claude Code workflow. "Virtual software development team."
- **Architecture**: Git clone into `~/.claude/skills/gstack/`. Pure markdown SKILL.md files, no daemon.
- **Key skills**: /office-hours, /plan-ceo-review, /plan-eng-review, /plan-design-review, /review, /qa, /ship, /land-and-deploy, /canary, /codex, /cso, /careful, /freeze, /guard, /browse, /autoplan, /retro, /investigate, /benchmark
- **Differentiator**: Process-driven (Think > Plan > Build > Review > Test > Ship > Reflect). Real Chromium browser (~100ms/cmd). Cross-model review with OpenAI Codex.
- **Our equivalent**: CTO skill + our existing skills (we already have gstack installed via plugin)
- **Gap**: We already use gstack. No gap -- it IS part of our stack.
- **Action**: **Already using** -- continue.

### 1.2 oh-my-claudecode (Yeachan-Heo) -- 13.8k stars
- **What**: Teams-first multi-agent orchestration. 32 specialized agents, smart model routing, magic keywords.
- **Architecture**: Claude Code plugin (npm: oh-my-claude-sisyphus). Spawns tmux workers across providers (Claude, Codex, Gemini).
- **Key features**: Zero-config, autopilot mode, HUD statusline, rate-limit auto-resume, Discord/Telegram/Slack notifications, custom skill extraction, 30-50% token savings via smart routing.
- **Differentiator**: Multi-provider worker spawning. Automatic skill learning from sessions.
- **Our equivalent**: CTO skill dispatches ccz/cxc agents via Bash. Manual routing.
- **Gap**: We lack automatic model routing, automatic skill extraction, and provider-agnostic worker pools.
- **Action**: **Adopt patterns** -- steal skill auto-extraction and model routing ideas.

### 1.3 everything-claude-code (affaan-m) -- 112k stars
- **What**: The largest Claude Code harness. 28 subagents, 125+ skills, 60+ commands. "Performance optimization system."
- **Architecture**: Directory-based (.agents/, skills/, commands/, hooks/, rules/, contexts/). Cross-platform (CC, Cursor, Codex, OpenCode).
- **Key features**: AgentShield security, MCP configs (GitHub, Supabase, Vercel), continuous learning, instinct-based pattern extraction, 997 tests.
- **Differentiator**: Research-first with instinct system. Anthopic hackathon winner. Massive community.
- **Our equivalent**: Our .claude/ scaffold is much smaller (skills, agents, hooks, commands).
- **Gap**: We lack contexts/ (dynamic prompt injection), cross-harness compatibility, AgentShield, and instinct-based learning.
- **Action**: **Adopt patterns** -- steal dynamic context injection and the instinct/learning loop concept.

### 1.4 Superpowers (obra) -- 118k stars
- **What**: Official Anthropic marketplace plugin. Agentic skills framework & software development methodology.
- **Architecture**: Plugin install via `/plugin install superpowers@claude-plugins-official`. 11 core skills across 4 categories.
- **Key skills**: Brainstorming (Socratic), TDD (red-green-refactor), systematic debugging (4-phase), subagent-driven dev with dual-stage review, git worktree isolation, writing-skills (meta).
- **Differentiator**: Deeply opinionated methodology. Enforces TDD, enforces root cause before fix, enforces design review. Official marketplace.
- **Our equivalent**: We already have superpowers installed as a plugin.
- **Gap**: We already have it. May not be fully utilizing all 11 skills.
- **Action**: **Already using** -- audit which skills we actively invoke vs. ignore.

### 1.5 Ruflo (ruvnet/ruflo) -- ~25k stars
- **What**: Multi-agent swarm orchestration. 259 MCP tools, 60+ agents, 8 AgentDB controllers.
- **Architecture**: WASM-based agent booster (352x faster simple transformations). Neural self-learning from task executions.
- **Key features**: 85% API cost reduction via model routing, Agent Teams integration, swarm intelligence.
- **Differentiator**: WASM acceleration for simple tasks. Self-learning across sessions.
- **Our equivalent**: CTO skill does multi-agent dispatch but no WASM, no self-learning.
- **Gap**: No WASM acceleration, no persistent cross-session learning.
- **Action**: **Ignore for now** -- too heavy. Watch for WASM acceleration pattern.

### 1.6 Ralph (frankbria/ralph-claude-code) -- community tool
- **What**: Autonomous development loop. Claude Code runs iteratively until PRD completion.
- **Architecture**: Shell script loop with intelligent exit detection, circuit breakers, rate limiting.
- **Key features**: Dual-condition exit (completion + EXIT_SIGNAL), session continuity, 24h expiration.
- **Differentiator**: "Set it and forget it" autonomous development.
- **Our equivalent**: /ralph-loop skill already installed.
- **Gap**: None -- already in our stack.
- **Action**: **Already using**.

---

## Category 2: Curated Lists & Awesome Collections

### 2.1 awesome-claude-code (hesreallyhim) -- 33.2k stars
- **What**: THE curated list. Agent skills, workflows, tooling, IDE integrations, orchestrators, hooks, slash-commands, CLAUDE.md files.
- **Key categories**: Orchestrators, Usage Monitors, Config Managers, Statuslines, Hooks, Slash-Commands, CLAUDE.md files, Alternative Clients.
- **Notable mentions**: Ruflo, Claude Squad, ccflare, CC Usage, Claudex, RIPER Workflow, Container Use, ContextKit, Rulesync.
- **Action**: **Bookmark** -- use as discovery tool for new projects.

### 2.2 awesome-claude-code-toolkit (rohitg00) -- 17.4k stars
- **What**: Most comprehensive toolkit. 135 agents, 35 skills (+400K via SkillKit), 42 commands, 150+ plugins, 19 hooks, 15 rules, 7 templates, 8 MCP configs.
- **Key feature**: SkillKit integration for 400K+ community skills.
- **Our equivalent**: Our toolkit is much smaller.
- **Gap**: SkillKit access, extensive template library.
- **Action**: **Adopt patterns** -- cherry-pick specific agents/commands that match our lab-manager domain.

### 2.3 awesome-cursorrules (PatrickJS) -- 38.7k stars
- **What**: 100+ cursor rule templates across every framework/language.
- **Relevance**: Rules are structurally similar to .claude/rules/ files. Concepts transfer directly.
- **Our equivalent**: Our .claude/ rules are lab-manager-specific.
- **Gap**: We could adapt some general coding rules (TypeScript, Python, testing patterns).
- **Action**: **Adopt patterns** -- port relevant Python/FastAPI rules to our .claude/rules/.

### 2.4 awesome-copilot (github/github) -- official
- **What**: GitHub's official community collection. 175+ agents, 208+ skills, 176+ instructions, 48+ plugins.
- **Architecture**: .github/copilot-instructions.md format.
- **Relevance**: Shows convergence -- all AI coding tools moving to markdown instruction files.
- **Action**: **Ignore** -- Copilot-specific format, we're Claude Code native.

### 2.5 awesome-claude-plugins (ComposioHQ) -- community
- **What**: Hub for Claude Skills, Agents, Commands, Hooks, Plugins, and Marketplace collections.
- **Action**: **Bookmark** for plugin discovery.

---

## Category 3: CLAUDE.md / AGENTS.md Templates & Best Practices

### 3.1 AGENTS.md Standard (agentsmd/agents.md) -- open standard
- **What**: Open format for guiding coding agents. 20K+ repos adopted. Supported by OpenAI Codex, Google Jules, Cursor, Amp, Factory.
- **Key structure**: Commands, testing, project structure, code style, git workflow, boundaries (always/ask first/never).
- **Best practices**: Start simple, iterate on mistakes. Nested AGENTS.md for subpackages. Never embed secrets.
- **Our equivalent**: Our CLAUDE.md is comprehensive. We don't have AGENTS.md.
- **Gap**: Adding AGENTS.md for cross-tool compatibility (Codex, Gemini CLI).
- **Action**: **Adopt** -- create AGENTS.md alongside CLAUDE.md for tool-agnostic guidance.

### 3.2 claude-md-templates (abhishekray07) -- templates
- **What**: CLAUDE.md best practices based on Anthropic's official guidance.
- **Our equivalent**: Our CLAUDE.md is more detailed than most templates.
- **Action**: **Ignore** -- our CLAUDE.md exceeds these templates.

### 3.3 claude-code-ultimate-guide (FlorianBruniaux) -- guide
- **What**: Beginner-to-power-user guide. 107 production templates, 55 external resource evaluations.
- **Key content**: Agent Teams workflow, release tracking, MCP security, scoring methodology.
- **Action**: **Bookmark** -- useful reference for onboarding new team members.

### 3.4 claude-code-showcase (ChrisWiles) -- reference implementation
- **What**: Comprehensive .claude/ configuration example with hooks, skills, agents, commands, GitHub Actions.
- **Key features**: Auto-format hooks, test-on-change hooks, main-branch edit blocking, intelligent skill suggestions, scheduled maintenance (monthly docs sync, weekly quality reviews, biweekly dep audits).
- **Our equivalent**: We have hooks + CI but no skill suggestion system, no scheduled maintenance agents.
- **Gap**: Automated skill suggestion based on prompt analysis. Scheduled GitHub Action agents.
- **Action**: **Adopt patterns** -- steal scheduled maintenance agent concept and skill suggestion system.

### 3.5 claude-code-system-prompts (Piebald-AI) -- reference
- **What**: Extracted system prompts from every CC version. 18 tool descriptions, all agent prompts, updated within minutes of each release.
- **Differentiator**: Shows exactly how Anthropic structures system prompts. Deep reference for prompt engineering.
- **Our equivalent**: Nothing -- we don't study CC internals.
- **Gap**: Understanding CC's internal prompt structure could improve our CLAUDE.md effectiveness.
- **Action**: **Adopt patterns** -- study how CC's own prompts handle tool descriptions and agent delegation.

---

## Category 4: Configuration & Customization Tools

### 4.1 tweakcc (Piebald-AI) -- deep customization
- **What**: Customize CC system prompts, create custom toolsets, input highlighters, themes, AGENTS.md support, unlock unreleased features.
- **Key feature**: Toolsets -- exclude tools from model context entirely (not just permissions, model doesn't even know they exist).
- **Differentiator**: Only tool that modifies CC's actual system prompt per-section.
- **Our equivalent**: Nothing.
- **Gap**: Context optimization via toolset pruning could save significant tokens.
- **Action**: **Adopt patterns** -- toolset pruning concept is valuable. Evaluate tweakcc for context optimization.

### 4.2 claude-code-config TUI (joeyism) -- config manager
- **What**: Terminal UI for managing ~/.claude.json. Hierarchical interface for MCP servers, projects, conversations.
- **Action**: **Ignore** -- nice-to-have, not essential.

### 4.3 Trail of Bits claude-code-config -- security
- **What**: Opinionated security defaults. Sandboxing, permissions, hooks, skills, MCP configs for security audits.
- **Key feature**: Dimensional analysis plugin (93% recall vs 50% baseline for finding bugs).
- **Our equivalent**: Our .claude/ has security rules but no formal security audit skills.
- **Gap**: Security audit skills, dimensional analysis.
- **Action**: **Adopt** -- install Trail of Bits security skills for code review pipeline.

### 4.4 Rulesync (dyoshikawa) -- cross-tool sync
- **What**: CLI to sync rules across Claude Code, Cursor, Gemini CLI from single .rulesync/ source.
- **Our equivalent**: We only target Claude Code.
- **Gap**: If we ever need multi-tool support.
- **Action**: **Ignore for now** -- we're Claude Code native. Revisit if team uses Cursor.

### 4.5 Claude Squad (smtg-ai) -- 6.7k stars
- **What**: Terminal app managing multiple CC instances in separate workspaces. Uses tmux + git worktrees.
- **Architecture**: Each agent gets isolated tmux session + git worktree. Auto-accept mode.
- **Our equivalent**: CTO skill manages agents via Bash + tmux.
- **Gap**: Claude Squad has nicer TUI and built-in worktree isolation.
- **Action**: **Watch** -- our CTO skill covers this. Claude Squad is simpler but less customizable.

---

## Category 5: Agent Skills Ecosystem

### 5.1 skills.sh / npx skills (vercel-labs/skills) -- THE package manager
- **What**: npm for agent skills. `npx skills add <package>`. Supports Claude Code, Codex, Cursor, 39+ agents.
- **Architecture**: SKILL.md files with YAML frontmatter. GitHub-based registry (skills.sh).
- **Key feature**: Install from GitHub shorthand, GitLab, any git URL, local paths.
- **Vendors shipping official skills**: Vercel, Prisma, Supabase, Stripe, Remotion, Coinbase, Microsoft.
- **Our equivalent**: We install skills manually or via gstack/superpowers.
- **Gap**: We don't use skills.sh registry. Could discover domain-specific skills faster.
- **Action**: **Adopt** -- start using `npx skills` for discovering and managing third-party skills.

### 5.2 Vercel agent-skills (vercel-labs/agent-skills) -- official
- **What**: React/Next.js performance optimization from Vercel Engineering. 40+ rules across 8 categories.
- **Relevance**: Low -- we're Python/FastAPI backend.
- **Action**: **Ignore** -- wrong tech stack.

### 5.3 Supabase agent-skills -- official
- **What**: Best practices for using Supabase with AI agents.
- **Relevance**: Medium -- we use PostgreSQL but not Supabase directly.
- **Action**: **Ignore** -- we have our own DB patterns.

### 5.4 antfu/skills -- 4k stars
- **What**: Anthony Fu's curated skills. Auto-generated from source docs. Vite/Nuxt focus.
- **Differentiator**: Skills generated FROM documentation, kept in sync automatically.
- **Our equivalent**: Our skills are hand-written.
- **Gap**: Auto-generating skills from our API docs would ensure they stay current.
- **Action**: **Adopt pattern** -- auto-generate skills from FastAPI/OpenAPI docs.

### 5.5 Trail of Bits Security Skills -- security focused
- **What**: Security research, vulnerability detection, audit workflow skills.
- **Relevance**: High -- we need security skills for our code review pipeline.
- **Action**: **Adopt** -- install for Layer 3 (external audit) of our review pipeline.

---

## Category 6: Agent-Ready Project Templates

### 6.1 AI SDLC Scaffold (pangon/ai-sdlc-scaffold) -- template
- **What**: Repo template for AI-first development. 4 phases: Objectives > Design > Code > Deploy.
- **Architecture**: Everything-in-repo (objectives, requirements, architecture, decisions, task tracking alongside code).
- **Key concept**: Context-window efficiency via hierarchical instructions and two-file decision records.
- **Our equivalent**: Our CLAUDE.md + MEMORY.md + labclaw-private docs.
- **Gap**: We don't have formal phase-gated SDLC structure in the repo itself.
- **Action**: **Adopt patterns** -- steal the decision record format and context-window efficiency tricks.

### 6.2 Agent Readiness (kodustech/agent-readiness) -- scoring
- **What**: Open-source alternative to Factory.ai's Agent Readiness. Scores repos on testing, docs, security.
- **Architecture**: CLI that evaluates repo and produces web dashboard.
- **Our equivalent**: Nothing formal.
- **Gap**: We don't score our repos for agent-readiness.
- **Action**: **Use directly** -- run on lab-manager to get a readiness score and identify gaps.

### 6.3 AgentReady (ambient-code/agentready) -- scoring
- **What**: Repo assessment against 50+ research sources (Anthropic, Microsoft, Google, peer-reviewed).
- **Our equivalent**: Nothing formal.
- **Action**: **Use directly** -- run alongside agent-readiness for cross-validation.

### 6.4 claude-toolbox/starter-kit (serpro69) -- template
- **What**: Template repo with pre-configured MCP servers, skills, hooks, themed statuslines.
- **Key feature**: Plugin marketplace distribution model -- install via `/plugin install`.
- **Our equivalent**: Our .claude/ is project-specific, not distributable as a plugin.
- **Gap**: We can't share our lab-manager .claude/ config as a reusable plugin.
- **Action**: **Watch** -- if we want to distribute lab configs to other labs, this pattern matters.

---

## Category 7: Monitoring & Analytics

### 7.1 ccflare -- API proxy
- **What**: Claude API proxy with request-level analytics. Tracks latency, tokens, costs in real-time.
- **Our equivalent**: No real-time cost tracking.
- **Gap**: We don't track per-session costs.
- **Action**: **Watch** -- useful for cost optimization once team grows.

### 7.2 Claude Code Agent Monitor (hoangsonww) -- dashboard
- **What**: Real-time monitoring dashboard (Node.js + React + WebSockets). Tracks sessions, tool usage, subagent orchestration.
- **Our equivalent**: Nothing.
- **Gap**: No visibility into agent activity across sessions.
- **Action**: **Ignore for now** -- premature for current team size.

---

## Category 8: Prompt Engineering Patterns

### 8.1 Marmelab Agent Experience (AX) -- best practices
- **What**: 40+ best practices for optimizing Agent Experience, modeled after DX (Developer Experience).
- **Key insights**: Hooks as guardrails (block bad patterns, agent retries), browser testing for self-validation, never merge without human review.
- **Our equivalent**: We follow most of these via CLAUDE.md rules.
- **Gap**: Systematic AX audit of our repo.
- **Action**: **Adopt patterns** -- run AX checklist against lab-manager.

### 8.2 Context Engineering (various) -- methodology
- **Key concept**: Context is a budget. Treat every token as cost. Hierarchical instructions, phase-based workflows, document-and-clear pattern.
- **Best practices**: CLAUDE.md + skills + subagents + hooks = context engineering stack. Break work into Research > Plan > Execute > Review > Ship.
- **Our equivalent**: We do this intuitively.
- **Gap**: Not formalized. Could optimize CLAUDE.md token count.
- **Action**: **Audit** -- measure our CLAUDE.md token count, prune low-value sections.

---

## Comparison Matrix

| Tool | Stars | Category | Our Equivalent | Gap | Action |
|------|-------|----------|---------------|-----|--------|
| gstack | 52.1k | Harness/Skills | Already installed | None | **Already using** |
| superpowers | 118k | Methodology/Plugin | Already installed | Audit usage | **Already using** |
| ralph-loop | community | Autonomous loop | Already installed | None | **Already using** |
| everything-claude-code | 112k | Mega-harness | .claude/ scaffold | Dynamic contexts, instinct learning, cross-harness | **Adopt patterns** |
| oh-my-claudecode | 13.8k | Multi-agent orchestration | CTO skill | Auto model routing, skill extraction | **Adopt patterns** |
| Ruflo | ~25k | Swarm orchestration | CTO skill | WASM acceleration, self-learning | **Ignore** (too heavy) |
| Claude Squad | 6.7k | Multi-workspace TUI | CTO skill + tmux | Nicer TUI | **Watch** |
| skills.sh (npx skills) | - | Package manager | Manual install | Skill discovery, registry | **Adopt** |
| AGENTS.md standard | 20K+ repos | Cross-tool format | CLAUDE.md only | Cross-tool compat | **Adopt** |
| agent-readiness | - | Repo scoring | Nothing | No readiness scoring | **Use directly** |
| Trail of Bits security | - | Security skills | Basic rules | Security audit skills | **Adopt** |
| tweakcc | - | System prompt customization | Nothing | Toolset pruning, context optimization | **Adopt patterns** |
| claude-code-showcase | - | Reference .claude/ config | Our .claude/ | Skill suggestion, scheduled agents | **Adopt patterns** |
| Piebald system prompts | - | CC internal reference | Nothing | Understanding CC internals | **Adopt patterns** |
| AI SDLC Scaffold | - | Project template | MEMORY.md | Formal decision records | **Adopt patterns** |
| awesome-cursorrules | 38.7k | Rule templates | .claude/rules/ | General coding rules | **Adopt patterns** |
| awesome-claude-code | 33.2k | Curated list | N/A | Discovery tool | **Bookmark** |
| awesome-claude-toolkit | 17.4k | Toolkit | N/A | SkillKit access | **Adopt patterns** |
| antfu/skills | 4k | Auto-generated skills | Hand-written skills | Auto-gen from docs | **Adopt pattern** |
| Rulesync | - | Cross-tool sync | CC-only | Multi-tool support | **Ignore** (CC-native) |
| ccflare | - | Cost analytics | Nothing | Cost tracking | **Watch** |

---

## Priority Actions (Ranked)

### Immediate (This Week)
1. **Run agent-readiness scoring** on lab-manager repo -- identify structural gaps
2. **Create AGENTS.md** -- cross-tool compatibility with Codex/Gemini CLI
3. **Audit CLAUDE.md token count** -- measure context budget usage, prune low-value sections

### Short-Term (Phase 0)
4. **Install Trail of Bits security skills** -- integrate into L3 review pipeline
5. **Study Piebald system prompts** -- understand how CC handles tool descriptions, optimize our CLAUDE.md accordingly
6. **Adopt `npx skills`** -- use skills.sh for discovering domain-relevant skills

### Medium-Term (Phase 1-2)
7. **Steal from everything-claude-code**: dynamic context injection (contexts/ directory pattern)
8. **Steal from oh-my-claudecode**: auto model routing logic for CTO skill
9. **Steal from claude-code-showcase**: scheduled maintenance GitHub Actions (weekly quality, monthly docs)
10. **Steal from antfu/skills**: auto-generate skills from our OpenAPI/FastAPI docs
11. **Steal from AI SDLC Scaffold**: formal decision records alongside code

### Watch List
12. tweakcc toolset pruning (context optimization)
13. Claude Squad TUI (if CTO skill becomes unwieldy)
14. ccflare cost analytics (when team grows)
15. WASM acceleration pattern from Ruflo (long-term)

---

## Key Insights

1. **The ecosystem is massive**: 100K+ star repos (superpowers, everything-claude-code) indicate this space is mature. We're not early anymore.

2. **We're already well-positioned**: Having gstack + superpowers + ralph + CTO skill means we have ~80% of what the top harnesses provide.

3. **Biggest gaps are meta-level**:
   - No agent-readiness scoring
   - No AGENTS.md for cross-tool compat
   - No auto-generated skills from docs
   - No context budget optimization
   - No scheduled maintenance agents

4. **"Skills as packages" is the future**: Vercel's skills.sh, Anthropic's plugin marketplace, and SkillKit all point to skills becoming the npm of AI agent capabilities.

5. **Security skills are underutilized**: Trail of Bits' 93% recall dimensional analysis is a concrete win we're missing.

6. **The convergence**: CLAUDE.md, AGENTS.md, .cursorrules, copilot-instructions.md -- all converging on "markdown instructions for AI agents." The format is stabilizing.
