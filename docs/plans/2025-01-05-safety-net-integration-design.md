# Claude Code Safety Net Integration Design

**Date:** 2025-01-05
**Status:** Ready for Implementation
**Jira Project:** AIML

## Overview

Integrate the claude-code-safety-net plugin into Istari to prevent destructive git and filesystem commands during autonomous AI coding sessions.

## Background

The claude-code-safety-net plugin blocks dangerous commands that could wipe out work:
- Force pushes (`git push --force`)
- Branch deletions (`git branch -D`)
- Hard resets that discard changes (`git reset --hard`)
- Risky file deletion operations (`rm -rf` outside working directory)

**Source:** https://github.com/kenryu42/claude-code-safety-net

**Why this matters for Istari:**
Autonomous agents executing `/istari-work` can make git operations without user oversight. Safety Net prevents accidents where hours of work could be lost to a single destructive command.

## Design Decisions

### 1. Global vs. Istari-Only Protection

**Decision:** Global protection (active in all Claude Code sessions)

**Rationale:**
- Conditional plugin activation is not supported by Claude Code plugin API
- Reimplementing the safety parser would be complex and error-prone
- Global protection provides value outside Istari workflows
- No significant downside - plugin only blocks truly dangerous commands

### 2. Safety Mode

**Decision:** Standard mode (default)

**Options considered:**
- Standard - Blocks known dangerous commands
- Strict - Fails closed on unparseable commands
- Paranoid - Maximum restrictions

**Rationale:**
Standard mode provides good protection without being overly restrictive. Users can upgrade to stricter modes via plugin configuration if needed.

## Implementation Plan

### File Changes

#### 1. istari-setup.md

**Section 7 - Claude Code Plugins** (after Compound Engineering, around line 617):

```bash
**Safety Net (Command Protection):**
```bash
echo "📦 Claude Code Safety Net Plugin:"
echo ""

# Check if safety-net is available
if [ -d ~/.claude/plugins/cache/cc-marketplace/safety-net ]; then
  echo "✅ Safety Net: installed"
else
  echo "❌ Safety Net: Not installed"
  echo ""
  echo "Installing Safety Net plugin (protects against destructive commands)..."
  read -p "Install Safety Net now? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running: claude plugin marketplace add kenryu42/cc-marketplace"
    claude plugin marketplace add kenryu42/cc-marketplace
    echo ""
    echo "Running: claude plugin install safety-net@cc-marketplace"
    claude plugin install safety-net@cc-marketplace
    echo ""
    echo "✅ Safety Net installed in standard mode!"
    echo "   Blocks: force pushes, branch deletions, hard resets, dangerous file operations"
  fi
fi
echo ""
```
```

**Section 9 - Summary Report** (around line 738):

```bash
# Add to "Claude Code Plugins:" section
echo "Claude Code Plugins:"
[ -d ~/.claude/plugins/cache/superpowers-marketplace/superpowers ] && echo "  ✅ Superpowers" || echo "  ❌ Superpowers"
[ -d ~/.claude/plugins/cache/every-marketplace/compound-engineering ] && echo "  ✅ Compound Engineering" || echo "  ❌ Compound Engineering"
[ -d ~/.claude/plugins/cache/cc-marketplace/safety-net ] && echo "  ✅ Safety Net" || echo "  ❌ Safety Net"

# Update TOTAL count (around line 754)
TOTAL=24  # Changed from 23

# Add installation check (around line 773)
[ -d ~/.claude/plugins/cache/cc-marketplace/safety-net ] && ((INSTALLED++))
```

**Success Criteria** (around line 1019):

```markdown
- ✅ Safety Net is installed in `~/.claude/plugins/cache/cc-marketplace/`
```

#### 2. README.md

**Toolchain Overview - AI Orchestration** (around line 68):

```markdown
### AI Orchestration
- **Copilot CLI** - Oracle for complex queries (defaults to grok-code-fast-1 for speed)
- **Superpowers** - Claude Code plugin for TDD guidance and code review
- **Compound Engineering** - Claude Code plugin for plan expansion
- **Safety Net** - Claude Code plugin preventing destructive git/filesystem commands
- **Context7** - MCP server providing up-to-date library documentation (requires API key)
- **Atlassian** - MCP server for Jira/Confluence integration (OAuth)
```

**Purpose Section** (around line 73):

```markdown
This toolchain enables **autonomous multi-agent execution** where multiple Claude instances can:
1. Work in parallel without conflicts (via agent_mail file reservations)
2. Make informed decisions (via Context7, Confluence, procedural memory)
3. Maintain quality (via TDD, bug scanning, multi-tool reviews)
4. **Operate safely (via Safety Net blocking destructive commands)**
5. Learn and improve (via daily learning files shared across agents)
6. Consult oracles when stuck (via Copilot CLI)
```

**Troubleshooting Section** (after line 375):

```markdown
**Safety Net blocking legitimate commands:**
- Review the command that was blocked in the error message
- If it's a false positive, you can customize rules via JSON config
- See https://github.com/kenryu42/claude-code-safety-net#configuration
- For one-time overrides, you can temporarily disable the plugin in Claude Code settings
```

### No Changes Required

**istari-plan.md** - No changes (safety-net is passive, doesn't affect planning)

**istari-work.md** - No changes (safety-net operates at Bash tool level automatically)

## Testing Plan

### Manual Verification

After implementation:

1. **Installation test:**
   ```bash
   /istari-setup
   # Verify Safety Net installation section appears
   # Confirm marketplace add and plugin install commands execute
   # Check ~/.claude/plugins/cache/cc-marketplace/safety-net exists
   ```

2. **Summary report test:**
   ```bash
   # At end of /istari-setup
   # Verify "✅ Safety Net" appears in Claude Code Plugins section
   # Verify tool count shows 24/24
   ```

3. **Protection test:**
   ```bash
   # In any Claude Code session, attempt dangerous command:
   # "Can you run: git push --force"
   # Expected: Safety Net blocks with explanation message
   ```

4. **Safe command test:**
   ```bash
   # Verify normal git operations still work:
   # "git status", "git add .", "git commit", "git push"
   # Expected: All execute normally
   ```

## Rollback Plan

If Safety Net causes issues:

1. **Temporary disable:**
   ```bash
   # In Claude Code: Settings > Extensions > Safety Net > Disable
   ```

2. **Permanent uninstall:**
   ```bash
   claude plugin uninstall safety-net@cc-marketplace
   ```

3. **Revert changes:**
   ```bash
   git revert <commit-hash>
   ```

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| False positives block legitimate commands | Medium | Medium | Document customization in README troubleshooting |
| Plugin marketplace unreachable | Low | Low | Installation prompts user, can skip and retry later |
| Conflicts with existing git workflows | Low | Medium | Standard mode is permissive, only blocks truly dangerous ops |
| Users unfamiliar with blocked commands | Medium | Low | Error messages explain why command was blocked |

## Success Criteria

Implementation is complete when:

- ✅ Safety Net installation added to istari-setup.md Section 7
- ✅ Summary report includes Safety Net status checks
- ✅ Tool count updated from 23 to 24
- ✅ README.md documents Safety Net in toolchain
- ✅ README.md includes troubleshooting for blocked commands
- ✅ Manual testing verifies: installation works, dangerous commands blocked, safe commands allowed
- ✅ Jira ticket created in AIML project

## Future Enhancements

Not in scope for initial integration, but possible future work:

1. **Custom rule configuration** - Add Istari-specific safety rules beyond defaults
2. **Logging integration** - Log blocked commands to `.claude/learnings/` for review
3. **Agent coordination** - Safety Net alerts via agent_mail when dangerous command attempted
4. **Mode switching** - Allow users to opt into Strict or Paranoid modes during setup

## References

- [claude-code-safety-net GitHub](https://github.com/kenryu42/claude-code-safety-net)
- [claude-code-safety-net Documentation](https://github.com/kenryu42/claude-code-safety-net#configuration)
- Istari README: `/Users/jacobmages-haskins/jacob-dev/istari/README.md`
- Istari Setup: `/Users/jacobmages-haskins/jacob-dev/istari/istari-setup.md`

## Jira Ticket Details

**Create manually in AIML project:**

**Title:** Integrate claude-code-safety-net plugin into Istari

**Description:**
```
# Overview

Integrate the claude-code-safety-net plugin into the Istari project to prevent destructive git and filesystem commands during autonomous AI coding sessions.

## Background

The claude-code-safety-net is a Claude Code plugin that blocks dangerous commands like:
- Force pushes (git push --force)
- Branch deletions
- Hard resets that discard changes
- Risky file deletion operations

Source: https://github.com/kenryu42/claude-code-safety-net

## Scope

### Files to Update:
1. istari-setup.md - Add Safety Net installation in Section 7 (Claude Code Plugins)
2. istari-setup.md - Update Section 9 (Summary Report) to include Safety Net checks
3. README.md - Add Safety Net to Toolchain Overview
4. README.md - Add troubleshooting guidance for Safety Net

### Configuration:
- Standard mode (default safety level)
- Global protection (active across all Claude Code sessions)

## Acceptance Criteria

- [ ] Safety Net installation added to istari-setup.md Section 7
- [ ] Summary report includes Safety Net status checks
- [ ] Tool count updated from 23 to 24
- [ ] README.md documents Safety Net in toolchain
- [ ] README.md includes troubleshooting for blocked commands
- [ ] Installation uses standard mode (no additional config)
- [ ] Verification shows Safety Net in plugin list
- [ ] Design document created in docs/plans/

## Design Document

See: docs/plans/2025-01-05-safety-net-integration-design.md
```

**Issue Type:** Task
**Priority:** Medium
**Labels:** istari, safety, plugin, automation
