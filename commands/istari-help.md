---
description: Display help information for all istari commands
---

# Help Command

When the user types the `/istari-help` command, display comprehensive information about all available istari commands.

## Overview

Provides a quick reference guide to all istari commands with descriptions and usage examples.

## Help Display

```bash
cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          istari - AI Orchestration Toolkit
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

istari is a comprehensive toolkit for AI-powered software development,
combining multiple tools into coordinated workflows.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                    COMMANDS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/istari-setup
  Install and verify all prerequisites for istari.
  Checks: beads, mcp-agent-mail, ultimate_bug_scanner,
  Superpowers, Compound Engineering, Context7, cass,
  copilot CLI, and utility tools.

  Usage: /istari-setup
  Run this first before using other istari commands.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/istari-plan [JIRA-ID | description]
  Decompose Jira tickets into structured, dependency-aware beads.
  Uses Superpowers and Compound Engineering for planning.
  Creates feature branch and optimized work order.

  Usage: /istari-plan PROJ-123
         /istari-plan "Add two-factor authentication"

  Creates: Beads, feature branch, robot-plan analysis

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/istari-work
  Autonomous software development agent that executes beads.
  Follows TDD, runs comprehensive reviews, coordinates with
  other agents via mcp-agent-mail, creates PRs when complete.

  Usage: /istari-work

  Workflow: Select bead → Reserve files → Implement with TDD
            → Review (4 tools) → Commit → Document learnings
            → Repeat until ticket complete → Create PR

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/istari-update [target-directory]
  Sync istari commands and skills from repo to .claude directory.
  Keeps your installation up-to-date with latest versions.

  Usage: /istari-update
         /istari-update ~/my-project/.claude

  Copies: 8 command files, 1 skill file

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/istari-upgrade
  Smart version management with semantic versioning.
  Detects installed versions, queries registries, compares
  versions, categorizes as patch/minor/major, interactive
  upgrade prompts.

  Usage: /istari-upgrade

  Supports: cargo, npm, brew, Claude plugins

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/istari-review <github-pr-url>
  Comprehensive code review using multiple tools.
  Runs: built-in review, security-review, Superpowers,
  Compound Engineering, Uncle Bob (Java files only).

  Usage: /istari-review https://github.com/org/repo/pull/123

  Output: All results displayed on screen (no files written)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/istari-skill-builder
  Analyze work patterns and generate personalized Claude skills.
  Mines: .claude/learnings/, docs/plans/, cass_memory_system
  Detects repeated workflows (3+ occurrences).
  AI-generated skills with human review and editing.

  Usage: /istari-skill-builder

  Output: Skills installed to ~/.claude/skills/ (local only)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/istari-help
  Display this help information.

  Usage: /istari-help

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                  TYPICAL WORKFLOW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Initial Setup
   /istari-setup              # Install prerequisites (once)

2. Planning Phase
   /istari-plan PROJ-456      # Create beads from Jira ticket

3. Execution Phase
   /istari-work               # Autonomous development

4. Review Phase
   /istari-review <PR-URL>    # Comprehensive PR review

5. Maintenance
   /istari-upgrade            # Update tool versions
   /istari-skill-builder      # Generate new skills from patterns

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                 GETTING STARTED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

New to istari? Follow this sequence:

1. Run /istari-setup to verify prerequisites
2. Try /istari-plan with a simple Jira ticket
3. Execute beads with /istari-work
4. Review a PR with /istari-review
5. Run /istari-help anytime for reference

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

For more information about istari:
  Repository: https://github.com/Contrast-Security-OSS/istari
  Issues: https://github.com/Contrast-Security-OSS/istari/issues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
```

## Design Philosophy

**Quick Reference:**
- All commands visible in one screen
- Brief, scannable descriptions
- Usage examples for clarity
- Typical workflow guide for new users

**No Installation Required:**
- Pure information display
- No external dependencies
- Always available

**Self-Documenting:**
- Includes itself in the list
- Shows typical usage patterns
- Guides new users through common sequences

## Success Criteria

- ✅ Lists all istari commands
- ✅ Provides brief descriptions for each
- ✅ Shows usage examples
- ✅ Includes typical workflow guide
- ✅ Easy to scan and read
- ✅ No external dependencies
