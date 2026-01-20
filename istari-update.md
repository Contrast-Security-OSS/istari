---
description: Sync istari commands from repo to target .claude directory
---

# Update Command

When the user types the `/istari-update` command, sync istari command files and skills from the istari repository to a target .claude directory.

## Overview

This command automates the process of updating istari commands and skills in your Claude environment. It copies all command files and skills from the istari repository to your specified .claude directory.

**What gets synced:**
- Command files (istari-plan, istari-work, istari-setup, istari-update, istari-upgrade, istari-review)
- Skills (uncle-bob-clean-code)

**Use cases:**
- After pulling updates to the istari repository
- Setting up istari in a new project
- Resetting istari commands to repo versions

## Update Workflow

### 1. Verify Running from Istari Repo

```bash
if [ ! -f "istari-setup.md" ]; then
  echo "❌ Error: Must run from istari repository"
  echo "   Current directory: $(pwd)"
  echo "   Expected files: istari-setup.md, istari-plan.md, etc."
  exit 1
fi

ISTARI_REPO=$(pwd)
echo "✅ Istari repo detected: $ISTARI_REPO"
echo ""
```

### 2. Prompt for Target Directory

```bash
echo "━━━ Istari Update ━━━"
echo ""
echo "This command will copy istari commands and skills to a .claude directory."
echo ""
echo "Where should istari commands be installed?"
echo "Example: ~/my-project/.claude"
echo "Example: ~/.claude (global)"
echo ""
read -p "Target directory: " TARGET

# Trim whitespace
TARGET=$(echo "$TARGET" | xargs)

# Expand ~ to home directory
TARGET="${TARGET/#\~/$HOME}"
```

### 3. Validate Target is .claude Directory

```bash
# Validate it's a .claude directory
if [[ ! "$TARGET" =~ \.claude(/|$) ]]; then
  echo ""
  echo "❌ Error: Target must be a .claude directory"
  echo "   Got: $TARGET"
  echo ""
  echo "Valid examples:"
  echo "  - /Users/username/project/.claude"
  echo "  - ~/.claude"
  echo "  - ./my-project/.claude"
  exit 1
fi

echo "✅ Target validated: $TARGET"
echo ""
```

### 4. Create Directory if Needed

```bash
if [ ! -d "$TARGET" ]; then
  echo "⚠️  Directory doesn't exist: $TARGET"
  read -p "Create $TARGET? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    mkdir -p "$TARGET"
    echo "✅ Created: $TARGET"
  else
    echo "Aborted."
    exit 1
  fi
fi
echo ""
```

### 5. Confirm Before Proceeding

```bash
echo "━━━ Sync Plan ━━━"
echo ""
echo "From: $ISTARI_REPO"
echo "To:   $TARGET"
echo ""
echo "Will copy:"
echo "  • 6 command files → $TARGET/commands/"
echo "  • 1 skill file    → $TARGET/skills/istari/"
echo ""
read -p "Proceed with sync? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi
echo ""
```

### 6. Copy Command Files

```bash
echo "━━━ Copying Command Files ━━━"
echo ""

# Create commands directory
mkdir -p "$TARGET/commands"

# Copy each command file
COMMANDS=(
  "istari-plan.md"
  "istari-work.md"
  "istari-setup.md"
  "istari-update.md"
  "istari-upgrade.md"
  "istari-review.md"
)

for cmd in "${COMMANDS[@]}"; do
  if [ -f "$ISTARI_REPO/$cmd" ]; then
    cp "$ISTARI_REPO/$cmd" "$TARGET/commands/"
    echo "✅ $cmd"
  else
    echo "⚠️  $cmd (not found, skipping)"
  fi
done

echo ""
```

### 7. Copy Skill Files

```bash
echo "━━━ Copying Skill Files ━━━"
echo ""

# Create skills directory
mkdir -p "$TARGET/skills/istari"

# Copy uncle-bob-clean-code skill
if [ -f "$ISTARI_REPO/uncle-bob-clean-code-skill.md" ]; then
  cp "$ISTARI_REPO/uncle-bob-clean-code-skill.md" "$TARGET/skills/istari/uncle-bob-clean-code.md"
  echo "✅ uncle-bob-clean-code.md"
else
  echo "⚠️  uncle-bob-clean-code-skill.md (not found, skipping)"
fi

echo ""
```

### 8. Verify Installation (Optional)

```bash
echo "━━━ Verifying Installation ━━━"
echo ""

# Check if target has istari-setup command
if [ -f "$TARGET/commands/istari-setup.md" ]; then
  echo "✅ Commands installed in: $TARGET/commands/"
  echo "   Files: $(ls -1 $TARGET/commands/istari-*.md | wc -l | xargs) istari command(s)"
else
  echo "⚠️  Commands directory may not be configured correctly"
fi

# Check if skill was installed
if [ -f "$TARGET/skills/istari/uncle-bob-clean-code.md" ]; then
  echo "✅ Skills installed in: $TARGET/skills/istari/"
  echo "   Files: uncle-bob-clean-code.md"
else
  echo "⚠️  Skills directory may not be configured correctly"
fi

echo ""
```

### 9. Suggest Running Setup

```bash
echo "━━━ Next Steps ━━━"
echo ""
echo "Commands and skills have been synced to: $TARGET"
echo ""
echo "Recommended next steps:"
echo "  1. Run /istari-setup to verify tool installation"
echo "  2. Test commands are accessible in Claude Code"
echo ""

# If target is current project, suggest running setup
if [[ "$TARGET" == *"$(pwd)"* ]] || [[ "$(pwd)" == *"$TARGET"* ]]; then
  read -p "Run /istari-setup now? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Running istari-setup..."
    /istari-setup
  fi
fi
```

### 10. Summary Report

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Istari Update Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Synced from: $ISTARI_REPO"
echo "Synced to:   $TARGET"
echo ""
echo "Commands:    $TARGET/commands/"
echo "Skills:      $TARGET/skills/istari/"
echo ""
```

## Error Handling

**Not running from istari repo:**
```
❌ Error: Must run from istari repository
   Current directory: /some/other/path
   Expected files: istari-setup.md, istari-plan.md, etc.
```

**Invalid target path:**
```
❌ Error: Target must be a .claude directory
   Got: /Users/username/project/commands

Valid examples:
  - /Users/username/project/.claude
  - ~/.claude
  - ./my-project/.claude
```

**Target directory creation failed:**
```
⚠️  Directory doesn't exist: /path/to/.claude
Create /path/to/.claude? (y/n) n
Aborted.
```

**Source files missing:**
```
⚠️  istari-upgrade.md (not found, skipping)
```

This allows partial sync if some commands haven't been created yet.

## Example Invocation

```
User: /istari-update

━━━ Istari Update ━━━

This command will copy istari commands and skills to a .claude directory.

Where should istari commands be installed?
Example: ~/my-project/.claude
Example: ~/.claude (global)

Target directory: ~/my-app/.claude
✅ Target validated: /Users/username/my-app/.claude

⚠️  Directory doesn't exist: /Users/username/my-app/.claude
Create /Users/username/my-app/.claude? (y/n) y
✅ Created: /Users/username/my-app/.claude

━━━ Sync Plan ━━━

From: /Users/username/jacob-dev/istari
To:   /Users/username/my-app/.claude

Will copy:
  • 6 command files → /Users/username/my-app/.claude/commands/
  • 1 skill file    → /Users/username/my-app/.claude/skills/istari/

Proceed with sync? (y/n) y

━━━ Copying Command Files ━━━

✅ istari-plan.md
✅ istari-work.md
✅ istari-setup.md
✅ istari-update.md
✅ istari-upgrade.md
✅ istari-review.md

━━━ Copying Skill Files ━━━

✅ uncle-bob-clean-code.md

━━━ Verifying Installation ━━━

✅ Commands installed in: /Users/username/my-app/.claude/commands/
   Files: 6 istari command(s)
✅ Skills installed in: /Users/username/my-app/.claude/skills/istari/
   Files: uncle-bob-clean-code.md

━━━ Next Steps ━━━

Commands and skills have been synced to: /Users/username/my-app/.claude

Recommended next steps:
  1. Run /istari-setup to verify tool installation
  2. Test commands are accessible in Claude Code

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Istari Update Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Synced from: /Users/username/jacob-dev/istari
Synced to:   /Users/username/my-app/.claude

Commands:    /Users/username/my-app/.claude/commands/
Skills:      /Users/username/my-app/.claude/skills/istari/
```

## Design Philosophy

**Safety first:**
- Validates target directory structure
- Confirms before copying
- Never modifies source files
- Allows partial sync if some files missing

**Clear feedback:**
- Shows source and destination paths
- Reports what will be copied
- Indicates success/skip/warning for each file
- Provides next steps

**Idempotent:**
- Safe to run multiple times
- Overwrites existing files with repo versions
- Repo is always source of truth

## Success Criteria

- ✅ Validates running from istari repository
- ✅ Prompts for and validates .claude target directory
- ✅ Creates target directory if needed
- ✅ Confirms sync plan before proceeding
- ✅ Copies all command files to target/commands/
- ✅ Copies skill files to target/skills/istari/
- ✅ Verifies installation succeeded
- ✅ Provides clear next steps
- ✅ Handles missing source files gracefully
- ✅ Works for both project-specific and global .claude directories
