# Istari

**Autonomous AI coding agents powered by Claude Code**

Turn Claude into a self-directed software development team that plans features, executes work in parallel, and maintains quality through comprehensive automated reviews.

```
                       ,---.
                       /    |
                      /     |
  Istari             /      |
                    /       |
               ___,'        |
             <  -'          :
              `-.__..--'``-,_\_
                 |o/ <o>` :,.)_`>
                 :/ `     ||/)
                 (_.).__,-` |\
                 /( `.``   `| :
                 \'`-.)  `  ; ;
                 | `       /-<
                 |     `  /   `.
 ,-_-..____     /|  `    :__..-'\
/,'-.__\\  ``-./ :`      ;       \
`\ `\  `\\  \ :  (   `  /  ,   `. \
  \` \   \\   |  | `   :  :     .\ \
   \ `\_  ))  :  ;     |  |      ): :
  (`-.-'\ ||  |\ \   ` ;  ;       | |
   \-_   `;;._   ( `  /  /_       | |
    `-.-.// ,'`-._\__/_,'         ; |
       \:: :     /     `     ,   /  |
        || |    (        ,' /   /   |
        ||                ,'   / SSt|
```

## Executive Summary

Istari is a complete AI-driven software development workflow built on Claude Code. It provides three slash commands that transform feature requests into production-ready code through:

- **Intelligent decomposition** of Jira tickets into dependency-aware tasks ("beads")
- **Parallel autonomous execution** by multiple AI agents coordinating via message passing
- **Built-in quality gates** including TDD, static analysis, and multi-tool code reviews
- **Institutional knowledge capture** through daily learning files and procedural memory
- **Zero-conflict collaboration** via file reservation system for parallel agents

The result: Define a feature once, then let multiple Claude instances work autonomously in parallel while you focus on higher-level decisions.

## Toolchain Overview

Istari establishes a comprehensive AI coding environment by integrating:

### Core Development Tools
- **beads/beads_viewer** - Task management with dependency tracking and robot planner for optimal work ordering
- **ultimate_bug_scanner** - Pre-commit static analysis detecting 1000+ bug patterns across 7 languages
- **mcp_agent_mail** - Inter-agent messaging and file reservation system for conflict-free parallel work
- **cass_memory_system** - Procedural memory for storing coding standards and lessons learned
- **coding_agent_session_search** - Historical session search for finding past solutions

### Enhanced Productivity
- **ripgrep (rg)** - Fast code search across large codebases
- **ast-grep (sg)** - Structural code search using AST patterns
- **fzf** - Fuzzy file finding for rapid navigation
- **lazygit** - Interactive git TUI for reviewing changes
- **jq** - JSON processing for parsing tool outputs

### AI Orchestration
- **Copilot CLI** - Oracle for complex queries (defaults to grok-code-fast-1 for speed)
- **Superpowers** - Claude Code plugin for TDD guidance and code review
- **Compound Engineering** - Claude Code plugin for plan expansion
- **Context7** - MCP server providing up-to-date library documentation (requires API key)
- **Atlassian** - MCP server for Jira/Confluence integration (OAuth)

### Purpose
This toolchain enables **autonomous multi-agent execution** where multiple Claude instances can:
1. Work in parallel without conflicts (via agent_mail file reservations)
2. Make informed decisions (via Context7, Confluence, procedural memory)
3. Maintain quality (via TDD, bug scanning, multi-tool reviews)
4. Learn and improve (via daily learning files shared across agents)
5. Consult oracles when stuck (via Copilot CLI)

## Setup Instructions

### 1. Install Istari Commands

Create a `.claude/commands` folder in the **parent directory** of your project folders:

```bash
# If your projects are in ~/projects/*, create:
cd ~
mkdir -p .claude/commands

# Clone or download the istari command files
cd .claude/commands
curl -O https://raw.githubusercontent.com/your-org/istari/main/istari-setup.md
curl -O https://raw.githubusercontent.com/your-org/istari/main/istari-plan.md
curl -O https://raw.githubusercontent.com/your-org/istari/main/istari-work.md
```

**Why parent directory?** Claude Code searches upward from your project for `.claude/commands`, making these commands available across all your projects from a single location.

### 2. Verify Installation

Open Claude Code in any project and type `/` - you should see:
- `/istari-setup`
- `/istari-plan`
- `/istari-work`

### 3. Run Setup Command

In Claude Code, run:
```
/istari-setup
```

This will interactively install all toolchain components (see detailed breakdown below).  This only needs to be run once unless a tool installation needs to be repaired.  You are then ready to use `/istari-plan` to plan new work and `/istari-work` to get one or more Claude Code instances working on the plan in your project.

## Command Reference

### `/istari-setup` - Environment Preparation

**What it does:** Verifies and installs all required tools, plugins, and MCP servers.

**Interactive workflow:**
1. Detects your OS (macOS/Linux) and package manager
2. Checks each tool and offers to install missing components
3. Configures Claude Code plugins (Superpowers, Compound Engineering)
4. Sets up MCP servers (Context7, Atlassian) with API credentials
5. Generates comprehensive status report

**Side effects and required credentials:**

- **Copilot CLI configuration** - Creates `~/.copilot/config.json` with:
  ```json
  {
    "model": "grok-code-fast-1",
    "temperature": 0.2,
    "maxTokens": 8192
  }
  ```
  You can change the model later, but grok-code-fast-1 is recommended for speed.

- **Claude Code configuration** - Updates `~/.claude.json` with:
  ```json
  {
    "maxTokens": 200000
  }
  ```
  This enables extended context for large codebases.

- **Context7 API key** - You'll be prompted to:
  1. Visit https://context7.com/dashboard
  2. Create a free account
  3. Generate an API key
  4. Enter it during setup

  Context7 provides real-time documentation for any library, eliminating hallucinated API calls.

- **Atlassian OAuth** - After installation, run `/mcp` in Claude Code to:
  1. Authenticate via browser OAuth flow
  2. Grant access to your Jira/Confluence instance
  
  This enables automatic Jira ticket fetching and Confluence wiki queries.

- **Agent mail server** - Starts a background process on `localhost:8765` for inter-agent messaging.

**When to run:** Once per machine, or when adding new projects that need the toolchain.

---

### `/istari-plan` - Intelligent Feature Planning

**What it does:** Decomposes Jira tickets or feature descriptions into structured, dependency-aware beads.

**Input formats:**
```
/istari-plan PROJ-123
/istari-plan Implement two-factor authentication with TOTP support
```

**Workflow:**
1. **Fetches ticket details** (if Jira ID) or creates new ticket (if description)
2. **Loads context** from:
   - Recent learnings (`.claude/learnings/`)
   - Procedural memory (cass)
   - Confluence wiki (via Atlassian MCP)
   - Existing codebase (via ripgrep/ast-grep)
3. **Interactive brainstorming** with Superpowers:
   - Clarifying questions about requirements
   - Technical constraints discussion
   - Risk identification
4. **Plan expansion** with Compound Engineering:
   - Breaks feature into granular tasks
   - Identifies dependencies
   - Estimates complexity
5. **Bead creation** with:
   - Clear acceptance criteria
   - Dependency links
   - Priority/complexity scores
6. **Robot plan generation** showing:
   - Actionable beads (no blockers)
   - Blocked beads (waiting on dependencies)
   - Optimal execution order for parallelization

**Outputs:**
- `.beads/` directory with task definitions
- `.beads/robot-plan.json` for dynamic work selection
- `.claude/learnings/YYYY-MM-DD.md` with planning insights

**Side effects:**
- May create new Jira ticket if free-form description provided
- Commits planning artifacts to git (update your .gitignore file to ignore /docs/plans if this isn't desired)
- Syncs beads to remote repository

**When to run:** Once per feature/ticket before starting implementation.

---

### `/istari-work` - Autonomous Development Execution

**What it does:** Activates autonomous agent mode to execute beads using TDD and quality gates.

**Prerequisites:**
- Must have beads created (run `/istari-plan` first)
- Must be on a feature branch (format: `JIRA-ID_feature-name`)

**Autonomous workflow:**

1. **Initialization:**
   - Loads procedural memory and recent learnings
   - Registers with agent_mail using unique name (e.g., `claude_dev_purple_falcon_20251222_143052`)
   - Checks inbox for coordination messages

2. **Bead selection:**
   - Runs `bv --robot-plan` to get fresh work landscape
   - Selects highest-impact actionable bead (unblocks most work)
   - Announces work start via agent_mail

3. **File reservation:**
   - Uses `ast-grep` and `ripgrep` to identify affected files
   - **Checks reservations** via `am check_reservation <pattern>`
   - Reserves files exclusively via `am reserve <pattern>`
   - If conflict: Messages other agent to coordinate or selects different bead

4. **TDD implementation:**
   - Uses Superpowers for Red-Green-Refactor guidance
   - Searches codebase for existing patterns (ripgrep/ast-grep)
   - Writes failing test first
   - Implements minimal code to pass
   - Refactors for quality
   - Consults Copilot CLI oracle if stuck after 2 attempts

5. **Quality gates (MANDATORY - ALL must pass):**
   - ✅ All tests passing
   - ✅ UBS scan clean or warnings-only
   - ✅ Superpowers review
   - ✅ `/review` (Claude built-in)
   - ✅ `/security-review`
   - ✅ `/workflow:review` (Compound Engineering)
   - ✅ All critical issues resolved

   **Agents cannot skip reviews** - failure to run all reviews means the bead is incomplete.

6. **Commit and learn:**
   - Creates descriptive commit message linking to bead ID
   - Pushes to feature branch
   - Documents learnings in `.claude/learnings/YYYY-MM-DD.md` (you may also want to add this to .gitignore)
   - Stores patterns in procedural memory (cass)

7. **Cleanup:**
   - Closes bead
   - Releases file reservations
   - Syncs beads to git
   - Announces completion via agent_mail

8. **Loop or finish:**
   - If more beads: Returns to step 2
   - If last bead: Creates comprehensive PR with review evidence

**Multi-agent parallelization:**
- Run `/istari-work` in multiple Claude Code windows simultaneously
- Agents coordinate via agent_mail to avoid file conflicts
- Each agent works on different beads in parallel
- Shared learning files provide context continuity

**Side effects:**
- Commits code to feature branch
- Creates/updates `.claude/learnings/` files (committed to git)
- Sends messages via agent_mail (local server only)
- May create PR when all beads complete
- Updates procedural memory (persists across sessions)

**Error handling:**
- Tests fail after 2 attempts: Consults Copilot oracle
- File reservation conflict: Coordinates via agent_mail or switches beads
- Review critical issues: Max 2 fix attempts, then asks user for override
- Out-of-scope review issues: Offers to create separate cleanup bead

**When to run:** 
- After `/istari-plan` creates beads
- Can run multiple instances for parallel execution
- Continues autonomously until all beads complete or user intervention needed

---

## Daily Workflow Example

```bash
# Morning: Check what needs planning
cd ~/projects/myapp
git checkout -b AUTH-456_two-factor-auth

# Plan the feature
/istari-plan AUTH-456

# [Claude interactively plans, creates 8 beads with dependencies]

# Start autonomous execution (can run in multiple windows)
# Window 1:
/istari-work

# Window 2 (parallel agent):
/istari-work

# [Both agents coordinate via agent_mail, work on different beads]
# [Agent 1: Implements backend TOTP generation]
# [Agent 2: Implements frontend UI (waits for backend)]
# [Both run TDD, quality gates, document learnings]

# End of day: Review PR created by agents
gh pr view

# Next day: Agents read yesterday's learnings automatically
/istari-work
```

## Learning and Memory System

Istari captures institutional knowledge automatically:

- **Daily learning files** (`.claude/learnings/YYYY-MM-DD.md`) - Readable markdown logs of:
  - What worked well
  - Challenges encountered and solutions
  - Code patterns discovered
  - Retrospective notes

- **Procedural memory** (cass) - Queryable database of:
  - Coding standards
  - Testing patterns
  - Common pitfalls
  - Project conventions

Both systems are **automatically consulted** at the start of each `/istari-plan` and `/istari-work` session, ensuring agents learn from past work.

## Troubleshooting

**Commands not showing in `/` menu:**
- Verify `.claude/commands` is in parent directory of your projects
- Restart Claude Code
- Check file permissions on command files

**Context7 API errors:**
- Verify API key is valid at https://context7.com/dashboard
- Check MCP configuration: `cat ~/.claude.json | grep context7`
- Re-run `/istari-setup` to reconfigure

**Agent mail connection failures:**
- Check if server is running: `curl http://localhost:8765/`
- Restart server: `am server restart`
- Check logs: `am server logs`

**Tools not found after setup:**
- Check PATH includes cargo/bin: `echo $PATH | grep cargo`
- Source shell config: `source ~/.zshrc` (or ~/.bashrc)
- Re-run setup: `/istari-setup`

**Reviews being skipped:**
- Section 6 of `/istari-work` is **MANDATORY**
- Agents must run ALL 4 reviews before commit
- Check success criteria checklist at end of work session

## Contributing

Istari commands are designed to be forked and customized for your team's workflow. Common customizations:

- Change default Copilot model in setup
- Add team-specific quality gates
- Customize bead complexity estimation
- Add additional MCP servers for team tools


