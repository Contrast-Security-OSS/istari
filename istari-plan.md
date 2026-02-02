---
description: Intelligent planning command that decomposes Jira tickets into actionable beads with dependencies
---

# Plan Command

When the user types the `/istari-plan` command, activate planning mode and execute the full planning workflow.

## Overview

This command orchestrates multiple AI tools to decompose a Jira ticket (format: ABCD-###) or free-form feature request into structured, dependency-aware tasks stored as beads. It creates an optimized work order and prepares the repository for multi-agent execution.

## Prerequisites

Assumes all required tools are installed:
- Superpowers (interviewing & planning)
- Compound Engineering plugin (plan expansion)
- beads & beads_viewer (task management)
- Context7 (background knowledge)
- cass_memory_system (procedural memory)
- copilot CLI (oracle when stuck)
- Atlassian MCP server (Jira integration & Confluence wiki access)
- CLI utilities: ripgrep (rg), fzf, ast-grep (sg), jq

**Run `/istari-setup` first to install all prerequisites.**

**Copilot Configuration:**
Set preferred model in copilot config file:
```bash
# Edit ~/.copilot/config.json or equivalent
# Set model to: gpt-5, gpt-4o, claude-sonnet-3.5, etc.
```

## Planning Workflow

### 1. Jira Ticket Resolution

**If user provides Jira ticket ID (format: ABCD-123):**

Use Atlassian MCP server to fetch ticket details:
- Summary/title
- Description
- Acceptance criteria
- Current status
- Priority
- Assignee

**If user provides free-form description:**

1. Analyze the description to extract:
   - Feature summary (1-line title)
   - Detailed description
   - Acceptance criteria (if mentioned)

2. Create Jira ticket via Atlassian MCP:
   - Auto-generate title from summary
   - Use description as ticket body
   - Ask user for indeterminate details:
     - Project key (PROJ, AUTH, etc.)
     - Issue type (Story, Task, Bug)
     - Priority (if not clear from context)
     - Sprint/Epic assignment

3. Receive new ticket ID (e.g., PROJ-456)

4. Use this ticket ID for all subsequent steps

### 2. Context Gathering

**Query procedural memory:**
```bash
cm context "planning best practices" --json
cm context "project architecture decisions" --json
cm context "past Jira ticket patterns" --json
```

**Review recent learnings:**
```bash
# Read recent learnings for context about recent work
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d)  # macOS: use -v-1d; Linux: use -d "yesterday"

if [ -f ".claude/learnings/$TODAY.md" ]; then
  echo "📚 Today's learnings:"
  cat ".claude/learnings/$TODAY.md"
fi

if [ -f ".claude/learnings/$YESTERDAY.md" ]; then
  echo "📚 Yesterday's learnings:"
  cat ".claude/learnings/$YESTERDAY.md"
fi

# Optionally check last few days for related topics
ls -t .claude/learnings/*.md | head -5
```

This helps with:
- Understanding recently completed work
- Avoiding duplicate planning
- Learning from recent implementation challenges
- Understanding team velocity and patterns

**Load project background knowledge:**
- Context7 is available for Claude to query when needed
- Atlassian MCP can access Contrast's Confluence wiki for documentation, architecture decisions, and team knowledge
- Check for DECISIONS.md, ARCHITECTURE.md, README.md in the repository
- Search for related past tickets via cass: `cass search "<ticket-topic>"`

**Discover existing code patterns:**
```bash
# Find similar features or components
rg "class.*Controller" --type typescript -l
rg "def.*handler" --type python -l

# Use ast-grep to find structural patterns
sg --pattern 'export class $NAME extends Controller { $$$ }' --lang typescript
sg --pattern 'async def $NAME(request: Request): $$$ }' --lang python

# Use fzf to interactively browse relevant files
fd . src/ | fzf --multi --preview 'bat --color=always {}'
```

This helps understand:
- Existing conventions (naming, structure)
- Similar implementations to reference
- Where new code should integrate

### 3. Initial Planning Phase

**Use Superpowers plugin to brainstorm and plan:**

Invoke the Superpowers brainstorming command:
```bash
/superpowers:brainstorm
```

Superpowers will guide you through:
- Asking clarifying questions about the ticket
- Understanding acceptance criteria
- Identifying technical constraints
- Determining scope boundaries
- Generating initial plan with:
  - High-level steps
  - Technical approach
  - Risk areas
  - Open questions

Work through the interactive brainstorming session to develop a comprehensive plan.

### 4. Plan Expansion

**Use Compound Engineering plugin to expand plan:**
```bash
/workflow:plan
```

This adds:
- Detailed implementation steps
- Test requirements
- Code review checkpoints
- Integration considerations

### 5. Bead Decomposition

**Break down the expanded plan into beads:**

For each logical unit of work, create a bead:
```bash
br create --title="<step-description>" \
  --type=<task|bug|feature> \
  --priority=<0-4> \
  --description="<detailed-description>"
```

**Bead types:**
- `feature` - New functionality
- `task` - Implementation work
- `bug` - Fix existing issue
- `docs` - Documentation work

**Priority levels:**
- P0 = Critical (blockers)
- P1 = High (core functionality)
- P2 = Medium (standard work)
- P3 = Low (nice-to-have)
- P4 = Backlog

**Add dependencies between beads:**
```bash
br dep add <ISSUE> <DEPENDS_ON> --type blocks
```

Where:
- `<ISSUE>` is the bead that will depend on something
- `<DEPENDS_ON>` is the bead being depended on (the blocker)
- `--type blocks` means the dependency type (default if omitted)

Example dependency patterns:
- Tests depend on implementation: `br dep add AUTH-789-tests AUTH-789-backend --type blocks`
- Integration depends on unit work
- Documentation depends on feature completion

### 6. Work Order Optimization

**Use robot planner to analyze initial work order:**
```bash
bv --robot-plan > .beads/robot-plan.json
```

This outputs JSON showing:
- Parallel work tracks
- Actionable beads (no blockers)
- Blocked beads (waiting on dependencies)
- Highest impact items (unblock the most work)

Example output:
```json
{
  "tracks": [
    {
      "track_id": "track-A",
      "reason": "Independent work stream",
      "items": [
        { "id": "AUTH-001", "priority": 1, "unblocks": ["AUTH-002", "AUTH-003"] }
      ]
    }
  ],
  "total_actionable": 3,
  "total_blocked": 5,
  "summary": {
    "highest_impact": "AUTH-001",
    "impact_reason": "Unblocks 3 tasks"
  }
}
```

Review the suggested work order and present to user.

**Note:** The `/work` command will re-run `bv --robot-plan` dynamically when selecting each bead, as the work landscape changes when beads complete.

### 7. Feature Branch Creation

**Create Jira-prefixed feature branch:**
```bash
# Extract Jira ticket number (format: ABCD-123)
# Create branch: ABCD-123_<descriptive-name>
# Note: Uses underscore, not hyphen

git checkout main
git pull origin main
git checkout -b <JIRA-ID>_<feature-slug>
git push -u origin <JIRA-ID>_<feature-slug>
```

Example: `PROJ-456_oauth-login-implementation`

### 8. Plan Introspection & Learning

**Reflect on the planning session:**
- What patterns emerged?
- What architectural decisions were made?
- What risks were identified?
- What assumptions need validation?

**Save learnings:**
```bash
# Use daily learning files to prevent unbounded growth
LEARNING_FILE=".claude/learnings/$(date +%Y-%m-%d).md"
mkdir -p .claude/learnings

cat >> "$LEARNING_FILE" << EOF

## [$(date +%H:%M)] Planning: <JIRA-ID> - <ticket-summary>

**Key Learnings:**
- <learning-1>
- <learning-2>
- <learning-3>

**Architectural Decisions:**
- <decision-1>
- <decision-2>

**Risks Identified:**
- <risk-1>
- <risk-2>

**Follow-up Questions:**
- <question-1>
- <question-2>

---
EOF
```

**Store in procedural memory:**
```bash
# After completing planning, reflect on the session to extract learnings
cm reflect --json
```

### 9. Summary & Handoff

**Present plan summary to user:**
- Jira Ticket: <JIRA-ID>
- Total beads created: X
- Initial work order (from robot-plan):
  - Track A: [actionable bead IDs]
  - Track B: [actionable bead IDs]
  - Blocked: [blocked bead IDs]
- Highest impact first bead: <bead-id>
- Feature branch: <JIRA-ID>_<feature-slug>
- Next steps: Run `/work` to begin execution

**Commit planning artifacts:**
```bash
br sync  # Commits beads to .beads/ directory
# Note: .claude/learnings/ and docs/plans/ are local only (excluded by .gitignore)
git commit -m "Planning: <JIRA-ID> - <summary>"
git push
```

## Oracle Consultation (When Stuck)

If planning encounters ambiguity or technical uncertainty:

**Consult Copilot (quick tactical advice):**
```bash
copilot -p "How should we structure <specific-technical-question>?" \
  --allow-tool 'shell' \
  --deny-tool 'write' \
  --deny-tool 'shell(rm)' \
  --deny-tool 'shell(git push)' \
  --deny-tool 'shell(git commit)'
```

Safety constraints prevent copilot from making destructive changes.

Use oracle responses to refine the plan before creating beads.

## Error Handling

- If Superpowers fails: Fall back to manual interview questions
- If /workflow:plan unavailable: Use expanded Superpowers output
- If bv --robot-planner fails: Use manual dependency-aware ordering
- If Context7 unavailable: Rely on code search and documentation

## Success Criteria

Planning is complete when:
- ✅ All beads created with clear descriptions
- ✅ Dependencies properly mapped
- ✅ Work order optimized
- ✅ Feature branch created and pushed
- ✅ Learnings documented
- ✅ User confirms plan looks good

## Example Invocation

```
User: /plan Implement two-factor authentication

[Claude activates planning mode]
[User didn't provide Jira ID]
[Generates ticket title: "Implement Two-Factor Authentication"]
[Asks user: "Which project? (PROJ, AUTH, etc.)" → User: "AUTH"]
[Creates Jira ticket via Atlassian MCP → AUTH-789]
[Queries cm for auth-related learnings]
[Uses Superpowers /plan to interview user about requirements]
[Uses /workflow:plan to expand into detailed steps]
[Creates beads with dependencies:]
  - AUTH-789-backend (P1, task)
  - AUTH-789-frontend (P1, task, depends-on: backend)
  - AUTH-789-tests (P2, task, depends-on: backend, frontend)
  - AUTH-789-docs (P3, docs, depends-on: tests)
[Runs bv --robot-plan]
[Robot plan output shows:]
  - Track A: AUTH-789-backend (actionable, unblocks 2)
  - Track B: (empty - all items blocked)
  - Blocked: AUTH-789-frontend, AUTH-789-tests, AUTH-789-docs
[Creates branch: AUTH-789_two-factor-auth]
[Documents learnings about auth patterns]
[Presents summary]

Ready to execute! Run /work to begin implementation.
Suggested first bead: AUTH-789-backend (highest impact)
```
