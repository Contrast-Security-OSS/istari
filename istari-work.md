---
description: Autonomous software development agent that executes beads with TDD, code review, and multi-agent coordination
---

# Work Command

When the user types the `/istari-work` command, activate autonomous development mode and execute beads with full quality gates.

## Overview

This command transforms Claude into a self-directed software development agent that:
- Coordinates with other agents via mcp_agent_mail
- Works on beads in priority order
- Follows test-driven development
- Runs comprehensive quality checks
- Handles review feedback automatically
- Creates PRs when Jira tickets are complete

## Prerequisites

Assumes all required tools are installed:
- beads & beads_viewer (task management)
- mcp_agent_mail (agent coordination)
- ultimate_bug_scanner (pre-commit scanning)
- Superpowers (TDD support & review)
- Context7 (background knowledge)
- cass_memory_system (procedural memory)
- copilot CLI (oracle when stuck)
- CLI utilities: ripgrep (rg), fzf, ast-grep (sg), jq
- Git tools: git, gh, lazygit

**Run `/istari-setup` first to install all prerequisites.**

**Copilot Configuration:**
Set preferred model in copilot config file:
```bash
# Edit ~/.copilot/config.json or equivalent
# Recommended models:
#   - grok-code-fast-1 (fast code queries)
#   - gpt-5 (deep reasoning)
#   - claude-sonnet-3.5 (balanced)
```

## Work Execution Loop

### 1. Initialization & Context Loading

**Load procedural memory:**
```bash
cm context "coding standards" --json
cm context "testing patterns" --json
cm context "common pitfalls" --json
cm context "project conventions" --json
```

**Review recent learnings:**
```bash
# Read today's and yesterday's learnings for context continuity
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
```

This provides:
- Recent implementation patterns
- Known pitfalls to avoid
- Helpful techniques discovered
- Context about what was recently worked on

**Access Confluence wiki knowledge (via Atlassian MCP):**
- Query Contrast's Confluence wiki for:
  - Architecture documentation
  - API specifications
  - Team conventions and standards
  - Troubleshooting guides
  - Deployment procedures

**Register with agent mail (auto-generate unique name):**
```bash
# Generate memorable unique agent name with color, animal, and microsecond timestamp
AGENT_NAME=$(python3 -c "
import random
from datetime import datetime
colors = ['red', 'blue', 'green', 'purple', 'orange', 'yellow', 'cyan', 'magenta', 'crimson', 'teal']
animals = ['tiger', 'eagle', 'wolf', 'bear', 'falcon', 'panther', 'hawk', 'lion', 'fox', 'orca']
color = random.choice(colors)
animal = random.choice(animals)
timestamp = datetime.now().strftime('%Y%m%d_%H%M%S_%f')
print(f'claude_dev_{color}_{animal}_{timestamp}')
")
am register_agent --name "$AGENT_NAME" --project $(pwd)
```

Example name: `claude_dev_purple_falcon_20251222_143052_847293`

This creates memorable, unique agent names for easy identification in agent mail messages while ensuring no collisions between parallel workers.

**Check agent inbox:**
```bash
am inbox --limit 20
```

Read any coordination messages from other agents.

**Identify current Jira ticket context:**
```bash
# Get current branch name
git rev-parse --abbrev-ref HEAD
# Extract Jira ticket ID (format: ABCD-123_feature-name)
# Branch pattern: <JIRA-ID>_<feature-slug>
```

### 2. Bead Selection

**Run dynamic robot planner (in agent-specific temp directory):**
```bash
# Create agent-specific temp directory to avoid conflicts with parallel workers
mkdir -p "/tmp/$AGENT_NAME"
bv --robot-plan > "/tmp/$AGENT_NAME/robot-plan.json"
```

This generates fresh analysis of current work landscape:
```json
{
  "tracks": [...],
  "total_actionable": 3,
  "total_blocked": 5,
  "summary": {
    "highest_impact": "AUTH-001",
    "impact_reason": "Unblocks 3 tasks",
    "unblocks_count": 3
  }
}
```

**Auto-select from actionable beads:**
1. Parse `robot-plan.json`
2. Look at `total_actionable` beads (no blockers)
3. Select `summary.highest_impact` bead (unblocks most work)
4. If tied on impact, use priority: P0 > P1 > P2 > P3
5. If still tied, pick oldest created

**Why dynamic?** The work landscape changes as beads complete. Re-running robot-plan ensures optimal selection.

**Announce work start via agent mail:**
```bash
am send --to all_agents --thread <JIRA-ID> \
  "Starting work on bead <bead-id>: <title>"
```

### 3. File Reservation (Avoid Conflicts)

**Determine files to modify:**
- Analyze bead description
- Use ripgrep to find relevant code:
  ```bash
  # Find all files containing a class/function/pattern
  rg --type python "class AuthService" --files-with-matches
  rg --type typescript "import.*Button" -l
  ```
- Use ast-grep for structural search:
  ```bash
  # Find all function calls to a specific method
  sg --pattern 'api.authenticate($$$)' --lang typescript
  # Find all class definitions
  sg --pattern 'class $NAME { $$$ }' --lang python
  ```
- Use fzf for interactive file finding:
  ```bash
  # Fuzzy find files to identify scope
  fd . src/ | fzf --preview 'bat --color=always {}'
  ```
- Identify affected files/directories

**Check if files are already reserved by another agent:**
```bash
am check_reservation "<file-pattern>" --project $(pwd)
```

This returns:
- `AVAILABLE` - No conflicts, safe to proceed
- `RESERVED_BY: <agent-name> (expires: <timestamp>)` - Another agent has the file

**If files are reserved:**
1. **Check who has it:**
   ```bash
   am check_reservation "<file-pattern>" --project $(pwd)
   ```
2. **Message that agent to coordinate:**
   ```bash
   am send --to <agent-name> --thread <JIRA-ID> \
     "I need to work on <file-pattern> for bead <bead-id>. Can we coordinate?"
   ```
3. **Options:**
   - Wait for release (check inbox for coordination)
   - Work on different bead (skip to step 2)
   - If urgent: Ask user for guidance

**If files are available, reserve them:**
```bash
am reserve "<file-pattern>" --exclusive --ttl 3600 --project $(pwd)
```

Examples:
- `src/auth/**` - Reserve entire auth directory
- `src/components/Button.tsx` - Reserve specific file

**Successful reservation confirmation:**
```
✓ Reserved <file-pattern>
  Agent: $AGENT_NAME
  Expires: <timestamp>
  Project: $(pwd)
```

### 4. Implementation Phase

**Update bead status:**
```bash
bd update <bead-id> --status=in_progress
```

**Query Context7 for background knowledge** (when needed):
- Context7 is available for Claude to use
- Provides project-specific context and patterns

**Query Confluence wiki** (via Atlassian MCP):
- Access Contrast's Confluence wiki for documentation
- Search for relevant architectural decisions, API docs, and team knowledge
- Use for understanding existing patterns and established conventions

**Check past sessions for similar work:**
```bash
cass search "<bead-topic>"
```

Review relevant past implementations.

**Search codebase for existing patterns:**
```bash
# Find similar implementations
rg "class.*Service" --type typescript

# Find usage examples
rg "authenticate\(" --context 3

# Use ast-grep for structural patterns
sg --pattern 'async function $NAME($$$) { $$$ }' --lang typescript
```

**Test-Driven Development with Superpowers:**

Superpowers is a Claude Code plugin. Use it naturally:

"Use Superpowers to help with TDD for <feature-description>"

Superpowers guides through Red-Green-Refactor cycle:
1. **Write failing test first** (Red)
2. **Implement minimal code** (Green)
3. **Refactor for quality** (Refactor)

**Run project tests:**
```bash
# Detect test command from package.json, Makefile, etc.
# Examples:
npm test
# or
bun test
# or
pytest
# or
go test ./...
```

**Test failure handling:**
- Attempt 1: Analyze failure, fix code, re-run
- Attempt 2: Consult copilot oracle, fix, re-run
- If still failing: Ask user for guidance

**Oracle consultation when stuck:**

After 2 failed attempts or complex architectural decision:

```bash
copilot -p "Why is <specific-test> failing? Error: <error-message>" \
  --allow-tool 'shell' \
  --deny-tool 'write' \
  --deny-tool 'shell(rm)' \
  --deny-tool 'shell(git push)' \
  --deny-tool 'shell(git commit)'
```

### 5. Pre-Commit Quality Gates

**Run ultimate_bug_scanner:**
```bash
git add <changed-files>
ubs scan --staged
```

**Fix any critical issues found:**
- Iterate on fixes
- Re-run ubs until clean or warnings-only

**Stage all changes:**
```bash
git add .
```

### 6. Post-Implementation Review (MANDATORY - DO NOT SKIP)

**⚠️ CRITICAL: All reviews must be run before committing. Do NOT skip this step.**

**Step 1: Run Superpowers review (REQUIRED):**

Ask naturally: "Use Superpowers to review my staged changes"

Wait for feedback before proceeding.

**Step 2: Run Claude's built-in reviews (REQUIRED):**
```bash
/review
/security-review
```

Run BOTH commands. Wait for each to complete.

**Step 3: Run Compound Engineering review (REQUIRED):**
```bash
/workflow:review
```

Wait for completion.

**Step 4: Aggregate ALL review feedback:**
- Critical issues: MUST fix before commit (non-negotiable)
- Warnings: Ask user for guidance
- No issues: Proceed to commit

**If ANY review shows critical issues, you MUST fix them. Do NOT proceed to commit.**

**Fix critical issues with retry tracking:**

```bash
# Track retry attempts for each unique review issue
declare -A review_retry_counts
MAX_RETRIES_PER_ISSUE=2
```

For each critical issue:
1. Check if already tried fixing this issue
2. If `review_retry_counts[<issue-hash>] >= MAX_RETRIES_PER_ISSUE`:
   - Ask user for override authorization
3. Otherwise:
   - Attempt fix
   - Re-run tests
   - Re-run ubs
   - Re-run reviews
   - Increment `review_retry_counts[<issue-hash>]`
4. Repeat until clean or max retries reached

**When to ask for override:**

```
Review issue stuck after 2 attempts:
- Issue: <critical-issue-description>
- Attempted fixes:
  1. <attempt-1-description>
  2. <attempt-2-description>
- Test results: <passing/failing>
- Oracle consulted: <copilot/gemini suggestion>

This issue may be:
a) Out of scope for this bead (relates to existing code)
b) Requires architectural decision
c) Tool false positive

Options:
1. Override this review gate and proceed with commit
2. Try oracle's suggested fix
3. Mark bead as blocked, notify human via agent mail
4. Provide your own fix suggestion

Choose option (1-4):
```

**Out-of-scope detection:**

If review issue references files not modified in this bead:
```
Review flagged issue in unmodified code:
- File: <file-path>
- Issue: <description>
- This file was NOT changed in current bead

This appears out of scope for the current work.

Proceed anyway? (yes/no)
If yes, will mark for separate cleanup bead.
```

If warnings only:
```
Ask user: "Reviews found warnings (not critical):
- <warning-1>
- <warning-2>

Proceed with commit? (yes/no)"
```

### 7. Commit Work (Only After Reviews Pass)

**⚠️ BLOCKER: Do NOT commit until:**
- ✅ All tests passing
- ✅ UBS scan clean or warnings-only
- ✅ Superpowers review complete
- ✅ `/review` complete
- ✅ `/security-review` complete  
- ✅ `/workflow:review` complete
- ✅ All critical issues resolved

**Create meaningful commit message:**
```bash
git commit -m "<JIRA-ID>: <bead-title>

- <change-1>
- <change-2>
- <change-3>

Bead ID: <bead-id>
Tests: passing
Reviews: clean"
```

**Push to feature branch:**
```bash
git push origin HEAD
```

### 8. Bead Introspection & Learning

**Reflect on the implementation:**
- What worked well?
- What was challenging?
- What patterns emerged?
- What would I do differently?

**Save learnings:**
```bash
# Use daily learning files to prevent unbounded growth
LEARNING_FILE=".claude/learnings/$(date +%Y-%m-%d).md"
mkdir -p .claude/learnings

cat >> "$LEARNING_FILE" << EOF

## [$(date +%H:%M)] Bead <bead-id> - <bead-title>

**Approach:**
<describe-implementation-approach>

**Challenges:**
- <challenge-1>: <how-resolved>
- <challenge-2>: <how-resolved>

**Learnings:**
- <learning-1>
- <learning-2>

**Code Patterns Used:**
- <pattern-1>
- <pattern-2>

**Would Do Differently:**
- <reflection-1>

---
EOF
```

**Store in procedural memory:**
```bash
# After completing work, reflect on the session to extract learnings
cm reflect --json
```

**Note:** Learnings in `.claude/learnings/` and plans in `docs/plans/` are local only (excluded by .gitignore). They are not committed to git.

### 9. Bead Completion & Cleanup

**Close completed bead:**
```bash
bd close <bead-id> --reason "Implementation complete, tests passing, reviews clean"
```

**Release file reservations:**
```bash
am release "<file-pattern>" --project $(pwd)
```

**Sync beads to git:**
```bash
bd sync
```

**Notify via agent mail:**
```bash
am send --to all_agents --thread <JIRA-ID> \
  "Completed bead <bead-id>. Files released: <file-pattern>"
```

### 10. Determine Next Action

**Check for more open beads:**
```bash
bd list --status=open --filter="jira:<JIRA-ID>"
```

**If more beads exist:**
- Loop back to step 2 (Bead Selection)
- Continue working on next bead

**If this was the LAST bead for the Jira ticket:**

Proceed to PR creation workflow →

## PR Creation Workflow (Last Bead)

When completing the final bead for a Jira ticket:

### 1. Sync with Other Agents

**Pull latest changes:**
```bash
git pull --rebase origin <feature-branch>
```

Other agents may have committed to the same feature branch.

### 2. Comprehensive Review of Full Feature

**Run full test suite:**
```bash
# Run ALL project tests (not just changed files)
npm test  # or appropriate command
```

**Scan entire feature branch:**
```bash
git diff main..HEAD | ubs scan --diff
```

**Review all commits in feature branch:**
```bash
git log main..HEAD --oneline
```

Or use lazygit for interactive review:
```bash
lazygit
# Press 'l' to view log
# Press '3' to see diff
# Press 'q' to quit
```

Check for:
- Commit message quality
- Logical grouping
- No debug code left behind
- Use ripgrep to find debug statements:
  ```bash
  rg "console\.log|debugger|TODO|FIXME" --type typescript
  rg "print\(|import pdb" --type python
  ```

**Run all review tools on full diff:**
```bash
git diff main..HEAD > /tmp/feature.diff

# Ask naturally: "Use Superpowers to review this feature diff"
/review --scope branch
/security-review --scope branch
/workflow:review --scope branch
```

### 3. Address Review Findings

**Fix any critical issues across the entire feature:**
- Update code
- Re-run tests
- Re-scan with ubs
- Re-review

**Commit fixes:**
```bash
git add .
git commit -m "<JIRA-ID>: Address review findings for full feature

- <fix-1>
- <fix-2>
"
git push
```

### 4. Create Pull Request

**Generate PR description:**
```bash
gh pr create \
  --title "<JIRA-ID>: <feature-summary>" \
  --body "## Summary
Implements <feature-description>

## Jira Ticket
<JIRA-ID>

## Changes Overview 
- <change-1>
- <change-2>
- <change-3>

## Testing
- ✅ All unit tests passing
- ✅ Integration tests passing
- ✅ Manual testing completed

## Reviews
- ✅ ultimate_bug_scanner: clean
- ✅ Superpowers review: approved
- ✅ Security review: no issues
- ✅ Compound Engineering review: approved

" \
  --base main \
  --head <feature-branch>
```

**Notify team:**
```bash
am send --to all_agents --thread <JIRA-ID> \
  "PR created for <JIRA-ID>: <pr-url>. All beads complete. Ready for human review."
```

**Report completion:**
```
✅ Work Complete!

Jira Ticket: <JIRA-ID>
Beads Completed: <count>
Feature Branch: <branch-name>
PR: <pr-url>

All tests passing ✓
All reviews clean ✓
Ready for team review.
```

## Error Handling & Recovery

**Test failures after 2 attempts:**
```
Tests failing after 2 attempts:
<test-output>

Oracle consulted: <copilot/gemini-suggestion>

Need your guidance:
1. Should I try oracle's suggestion?
2. Should I skip this test temporarily?
3. Would you like to debug interactively?
```

**Agent mail file reservation conflicts:**

Before starting work, ALWAYS check if files are reserved:
```bash
am check_reservation "<file-pattern>" --project $(pwd)
```

If conflict detected:
```
⚠️  File reservation conflict on <file-pattern>
Reserved by: <agent-name>
Expires in: <time-remaining>

Actions:
1. Message agent to coordinate timing
   am send --to <agent-name> "Need <file-pattern> for bead <bead-id>"
2. Wait for release (check inbox periodically)
3. Work on different bead (return to step 2)
4. If urgent: Escalate to user
```

**Never proceed with work on reserved files without coordination.**

**Review shows critical issues:**
```
Critical issues found by <review-tool>:
- <issue-1>
- <issue-2>

Fixing automatically... [attempt 1/2]
```

## Success Criteria Per Bead

- ✅ Bead selected from ready list
- ✅ Files reserved (no conflicts)
- ✅ Tests written (TDD)
- ✅ Tests passing
- ✅ UBS scan clean
- ✅ **ALL reviews run and passed:**
  - ✅ Superpowers review
  - ✅ `/review`
  - ✅ `/security-review`
  - ✅ `/workflow:review`
- ✅ All critical issues resolved
- ✅ Commit pushed
- ✅ Learnings documented
- ✅ Bead closed
- ✅ Files released

**⚠️ If reviews were skipped, the bead is NOT complete. Return to step 6.**

## Example Invocation

```
User: /work

[Claude activates work mode]
[Loads procedural memory]
[Registers with agent mail]
[Checks inbox - no messages]
[Current branch: PROJ-789_two-factor-auth]
[Runs bv --robot-plan]
[Robot plan shows:]
  - Actionable: bead-42 (AUTH-backend, unblocks 2)
  - Blocked: bead-43, bead-44, bead-45
[Selects: bead-42 "Implement TOTP backend" (highest impact)]
[Announces work start]
[Reserves src/auth/totp/**]
[Uses Superpowers for TDD]
[Writes failing test for TOTP generation]
[Implements TOTP generation]
[Tests pass]
[Runs ubs scan - clean]
[Runs all reviews - clean]
[Commits work]
[Documents learnings about TOTP patterns]
[Closes bead-42]
[Releases src/auth/totp/**]
[Syncs beads]
[Runs robot-plan again - landscape changed!]
  - Actionable: bead-43 (TOTP frontend - now unblocked), bead-99 (parallel work)
  - Blocked: bead-44, bead-45
[Selects next: bead-43 "TOTP frontend UI"]
[Repeats process...]

[After bead-45 completes - last bead]
[Pulls latest from other agents]
[Reviews full feature branch]
[All tests passing]
[All reviews clean]
[Creates PR]

✅ PR created: https://github.com/org/repo/pull/123
All beads for PROJ-789 complete. Ready for team review!
```
