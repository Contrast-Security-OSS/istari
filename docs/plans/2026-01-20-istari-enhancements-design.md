# Istari Enhancements Design

**Date:** 2026-01-20
**Status:** Approved
**Author:** Jacob Mages-Haskins & Claude

## Overview

This design adds four new capabilities to the istari project:

1. **uncle-bob-clean-code skill** - Java-focused Clean Code review skill
2. **istari-update** - Sync istari commands from repo to target environment
3. **istari-upgrade** - Smart tool version updates with semantic versioning
4. **istari-review** - Comprehensive PR review orchestration

## Motivation

**Problem 1:** Compound Engineering review tools cover Python and Ruby but lack Java-specific code quality review following Clean Code principles.

**Solution:** Add uncle-bob-clean-code skill as an istari-managed skill, filling the Java review gap.

---

**Problem 2:** When istari commands are updated in the repo, users must manually sync them to their working projects.

**Solution:** istari-update command automates the sync from istari repo to target .claude directories.

---

**Problem 3:** The istari tool ecosystem (beads, ubs, cass, etc.) updates frequently. Manually tracking and upgrading 15+ tools is tedious and error-prone.

**Solution:** istari-upgrade intelligently detects updates, categorizes by risk (patch/minor/major), and automates safe upgrades.

---

**Problem 4:** Thorough PR review requires running 5+ different tools sequentially, manually collating results.

**Solution:** istari-review orchestrates all review tools, runs them in sequence, and presents unified results.

## Design

### 1. Project Structure

```
istari/
├── istari-plan.md                      (existing)
├── istari-setup.md                     (existing - updated)
├── istari-work.md                      (existing)
├── uncle-bob-clean-code-skill.md       (NEW - source file)
├── istari-update.md                    (NEW - command)
├── istari-upgrade.md                   (NEW - command)
├── istari-review.md                    (NEW - command)
└── .claude/
    └── learnings/
```

**Installation target structure:**
```
<project>/.claude/
├── commands/
│   ├── istari-plan.md
│   ├── istari-setup.md
│   ├── istari-work.md
│   ├── istari-update.md
│   ├── istari-upgrade.md
│   └── istari-review.md
└── skills/
    └── istari/
        └── uncle-bob-clean-code.md
```

### 2. uncle-bob-clean-code Skill Integration

**Source file:** `uncle-bob-clean-code-skill.md` in istari repo root

**Content:** Copy of existing `~/jacob-dev/.claude/skills/SKILL.md` (Java-focused Clean Code review persona)

**Installation:**
- `istari-setup` copies to `~/.claude/skills/istari/uncle-bob-clean-code.md`
- Uses flat-file-in-namespace pattern: `skills/istari/<skill-name>.md`

**Updates to istari-setup.md:**
```bash
# Add to skill installation section:
echo "Installing uncle-bob-clean-code skill..."
mkdir -p ~/.claude/skills/istari
cp "$ISTARI_REPO/uncle-bob-clean-code-skill.md" \
   ~/.claude/skills/istari/uncle-bob-clean-code.md
echo "✅ uncle-bob-clean-code skill installed"
```

### 3. istari-update Command

**Purpose:** Sync istari command files from repo to target .claude directory

**Usage:**
```bash
/istari-update
```

**Workflow:**

1. **Verify running from istari repo:**
   ```bash
   if [ ! -f "istari-setup.md" ]; then
     echo "❌ Error: Must run from istari repository"
     exit 1
   fi
   ISTARI_REPO=$(pwd)
   ```

2. **Prompt for target .claude directory:**
   ```bash
   echo "Where should istari commands be installed?"
   echo "Example: ~/my-project/.claude"
   read -p "Target directory: " TARGET

   # Validate it's a .claude directory
   if [[ ! "$TARGET" =~ \.claude(/|$) ]]; then
     echo "❌ Error: Target must be a .claude directory"
     echo "   Got: $TARGET"
     exit 1
   fi
   ```

3. **Create directory if needed:**
   ```bash
   if [ ! -d "$TARGET" ]; then
     read -p "Create $TARGET? (y/n) " -n 1 -r
     echo
     if [[ $REPLY =~ ^[Yy]$ ]]; then
       mkdir -p "$TARGET"
     else
       exit 1
     fi
   fi
   ```

4. **Confirm before proceeding:**
   ```bash
   echo "Will copy istari commands to: $TARGET"
   echo "  - commands/ (6 files)"
   echo "  - skills/istari/ (1 file)"
   read -p "Proceed? (y/n) " -n 1 -r
   echo
   if [[ ! $REPLY =~ ^[Yy]$ ]]; then
     exit 0
   fi
   ```

5. **Copy command files:**
   ```bash
   mkdir -p "$TARGET/commands"
   cp "$ISTARI_REPO/istari-plan.md" "$TARGET/commands/"
   cp "$ISTARI_REPO/istari-work.md" "$TARGET/commands/"
   cp "$ISTARI_REPO/istari-setup.md" "$TARGET/commands/"
   cp "$ISTARI_REPO/istari-update.md" "$TARGET/commands/"
   cp "$ISTARI_REPO/istari-upgrade.md" "$TARGET/commands/"
   cp "$ISTARI_REPO/istari-review.md" "$TARGET/commands/"
   echo "✅ Copied 6 command files"
   ```

6. **Copy skill files:**
   ```bash
   mkdir -p "$TARGET/skills/istari"
   cp "$ISTARI_REPO/uncle-bob-clean-code-skill.md" \
      "$TARGET/skills/istari/uncle-bob-clean-code.md"
   echo "✅ Copied uncle-bob-clean-code skill"
   ```

7. **Re-run setup verification:**
   ```bash
   echo ""
   echo "Running istari-setup to verify tools..."
   /istari-setup
   ```

8. **Report success:**
   ```
   ✅ Updated istari commands in: $TARGET/.claude/
   ✅ Updated uncle-bob-clean-code skill
   ✅ Setup verification complete

   Changes synced from: $ISTARI_REPO
   ```

### 4. istari-upgrade Command

**Purpose:** Smart tool version management with semantic versioning

**Usage:**
```bash
/istari-upgrade          # Check and upgrade with prompts
/istari-upgrade --check  # Check only, don't upgrade
```

**No manifest file** - uses semantic versioning intelligence instead of maintaining version pins.

**Workflow:**

1. **Detect installed versions:**
   ```bash
   # For each tool category:

   # Cargo tools
   cargo install --list | grep -E "(beads|abacus|ubs|cass|casc|mcp-agent-mail|dcg)"

   # Bun/npm global packages
   bun pm ls --global | grep -E "(beads|beads-viewer)"

   # System utilities
   rg --version
   fzf --version
   lazygit --version
   ast-grep --version
   jq --version

   # Claude plugins (via claude CLI)
   claude plugin list

   # MCP servers (via claude CLI)
   claude mcp list
   ```

2. **Query latest versions:**
   ```bash
   # Cargo (crates.io API)
   curl -s "https://crates.io/api/v1/crates/beads" | jq -r '.crate.max_version'

   # npm registry
   npm view @contrast/beads version

   # GitHub releases API for others
   gh api repos/BurntSushi/ripgrep/releases/latest --jq '.tag_name'

   # Plugins/MCP: assume "latest" always
   ```

3. **Categorize by semantic version delta:**
   ```bash
   # Parse versions: MAJOR.MINOR.PATCH
   # Compare installed vs latest:

   # Patch: 0.3.5 → 0.3.8 (bug fixes, safe)
   # Minor: 0.3.5 → 0.4.0 (new features, review)
   # Major: 0.3.5 → 1.0.0 (breaking changes, caution)
   ```

4. **Present categorized updates:**
   ```
   Found 12 updates:

   📦 Patch updates (safe - bug fixes only):
     • beads: 0.3.5 → 0.3.8
     • fzf: 0.46.0 → 0.46.1
     • ripgrep: 14.1.0 → 14.1.1
     • ubs: 0.4.2 → 0.4.5

   ⚠️  Minor updates (new features - review recommended):
     • beads_viewer: 0.2.8 → 0.3.0 (adds new visualization)
     • cass: 0.5.0 → 0.6.0 (new memory indexing)

   🚨 Major updates (breaking changes - caution):
     • ast-grep: 0.15.0 → 1.0.0 (API changes, review docs)

   Apply all 4 patch updates? (y/n)
   ```

5. **Apply patch updates if approved:**
   ```bash
   # User says 'y'
   cargo install beads --force
   cargo install ultimate-bug-scanner --force
   brew upgrade fzf
   brew upgrade ripgrep
   echo "✅ Applied 4 patch updates"
   ```

6. **Prompt individually for minor/major:**
   ```bash
   # For each minor update:
   echo "⚠️  beads_viewer: 0.2.8 → 0.3.0"
   echo "   Changes: Adds new visualization features"
   read -p "Apply? (y/n) " -n 1 -r

   # For each major update:
   echo "🚨 ast-grep: 0.15.0 → 1.0.0"
   echo "   WARNING: Breaking changes"
   echo "   Review: https://github.com/ast-grep/ast-grep/releases/v1.0.0"
   read -p "Apply? (y/n) " -n 1 -r
   ```

7. **Summary:**
   ```
   ━━━ Upgrade Complete ━━━

   ✅ Applied: 4 patch, 1 minor
   ⏭️  Skipped: 1 major

   Current versions saved to: .claude/istari-versions.lock
   ```

**Optional: Lock file** (post-upgrade snapshot, not a source of truth):
```yaml
# .claude/istari-versions.lock
# Auto-generated by istari-upgrade on 2026-01-20
# This is a snapshot, not a constraint

upgraded_at: "2026-01-20T15:30:00Z"
tools:
  beads: "0.3.8"
  beads_viewer: "0.3.0"
  # ...
```

### 5. istari-review Command

**Purpose:** Orchestrate comprehensive PR review using all available tools

**Usage:**
```bash
/istari-review <github-pr-url>
# or
/istari-review
> PR URL: <user pastes>
```

**Workflow:**

1. **Get PR URL:**
   ```bash
   if [ -z "$1" ]; then
     read -p "PR URL: " PR_URL
   else
     PR_URL="$1"
   fi
   ```

2. **Parse URL and fetch PR info:**
   ```bash
   # Extract org/repo/pr-number from URL
   # https://github.com/org/repo/pull/123

   PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')
   REPO=$(echo "$PR_URL" | grep -oE 'github.com/[^/]+/[^/]+' | sed 's/github.com\///')

   # Fetch PR metadata
   gh pr view "$PR_NUM" --repo "$REPO" --json files,additions,deletions,title

   # Get diff
   gh pr diff "$PR_NUM" --repo "$REPO" > /tmp/pr-$PR_NUM.diff
   ```

3. **Identify Java files:**
   ```bash
   JAVA_FILES=$(gh pr view "$PR_NUM" --repo "$REPO" --json files \
     --jq '.files[].path' | grep '\.java$')

   if [ -z "$JAVA_FILES" ]; then
     echo "ℹ️  No Java files in PR (uncle-bob review will be skipped)"
   else
     echo "📋 Java files to review:"
     echo "$JAVA_FILES"
   fi
   ```

4. **Run reviews sequentially with progress:**
   ```
   ━━━ Running Code Reviews ━━━
   PR: <title>
   Files: <count> (+<adds> -<dels>)

   [1/5] Built-in review...
   ```

5. **Execute each review:**

   **a) Built-in review:**
   ```bash
   /review "$PR_URL"
   ```

   **b) Security review:**
   ```bash
   [2/5] Security review...
   /security-review "$PR_URL"
   ```

   **c) Superpowers review:**
   ```bash
   [3/5] Superpowers review...
   /superpowers:requesting-code-review
   ```

   **d) Compound Engineering review:**
   ```bash
   [4/5] Compound Engineering review...
   /compound-engineering:workflows:review
   ```

   **e) Uncle Bob review (Java only):**
   ```bash
   [5/5] Uncle Bob Clean Code review (Java)...

   if [ -n "$JAVA_FILES" ]; then
     /istari:uncle-bob-clean-code
     # Then: "Review these Java files from the PR:"
     # Show each Java file's diff
     # Uncle Bob analyzes each one
   else
     echo "⏭️  Skipped (no Java files)"
   fi
   ```

6. **Collate results on screen:**
   ```
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Code Review Results
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   PR: <org/repo>#<num> - <title>
   Files: <count> (+<adds> -<dels>)

   ━━━ Built-in Review ━━━
   <full output from /review>

   ━━━ Security Review ━━━
   <full output from /security-review>

   ━━━ Superpowers Review ━━━
   <full output from Superpowers>

   ━━━ Compound Engineering Review ━━━
   <full output from /workflow:review>

   ━━━ Uncle Bob Clean Code (Java) ━━━
   <full output from uncle-bob skill>
   <per-file Java analysis>

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   Review Complete
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   All review output displayed above.
   No files written (as requested).
   ```

**Important:** No todo files, no markdown reports - everything on screen only.

## Implementation Tasks

### Task 1: Add uncle-bob-clean-code-skill.md
- Copy existing skill from `~/jacob-dev/.claude/skills/SKILL.md`
- Rename to `uncle-bob-clean-code-skill.md`
- Place in istari repo root
- Commit to version control

### Task 2: Update istari-setup.md
- Add skill installation section
- Copy to `~/.claude/skills/istari/uncle-bob-clean-code.md`
- Verify installation in setup checklist
- Test installation on clean environment

### Task 3: Create istari-update.md
- Implement prompt for target .claude directory
- Validate target is .claude path
- Copy all command files to target/commands/
- Copy skill file to target/skills/istari/
- Re-run istari-setup for verification
- Test on multiple target directories

### Task 4: Create istari-upgrade.md
- Implement version detection for all tool types
- Query package registries for latest versions
- Implement semantic version parsing and comparison
- Categorize updates: patch/minor/major
- Interactive prompts per category
- Apply upgrades with appropriate package managers
- Optional: Generate lock file snapshot

### Task 5: Create istari-review.md
- Accept PR URL as arg or prompt
- Parse GitHub PR URL
- Fetch PR metadata via gh CLI
- Identify Java files in PR
- Run 5 review tools sequentially with progress
- Collate all output to screen
- Format with clear section headers
- Test with real PR

### Task 6: Integration Testing
- Test full workflow: setup → update → upgrade → review
- Verify skill installation and invocation
- Test upgrade with different version scenarios
- Test review with PR containing Java files
- Test review with PR without Java files

## Success Criteria

- ✅ uncle-bob-clean-code skill available in istari-managed projects
- ✅ istari-setup installs skill to correct namespace
- ✅ istari-update syncs commands and skills to any .claude directory
- ✅ istari-upgrade detects updates, categorizes by risk, prompts appropriately
- ✅ istari-upgrade applies patch updates in batch, minor/major individually
- ✅ istari-review runs all 5 review tools on a PR
- ✅ istari-review applies uncle-bob to Java files only
- ✅ istari-review displays all results on screen (no files written)
- ✅ All commands have clear error messages and confirmations
- ✅ Commands work on both macOS and Linux

## Non-Goals

- **Version manifest maintenance** - Too much overhead with fast-moving projects
- **Automated PR commenting** - Keep human in the loop
- **Parallel review execution** - Sequential is simpler and more readable
- **Cross-repository skill syncing** - Users manage their own .claude directories

## Future Enhancements

- **istari-doctor** - Health check for all tools, detect issues
- **istari-reset** - Clean uninstall and reinstall all tools
- **Custom review profiles** - Users define which tools to run
- **Review result filtering** - Hide noise, show only critical findings
