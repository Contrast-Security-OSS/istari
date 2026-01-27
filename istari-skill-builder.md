---
description: Analyze work patterns from learnings, plans, and memory to suggest new Claude skills
---

# istari-skill-builder

## Overview

Discovers repeated workflows across three data sources and generates personalized skill suggestions:
- `.claude/learnings/` - Execution reality (what actually happened)
- `docs/plans/` - Design intent (what was planned)
- `cass_memory_system` - Historical knowledge (what we know works)

**Output:** Personalized skills installed to `~/.claude/skills/` (local machine only)

**Philosophy:** Automate patterns you repeat. Your workflows become reusable skills.

## Prerequisites

- `cass_memory_system` installed (`cm` command available)
- `.claude/learnings/` directory with learning logs (optional)
- `docs/plans/` directory with design documents (optional)

At least one data source is required.

## Workflow

### 1. Data Collection

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "istari Skill Builder - Phase 1"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Analyzing work patterns from:"
echo "  • Learning logs (.claude/learnings/)"
echo "  • Design documents (docs/plans/)"
echo "  • Long-term memory (cass)"
echo ""

# Check for data sources
LEARNINGS_DIR=".claude/learnings"
PLANS_DIR="docs/plans"

# Count learnings (last 30 days)
if [ -d "$LEARNINGS_DIR" ]; then
  LEARNING_FILES=$(find "$LEARNINGS_DIR" -name "*.md" -mtime -30 2>/dev/null | wc -l | xargs)
  echo "✅ Learnings: $LEARNING_FILES documents (last 30 days)"
else
  LEARNING_FILES=0
  echo "⚠️  Learnings: No .claude/learnings/ directory found"
fi

# Count plans (last 90 days)
if [ -d "$PLANS_DIR" ]; then
  PLAN_FILES=$(find "$PLANS_DIR" -name "*.md" -mtime -90 2>/dev/null | wc -l | xargs)
  echo "✅ Plans: $PLAN_FILES documents (last 90 days)"
else
  PLAN_FILES=0
  echo "⚠️  Plans: No docs/plans/ directory found"
fi

# Check cass memory
if command -v cm &> /dev/null; then
  echo "✅ Memory: cass_memory_system available"
  HAS_MEMORY=true
else
  echo "⚠️  Memory: cass_memory_system not installed"
  HAS_MEMORY=false
fi

echo ""

# Verify we have at least one data source
TOTAL_SOURCES=$((LEARNING_FILES + PLAN_FILES))
if [ $TOTAL_SOURCES -eq 0 ] && [ "$HAS_MEMORY" = false ]; then
  echo "❌ Error: No data sources available"
  echo ""
  echo "   To use istari-skill-builder, you need at least one of:"
  echo "     • .claude/learnings/*.md files"
  echo "     • docs/plans/*.md files"
  echo "     • cass_memory_system installed"
  echo ""
  exit 1
fi

echo "Proceeding with analysis..."
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Analysis cancelled."
  exit 0
fi
echo ""
```

### 2. Pattern Extraction

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Extracting Patterns"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create temporary analysis file
ANALYSIS_FILE=$(mktemp)
trap "rm -f $ANALYSIS_FILE" EXIT

echo "## Pattern Analysis Input" > "$ANALYSIS_FILE"
echo "" >> "$ANALYSIS_FILE"

# Add learnings content
if [ $LEARNING_FILES -gt 0 ]; then
  echo "### Recent Learnings (Last 30 Days)" >> "$ANALYSIS_FILE"
  echo "" >> "$ANALYSIS_FILE"

  # Concatenate recent learnings
  find "$LEARNINGS_DIR" -name "*.md" -mtime -30 2>/dev/null | while read -r file; do
    echo "#### $(basename "$file")" >> "$ANALYSIS_FILE"
    echo "" >> "$ANALYSIS_FILE"
    cat "$file" >> "$ANALYSIS_FILE"
    echo "" >> "$ANALYSIS_FILE"
    echo "---" >> "$ANALYSIS_FILE"
    echo "" >> "$ANALYSIS_FILE"
  done
fi

# Add plans content
if [ $PLAN_FILES -gt 0 ]; then
  echo "### Design Documents (Last 90 Days)" >> "$ANALYSIS_FILE"
  echo "" >> "$ANALYSIS_FILE"

  # Concatenate recent plans
  find "$PLANS_DIR" -name "*.md" -mtime -90 2>/dev/null | while read -r file; do
    echo "#### $(basename "$file")" >> "$ANALYSIS_FILE"
    echo "" >> "$ANALYSIS_FILE"
    cat "$file" >> "$ANALYSIS_FILE"
    echo "" >> "$ANALYSIS_FILE"
    echo "---" >> "$ANALYSIS_FILE"
    echo "" >> "$ANALYSIS_FILE"
  done
fi

# Add memory context
if [ "$HAS_MEMORY" = true ]; then
  echo "### Long-Term Memory Context" >> "$ANALYSIS_FILE"
  echo "" >> "$ANALYSIS_FILE"
  echo "Querying: workflows, patterns, repeated tasks" >> "$ANALYSIS_FILE"
  echo "" >> "$ANALYSIS_FILE"

  # Query relevant memories
  cm recall "workflows patterns repeated common" --limit 20 >> "$ANALYSIS_FILE" 2>/dev/null || true
  echo "" >> "$ANALYSIS_FILE"
fi

echo "✅ Collected data from all sources"
echo ""
echo "Analyzing patterns with AI..."
echo ""
```

### 3. AI-Powered Pattern Detection

```bash
# Use Task tool to analyze patterns and suggest skill candidates
echo "Launching pattern analysis..."
echo ""
echo "This will:"
echo "  1. Identify repeated activities (3+ occurrences)"
echo "  2. Find multi-step workflows (3+ steps)"
echo "  3. Score patterns by frequency and automation value"
echo "  4. Present top skill candidates for your review"
echo ""
```

**AI Analysis Task:**

Analyze the collected data and identify skill candidates:

**Instructions for Claude:**
1. Read the analysis file containing learnings, plans, and memory
2. Identify repeated patterns (activities appearing 3+ times)
3. Look for multi-step processes (3+ steps)
4. Score each pattern (1-10) based on:
   - Frequency across sources
   - Complexity (number of steps)
   - Automation potential
   - Proven success (from learnings)
5. Present top 5 candidates with:
   - Pattern name
   - Score and rationale
   - What it automates
   - Source references

**Output format for each candidate:**
```
## Skill Candidate: [name]
Score: [X/10]
Frequency: [X times]
Pattern: [brief description]
What it automates:
- [Step 1]
- [Step 2]
- [Step 3+]

Sources:
- Learnings: [specific files/sections]
- Plans: [specific files/sections]
- Memory: [relevant memories]
```

### 4. Candidate Review & Selection

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Review Skill Candidates"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Review the candidates above."
echo ""
echo "For each candidate, you'll be asked:"
echo "  1. Generate this skill? (y/n) - EARLY REJECTION"
echo "  2. After generation: Approve/Edit/Reject - LATE REJECTION"
echo ""
read -p "Ready to review candidates? (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Skill builder cancelled."
  exit 0
fi
echo ""
```

**For each skill candidate identified by AI:**

```bash
# Create temp directory for generated skills
GENERATED_SKILLS_DIR=$(mktemp -d)
trap "rm -rf $GENERATED_SKILLS_DIR $ANALYSIS_FILE" EXIT

SKILLS_TO_GENERATE=()

# Present each candidate and ask for early approval
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Candidate: [skill-name]"
echo "Score: [X/10]"
echo "Pattern: [description]"
echo "Frequency: [X times]"
echo ""
echo "Would automate:"
echo "  • [Step 1]"
echo "  • [Step 2]"
echo "  • [Step 3]"
echo ""
read -p "Generate full skill for this candidate? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
  SKILLS_TO_GENERATE+=("[skill-name]")
  echo "✅ Will generate: [skill-name]"
else
  echo "⏭️  Skipped: [skill-name]"
fi
echo ""

# Repeat for all candidates...
```

### 5. Skill Generation

```bash
if [ ${#SKILLS_TO_GENERATE[@]} -eq 0 ]; then
  echo "No skills selected for generation."
  echo ""
  exit 0
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Generating Skills"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Generating ${#SKILLS_TO_GENERATE[@]} skill(s)..."
echo ""
```

**AI Skill Generation Task:**

For each approved candidate, generate a complete skill markdown file:

**Instructions for Claude:**
1. Create complete skill with YAML frontmatter
2. Include sections:
   - Objective
   - Intake (what to ask user)
   - Routing/workflow
   - Examples from actual learnings/plans
3. Base examples on real data from analysis
4. Write to: `$GENERATED_SKILLS_DIR/[skill-name].md`

**Example skill structure:**
```markdown
---
name: skill-name
description: One line description
---

## Objective
[What this skill does]

## Intake
[Questions to ask the user]

## Workflow
[Step-by-step process with specific commands/actions]

## Examples
[Real examples from your learnings/plans]

## Success Criteria
[How to know the task completed successfully]
```

### 6. Interactive Review & Editing

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 5: Review & Edit Generated Skills"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SKILLS_APPROVED=0
SKILLS_REJECTED=0

# Review each generated skill
for skill_file in "$GENERATED_SKILLS_DIR"/*.md; do
  [ ! -f "$skill_file" ] && continue

  SKILL_NAME=$(basename "$skill_file" .md)

  while true; do
    clear
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Reviewing: $SKILL_NAME"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Show the generated skill
    cat "$skill_file"

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Options:"
    echo "  [a] Approve and install"
    echo "  [e] Request edits"
    echo "  [r] Reject - don't create this skill"
    echo ""
    read -p "Choice (a/e/r): " -n 1 -r CHOICE
    echo ""
    echo ""

    case $CHOICE in
      [Aa])
        # Approve - install skill
        echo "Installing $SKILL_NAME..."
        mkdir -p "$HOME/.claude/skills"
        cp "$skill_file" "$HOME/.claude/skills/$SKILL_NAME.md"
        echo "✅ Installed: ~/.claude/skills/$SKILL_NAME.md"
        echo ""
        ((SKILLS_APPROVED++))
        read -p "Press Enter to continue..."
        break
        ;;
      [Ee])
        # Request edits
        echo "What changes would you like?"
        echo "(Describe edits, then press Enter on empty line to finish)"
        echo ""

        # Read multi-line edit request
        EDIT_REQUEST=""
        while IFS= read -r line; do
          [ -z "$line" ] && break
          EDIT_REQUEST+="$line"$'\n'
        done

        if [ -z "$EDIT_REQUEST" ]; then
          echo "No edits requested."
          continue
        fi

        echo ""
        echo "Applying edits to $SKILL_NAME..."
        echo ""

        # AI applies edits to skill file
        # This will be handled by Claude reading the current skill,
        # applying the requested changes, and writing back to the file

        echo "✅ Edits applied. Showing updated skill..."
        echo ""
        read -p "Press Enter to review updated skill..."
        # Loop continues - shows updated skill
        ;;
      [Rr])
        # Reject
        echo "❌ Rejected: $SKILL_NAME (will not be installed)"
        echo ""
        ((SKILLS_REJECTED++))
        read -p "Press Enter to continue..."
        break
        ;;
      *)
        echo "Invalid choice. Use a, e, or r"
        read -p "Press Enter to try again..."
        ;;
    esac
  done
done
```

### 7. Summary

```bash
clear
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Skill Builder Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Analysis Summary:"
echo "  • Learnings analyzed: $LEARNING_FILES documents"
echo "  • Plans analyzed: $PLAN_FILES documents"
if [ "$HAS_MEMORY" = true ]; then
  echo "  • Memory queried: cass_memory_system"
fi
echo ""
echo "Generation Summary:"
echo "  • Candidates identified: [AI count]"
echo "  • Skills generated: ${#SKILLS_TO_GENERATE[@]}"
echo "  • Skills approved: $SKILLS_APPROVED"
echo "  • Skills rejected: $SKILLS_REJECTED"
echo ""

if [ $SKILLS_APPROVED -gt 0 ]; then
  echo "✅ Installed Skills:"
  ls -1 "$HOME/.claude/skills/" | grep -v istari || true
  echo ""
  echo "To use your new skills:"
  echo "  /[skill-name]"
  echo ""
fi

echo "Next Steps:"
echo "  • Test your new skills in real workflows"
echo "  • Run skill-builder monthly to discover new patterns"
echo "  • Refine skills based on usage"
echo ""
```

## Usage Example

```bash
$ /istari-skill-builder

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
istari Skill Builder - Phase 1
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Analyzing work patterns from:
  • Learning logs (.claude/learnings/)
  • Design documents (docs/plans/)
  • Long-term memory (cass)

✅ Learnings: 12 documents (last 30 days)
✅ Plans: 3 documents (last 90 days)
✅ Memory: cass_memory_system available

Proceeding with analysis...

Continue? (y/n) y

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step 2: Extracting Patterns
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ Collected data from all sources

Analyzing patterns with AI...

[AI analyzes and presents candidates...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step 3: Review Skill Candidates
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Skill Candidate: config-deployer
Score: 9/10
Frequency: 5 times
Pattern: Safe configuration file deployment

Would automate:
  • Validate target directory
  • Copy files atomically
  • Verify integrity
  • Report results

Generate full skill for this candidate? (y/n) y
✅ Will generate: config-deployer

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## Skill Candidate: test-workflow
Score: 8/10
Frequency: 7 times
Pattern: Command testing methodology

Would automate:
  • Setup clean environment
  • Execute test scenarios
  • Verify results
  • Document findings

Generate full skill for this candidate? (y/n) n
⏭️  Skipped: test-workflow

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step 4: Generating Skills
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Generating 1 skill(s)...

[AI generates config-deployer.md]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step 5: Review & Edit Generated Skills
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Reviewing: config-deployer
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---
name: config-deployer
description: Deploy configuration files safely with validation
---

## Objective
Systematically deploy config files with validation and rollback.

[... full skill content ...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Options:
  [a] Approve and install
  [e] Request edits
  [r] Reject - don't create this skill

Choice (a/e/r): e

What changes would you like?
(Describe edits, then press Enter on empty line to finish)

Add a backup option before deployment

Applying edits to config-deployer...

✅ Edits applied. Showing updated skill...

[Shows updated skill with backup option added]

Options:
  [a] Approve and install
  [e] Request edits
  [r] Reject - don't create this skill

Choice (a/e/r): a

Installing config-deployer...
✅ Installed: ~/.claude/skills/config-deployer.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Skill Builder Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Generation Summary:
  • Candidates identified: 5
  • Skills generated: 1
  • Skills approved: 1
  • Skills rejected: 0

✅ Installed Skills:
config-deployer.md

To use your new skills:
  /config-deployer
```

## Two-Stage Rejection Flow

**Stage 1: Early Rejection (Pre-Generation)**
- After AI identifies patterns
- Before spending time generating full skill
- Quick decision: "Is this worth pursuing?"
- **Saves time** if pattern isn't interesting

**Stage 2: Late Rejection (Post-Generation)**
- After seeing complete skill definition
- After optionally editing it
- Final decision: "Is this skill actually useful?"
- **Quality gate** before installation

## Design Philosophy

**Automated Generation:**
- AI creates complete, ready-to-use skills
- Based on your real workflows
- Includes examples from your data

**Human-in-the-Loop:**
- You control what gets generated (early rejection)
- You review before installation (late rejection)
- You can request edits iteratively
- You approve final version

**Iterative Editing:**
- Request changes in natural language
- AI applies edits and shows updated version
- Continue editing until satisfied
- Or reject if skill doesn't meet needs

## Success Criteria

- ✅ Patterns detected from multiple data sources
- ✅ AI generates complete skill markdown files
- ✅ Early rejection available (pre-generation)
- ✅ Iterative editing supported
- ✅ Late rejection available (post-review)
- ✅ Skills installed to ~/.claude/skills/
- ✅ Skills ready to invoke immediately
- ❌ NO documentation updates (local skills only)
- ❌ NO istari repository modifications

## Error Handling

**No data sources:**
```
❌ Error: No data sources available

   To use istari-skill-builder, you need at least one of:
     • .claude/learnings/*.md files
     • docs/plans/*.md files
     • cass_memory_system installed
```

**No patterns found:**
```
⚠️  No repeated patterns detected

   Skill builder needs:
     • 3+ occurrences of similar activities
     • Multi-step workflows (3+ steps)

   Run again after more work sessions.
```

**Skills directory creation fails:**
```
❌ Failed to create ~/.claude/skills/
   Check file permissions
```

## Notes

**Phase 1 Features:**
- Pattern detection from learnings/plans/memory
- AI-generated complete skill files
- Two-stage rejection (early + late)
- Iterative editing with human review
- Local installation only

**Future Enhancements (Phase 2+):**
- ML-based pattern clustering
- Automated scoring/ranking improvements
- Cross-project pattern detection
- Continuous monitoring mode
- Team skill sharing capabilities
