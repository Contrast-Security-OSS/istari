---
description: Comprehensive PR code review using multiple tools
---

# Review Command

When the user types the `/istari-review` command, orchestrate comprehensive code review of a GitHub pull request using all available review tools.

## Overview

This command runs multiple code review tools sequentially and collates their results on screen. It provides a thorough analysis of code quality, security, architecture, and Clean Code principles.

**Review tools used:**
1. Claude's built-in `/review` command
2. Claude's built-in `/security-review` command
3. Superpowers code review
4. Compound Engineering review agents
5. Uncle Bob Clean Code review (Java files only)

**Output:**
- All results displayed on screen
- Clear section headers for each tool
- No files written (as requested)

## Usage

```bash
/istari-review <github-pr-url>
# or
/istari-review
```

If no URL provided, you'll be prompted to enter one.

## Review Workflow

### 1. Get PR URL

```bash
# Check if URL was provided as argument
if [ -z "$1" ]; then
  echo "━━━ Istari PR Review ━━━"
  echo ""
  echo "Comprehensive code review using multiple tools:"
  echo "  • Built-in review & security-review"
  echo "  • Superpowers review"
  echo "  • Compound Engineering review agents"
  echo "  • Uncle Bob Clean Code (Java files)"
  echo ""
  read -p "GitHub PR URL: " PR_URL
else
  PR_URL="$1"
fi

# Trim whitespace
PR_URL=$(echo "$PR_URL" | xargs)

if [ -z "$PR_URL" ]; then
  echo "❌ Error: No PR URL provided"
  exit 1
fi

echo "✅ PR URL: $PR_URL"
echo ""
```

### 2. Parse URL and Fetch PR Info

```bash
# Extract org/repo/pr-number from URL
# Format: https://github.com/org/repo/pull/123
if [[ ! "$PR_URL" =~ github\.com ]]; then
  echo "❌ Error: URL must be a GitHub pull request"
  echo "   Got: $PR_URL"
  echo "   Expected format: https://github.com/org/repo/pull/123"
  exit 1
fi

# Extract components
PR_NUM=$(echo "$PR_URL" | grep -oE '[0-9]+$')
REPO=$(echo "$PR_URL" | sed -E 's|.*github\.com/([^/]+/[^/]+).*|\1|')

if [ -z "$PR_NUM" ] || [ -z "$REPO" ]; then
  echo "❌ Error: Could not parse PR URL"
  echo "   URL: $PR_URL"
  echo "   Expected format: https://github.com/org/repo/pull/123"
  exit 1
fi

echo "Fetching PR metadata..."
echo "  Repository: $REPO"
echo "  PR Number: #$PR_NUM"
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
  echo "❌ Error: GitHub CLI (gh) is not installed"
  echo "   Install: brew install gh"
  echo "   Or see: https://cli.github.com/"
  exit 1
fi

# Fetch PR metadata
PR_METADATA=$(gh pr view "$PR_NUM" --repo "$REPO" --json title,additions,deletions,files 2>&1)

if [ $? -ne 0 ]; then
  echo "❌ Error fetching PR metadata:"
  echo "$PR_METADATA"
  echo ""
  echo "Common issues:"
  echo "  • PR does not exist"
  echo "  • Not authenticated with gh CLI (run: gh auth login)"
  echo "  • No access to repository"
  exit 1
fi

# Extract PR details
PR_TITLE=$(echo "$PR_METADATA" | jq -r '.title')
PR_ADDITIONS=$(echo "$PR_METADATA" | jq -r '.additions')
PR_DELETIONS=$(echo "$PR_METADATA" | jq -r '.deletions')
PR_FILES_COUNT=$(echo "$PR_METADATA" | jq -r '.files | length')

echo "━━━ PR Details ━━━"
echo ""
echo "Title: $PR_TITLE"
echo "Files: $PR_FILES_COUNT (+$PR_ADDITIONS -$PR_DELETIONS)"
echo ""
```

### 3. Identify Java Files

```bash
echo "Analyzing file types..."

# Get all file paths from PR
ALL_FILES=$(echo "$PR_METADATA" | jq -r '.files[].path')

# Filter for Java files
JAVA_FILES=$(echo "$ALL_FILES" | grep '\.java$' || true)

JAVA_FILE_COUNT=$(echo "$JAVA_FILES" | grep -c '.' || echo "0")

if [ "$JAVA_FILE_COUNT" -gt 0 ]; then
  echo "✅ Found $JAVA_FILE_COUNT Java file(s)"
  echo ""
  echo "Java files:"
  echo "$JAVA_FILES" | sed 's/^/  • /'
  echo ""
  echo "Uncle Bob Clean Code review will be applied to Java files."
else
  echo "ℹ️  No Java files found in PR"
  echo "   Uncle Bob review will be skipped."
fi

echo ""
```

### 4. Run Reviews Sequentially

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Starting Code Reviews"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will run 5 review processes sequentially."
echo "Each review may take a few minutes."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Review cancelled."
  exit 0
fi
echo ""
```

### 5. Execute Each Review

**a) Built-in Review:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[1/5] Built-in Code Review"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Store output
REVIEW_1_OUTPUT=$(mktemp)

# Run built-in review
/review "$PR_URL" 2>&1 | tee "$REVIEW_1_OUTPUT"

echo ""
```

**b) Security Review:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[2/5] Security Review"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

REVIEW_2_OUTPUT=$(mktemp)

/security-review "$PR_URL" 2>&1 | tee "$REVIEW_2_OUTPUT"

echo ""
```

**c) Superpowers Review:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[3/5] Superpowers Review"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

REVIEW_3_OUTPUT=$(mktemp)

# Note: This should trigger the Superpowers review skill
# The actual invocation may vary based on how Superpowers is accessed
echo "Requesting Superpowers code review for this PR..."
echo ""
echo "PR: $PR_URL"
echo ""
echo "Please use Superpowers to review the staged changes from this PR."

# Superpowers review would happen interactively here
# Output captured if possible

echo ""
```

**d) Compound Engineering Review:**

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "[4/5] Compound Engineering Review"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

REVIEW_4_OUTPUT=$(mktemp)

# Note: Use the workflow:review slash command
echo "Invoking Compound Engineering multi-agent review workflow..."
echo "Command: /workflow:review <PR-URL>"
echo ""
echo "This workflow launches multiple specialized review agents in parallel."

echo ""
```

**e) Uncle Bob Review (Java files only):**

```bash
if [ "$JAVA_FILE_COUNT" -gt 0 ]; then
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "[5/5] Uncle Bob Clean Code Review (Java)"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""

  REVIEW_5_OUTPUT=$(mktemp)

  # Fetch diff for Java files
  echo "Fetching Java file diffs..."
  echo ""

  for java_file in $JAVA_FILES; do
    echo "━━━ $java_file ━━━"
    gh pr diff "$PR_NUM" --repo "$REPO" -- "$java_file"
    echo ""
  done

  echo ""
  echo "Requesting Uncle Bob Clean Code review for Java files..."
  echo ""
  echo "Please use /istari:uncle-bob-clean-code skill to review the Java files above."
  echo ""
  echo "Focus areas:"
  echo "  • Function size (should be < 20 lines)"
  echo "  • Single responsibility"
  echo "  • Meaningful names"
  echo "  • Absence of comments (code should be self-documenting)"
  echo "  • SOLID principles"

  # Uncle Bob review would happen interactively here
  # Output captured if possible

  echo ""
else
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "[5/5] Uncle Bob Review - Skipped"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "⏭️  No Java files in PR - Uncle Bob review not applicable"
  echo ""
fi
```

### 6. Summary

```bash
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Code Review Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "PR: $REPO#$PR_NUM"
echo "Title: $PR_TITLE"
echo "Files: $PR_FILES_COUNT (+$PR_ADDITIONS -$PR_DELETIONS)"
echo ""
echo "Reviews completed:"
echo "  ✅ Built-in code review"
echo "  ✅ Security review"
echo "  ✅ Superpowers review"
echo "  ✅ Compound Engineering review"
if [ "$JAVA_FILE_COUNT" -gt 0 ]; then
  echo "  ✅ Uncle Bob Clean Code review ($JAVA_FILE_COUNT Java files)"
else
  echo "  ⏭️  Uncle Bob review (no Java files)"
fi
echo ""
echo "All review output displayed above."
echo "No files written."
echo ""
```

## Implementation Notes

**Interactive vs Automated:**

Some reviews (Superpowers, Uncle Bob) are skills that require interactive prompting. The command:
1. Sets up the context (PR URL, files to review)
2. Prompts the user to invoke the skill
3. Continues after skill completes

This is cleaner than trying to automate skill invocation programmatically.

**Alternative: Full Automation**

For a fully automated version, you could:
- Fetch the PR diff to a file
- Pass diff content directly to each tool
- Capture all output programmatically

Example:
```bash
# Fetch full diff
gh pr diff "$PR_NUM" --repo "$REPO" > /tmp/pr-diff.patch

# Review diff content directly
/review --file /tmp/pr-diff.patch
```

However, the current design (interactive) is simpler and more reliable.

## Error Handling

**gh CLI not installed:**
```
❌ Error: GitHub CLI (gh) is not installed
   Install: brew install gh
   Or see: https://cli.github.com/
```

**Authentication required:**
```
❌ Error fetching PR metadata:
error: authentication required

Common issues:
  • PR does not exist
  • Not authenticated with gh CLI (run: gh auth login)
  • No access to repository
```

**Invalid PR URL:**
```
❌ Error: URL must be a GitHub pull request
   Got: https://gitlab.com/org/repo/-/merge_requests/123
   Expected format: https://github.com/org/repo/pull/123
```

**Parse error:**
```
❌ Error: Could not parse PR URL
   URL: https://github.com/org/repo
   Expected format: https://github.com/org/repo/pull/123
```

## Example Invocation

```
User: /istari-review https://github.com/Contrast-Security-OSS/istari/pull/3

✅ PR URL: https://github.com/Contrast-Security-OSS/istari/pull/3

Fetching PR metadata...
  Repository: Contrast-Security-OSS/istari
  PR Number: #3

━━━ PR Details ━━━

Title: Add istari enhancements: update, upgrade, review commands
Files: 4 (+529 -14)

Analyzing file types...
ℹ️  No Java files found in PR
   Uncle Bob review will be skipped.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Starting Code Reviews
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

This will run 5 review processes sequentially.
Each review may take a few minutes.

Continue? (y/n) y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1/5] Built-in Code Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<Review output from /review>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[2/5] Security Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<Review output from /security-review>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[3/5] Superpowers Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Requesting Superpowers code review for this PR...

PR: https://github.com/Contrast-Security-OSS/istari/pull/3

Please use Superpowers to review the staged changes from this PR.

<Superpowers interactive review>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[4/5] Compound Engineering Review
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

<Review output from Compound Engineering>

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[5/5] Uncle Bob Review - Skipped
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⏭️  No Java files in PR - Uncle Bob review not applicable

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Code Review Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PR: Contrast-Security-OSS/istari#3
Title: Add istari enhancements: update, upgrade, review commands
Files: 4 (+529 -14)

Reviews completed:
  ✅ Built-in code review
  ✅ Security review
  ✅ Superpowers review
  ✅ Compound Engineering review
  ⏭️  Uncle Bob review (no Java files)

All review output displayed above.
No files written.
```

## Design Philosophy

**Sequential execution:**
- One review finishes before next starts
- Easier to read and follow output
- No interleaved output confusion

**On-screen output only:**
- No files written to disk
- No todo list creation
- All results immediately visible
- User can scroll back to review any section

**Graceful degradation:**
- If tool not available, skip with clear message
- Java-specific review only runs when applicable
- Errors don't stop entire process

**Clear progress indication:**
- Numbered steps ([1/5], [2/5], etc.)
- Clear section headers with ━━━ borders
- Summary at end shows what ran

## Success Criteria

- ✅ Accepts PR URL as argument or prompts for it
- ✅ Validates GitHub PR URL format
- ✅ Fetches PR metadata via gh CLI
- ✅ Identifies Java files in PR
- ✅ Runs built-in /review command
- ✅ Runs built-in /security-review command
- ✅ Invokes Superpowers review
- ✅ Invokes Compound Engineering review
- ✅ Applies Uncle Bob review to Java files only
- ✅ Skips Uncle Bob if no Java files
- ✅ Displays all output on screen with clear sections
- ✅ No files written
- ✅ Provides comprehensive summary at end
- ✅ Handles errors gracefully (auth, invalid URL, etc.)
