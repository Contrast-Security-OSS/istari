---
description: Smart tool version management with semantic versioning
---

# Upgrade Command

When the user types the `/istari-upgrade` command, intelligently detect and upgrade istari-managed tools using semantic versioning logic.

## Overview

This command scans all istari-managed tools, compares installed versions against latest available versions, and categorizes updates by risk level (patch/minor/major). It then prompts for upgrades with appropriate safety considerations.

**First-time installation:** If you haven't installed the prerequisites yet, run `./install-prerequisites.sh` from the istari repository root to set up all required tools. Then use this command for future upgrades.

**No manifest file** - Uses semantic versioning intelligence rather than maintaining a central version registry.

**Tools managed:**
- Language runtimes (bun, rust, go, uv)
- CLI utilities (ripgrep, fzf, lazygit, ast-grep, jq)
- AI coding tools (beads, abacus, beads_viewer, ubs, cass, casc, mcp-agent-mail, dcg)
- Oracles (copilot)
- Claude plugins (Superpowers, Compound Engineering)
- MCP servers (Context7, Atlassian)

## Usage

```bash
/istari-upgrade           # Check and upgrade with prompts
/istari-upgrade --check   # Check only, don't upgrade
```

## Semantic Version Categories

**Patch updates (X.Y.Z → X.Y.Z+n):**
- Bug fixes only
- Backward compatible
- Safe to apply automatically
- Example: 0.3.5 → 0.3.8

**Minor updates (X.Y.Z → X.Y+n.0):**
- New features added
- Backward compatible
- Review recommended
- Example: 0.3.5 → 0.4.0

**Major updates (X.Y.Z → X+n.0.0):**
- Breaking changes
- May require code changes
- Review documentation
- Proceed with caution
- Example: 0.3.5 → 1.0.0

## Upgrade Workflow

### 1. Parse Command Arguments

```bash
CHECK_ONLY=false

if [ "$1" = "--check" ]; then
  CHECK_ONLY=true
fi

echo "━━━ Istari Upgrade ━━━"
echo ""

if [ "$CHECK_ONLY" = true ]; then
  echo "Mode: Check only (no upgrades)"
else
  echo "Mode: Interactive upgrade"
fi
echo ""
```

### 2. Detect Installed Versions

```bash
echo "━━━ Detecting Installed Versions ━━━"
echo ""

# Arrays to store tool info
declare -A INSTALLED_VERSIONS
declare -A LATEST_VERSIONS
declare -A TOOL_SOURCES  # cargo, npm, brew, etc.

# Cargo tools
echo "Checking Cargo tools..."
if command -v cargo &> /dev/null; then
  CARGO_LIST=$(cargo install --list 2>/dev/null || echo "")

  # Parse cargo install --list output
  # Format: tool_name v0.1.0:
  while IFS= read -r line; do
    if [[ "$line" =~ ^([a-z0-9_-]+)\ v([0-9]+\.[0-9]+\.[0-9]+): ]]; then
      tool="${BASH_REMATCH[1]}"
      version="${BASH_REMATCH[2]}"

      # Filter for istari-managed tools
      case "$tool" in
        beads|abacus|ultimate-bug-scanner|cass|casc|mcp-agent-mail|destructive-command-guard)
          INSTALLED_VERSIONS["$tool"]="$version"
          TOOL_SOURCES["$tool"]="cargo"
          echo "  • $tool: $version"
          ;;
      esac
    fi
  done <<< "$CARGO_LIST"
else
  echo "  ⚠️  Cargo not available"
fi
echo ""

# Bun/npm global tools
echo "Checking Bun/npm tools..."
if command -v bun &> /dev/null; then
  # Check for @contrast/beads
  if bun pm ls --global 2>/dev/null | grep -q '@contrast/beads'; then
    beads_version=$(bun pm ls --global 2>/dev/null | grep '@contrast/beads' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    if [ "$beads_version" != "unknown" ]; then
      INSTALLED_VERSIONS["@contrast/beads"]="$beads_version"
      TOOL_SOURCES["@contrast/beads"]="bun"
      echo "  • @contrast/beads: $beads_version"
    fi
  fi

  # Check for @contrast/beads-viewer
  if bun pm ls --global 2>/dev/null | grep -q '@contrast/beads-viewer'; then
    bv_version=$(bun pm ls --global 2>/dev/null | grep '@contrast/beads-viewer' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
    if [ "$bv_version" != "unknown" ]; then
      INSTALLED_VERSIONS["@contrast/beads-viewer"]="$bv_version"
      TOOL_SOURCES["@contrast/beads-viewer"]="bun"
      echo "  • @contrast/beads-viewer: $bv_version"
    fi
  fi
else
  echo "  ⚠️  Bun not available"
fi
echo ""

# CLI Utilities (system-installed)
echo "Checking CLI utilities..."
for tool in rg fzf lazygit jq; do
  if command -v "$tool" &> /dev/null; then
    case "$tool" in
      rg)
        version=$(rg --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        display_name="ripgrep"
        ;;
      fzf)
        version=$(fzf --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "unknown")
        display_name="fzf"
        ;;
      lazygit)
        version=$(lazygit --version 2>/dev/null | grep -oE 'version=[0-9]+\.[0-9]+\.[0-9]+' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
        display_name="lazygit"
        ;;
      jq)
        version=$(jq --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' || echo "unknown")
        display_name="jq"
        ;;
    esac

    if [ "$version" != "unknown" ]; then
      INSTALLED_VERSIONS["$display_name"]="$version"
      TOOL_SOURCES["$display_name"]="brew"  # Assume brew on macOS
      echo "  • $display_name: $version"
    fi
  fi
done
echo ""

# ast-grep
if command -v sg &> /dev/null; then
  ast_grep_version=$(sg --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
  if [ "$ast_grep_version" != "unknown" ]; then
    INSTALLED_VERSIONS["ast-grep"]="$ast_grep_version"
    TOOL_SOURCES["ast-grep"]="brew"
    echo "  • ast-grep: $ast_grep_version"
  fi
fi
echo ""
```

### 3. Query Latest Versions

```bash
echo "━━━ Querying Latest Versions ━━━"
echo ""

# Query crates.io for Cargo tools
echo "Querying crates.io..."
for tool in beads abacus ultimate-bug-scanner cass casc mcp-agent-mail destructive-command-guard; do
  if [ -n "${INSTALLED_VERSIONS[$tool]}" ]; then
    # Use crates.io API
    crate_name="$tool"
    if [ "$tool" = "ultimate-bug-scanner" ]; then
      crate_name="ultimate_bug_scanner"
    elif [ "$tool" = "destructive-command-guard" ]; then
      crate_name="destructive_command_guard"
    elif [ "$tool" = "mcp-agent-mail" ]; then
      crate_name="mcp_agent_mail"
    fi

    latest=$(curl -s "https://crates.io/api/v1/crates/$crate_name" 2>/dev/null | jq -r '.crate.max_version' 2>/dev/null || echo "unknown")
    if [ "$latest" != "unknown" ] && [ "$latest" != "null" ]; then
      LATEST_VERSIONS["$tool"]="$latest"
      echo "  • $tool: $latest"
    fi
  fi
done
echo ""

# Query npm for Bun tools
echo "Querying npm registry..."
for tool in "@contrast/beads" "@contrast/beads-viewer"; do
  if [ -n "${INSTALLED_VERSIONS[$tool]}" ]; then
    package_name=$(echo "$tool" | sed 's/@/%40/g')  # URL encode @
    latest=$(curl -s "https://registry.npmjs.org/$tool/latest" 2>/dev/null | jq -r '.version' 2>/dev/null || echo "unknown")
    if [ "$latest" != "unknown" ] && [ "$latest" != "null" ]; then
      LATEST_VERSIONS["$tool"]="$latest"
      echo "  • $tool: $latest"
    fi
  fi
done
echo ""

# For system tools (brew), use GitHub releases or skip
echo "System tools (brew):"
echo "  ℹ️  CLI utilities update via: brew upgrade <tool>"
echo "  ℹ️  Run manually or use this command to check versions"
echo ""

echo "Claude plugins and MCP servers:"
echo "  ℹ️  Plugins/MCP servers update via Claude marketplace"
echo "  ℹ️  Recommended: keep at 'latest' version"
echo ""
```

### 4. Categorize Updates by Semantic Version

```bash
echo "━━━ Analyzing Updates ━━━"
echo ""

# Parse version: MAJOR.MINOR.PATCH
parse_version() {
  local version="$1"
  echo "$version" | awk -F'.' '{print $1, $2, $3}'
}

# Compare versions and categorize
compare_versions() {
  local installed="$1"
  local latest="$2"

  read installed_major installed_minor installed_patch <<< $(parse_version "$installed")
  read latest_major latest_minor latest_patch <<< $(parse_version "$latest")

  if [ "$latest_major" -gt "$installed_major" ]; then
    echo "major"
  elif [ "$latest_major" -eq "$installed_major" ] && [ "$latest_minor" -gt "$installed_minor" ]; then
    echo "minor"
  elif [ "$latest_major" -eq "$installed_major" ] && [ "$latest_minor" -eq "$installed_minor" ] && [ "$latest_patch" -gt "$installed_patch" ]; then
    echo "patch"
  else
    echo "none"
  fi
}

# Categorize all tools
declare -a PATCH_UPDATES
declare -a MINOR_UPDATES
declare -a MAJOR_UPDATES

for tool in "${!INSTALLED_VERSIONS[@]}"; do
  installed="${INSTALLED_VERSIONS[$tool]}"
  latest="${LATEST_VERSIONS[$tool]}"

  if [ -n "$latest" ] && [ "$latest" != "unknown" ]; then
    category=$(compare_versions "$installed" "$latest")

    case "$category" in
      patch)
        PATCH_UPDATES+=("$tool:$installed:$latest")
        ;;
      minor)
        MINOR_UPDATES+=("$tool:$installed:$latest")
        ;;
      major)
        MAJOR_UPDATES+=("$tool:$installed:$latest")
        ;;
    esac
  fi
done

# Count updates
PATCH_COUNT=${#PATCH_UPDATES[@]}
MINOR_COUNT=${#MINOR_UPDATES[@]}
MAJOR_COUNT=${#MAJOR_UPDATES[@]}
TOTAL_COUNT=$((PATCH_COUNT + MINOR_COUNT + MAJOR_COUNT))

if [ "$TOTAL_COUNT" -eq 0 ]; then
  echo "✅ All tools are up to date!"
  echo ""
  exit 0
fi

echo "Found $TOTAL_COUNT update(s):"
echo ""
```

### 5. Present Categorized Updates

```bash
# Patch updates
if [ "$PATCH_COUNT" -gt 0 ]; then
  echo "📦 Patch updates (safe - bug fixes only):"
  for update in "${PATCH_UPDATES[@]}"; do
    IFS=':' read -r tool installed latest <<< "$update"
    echo "  • $tool: $installed → $latest"
  done
  echo ""
fi

# Minor updates
if [ "$MINOR_COUNT" -gt 0 ]; then
  echo "⚠️  Minor updates (new features - review recommended):"
  for update in "${MINOR_UPDATES[@]}"; do
    IFS=':' read -r tool installed latest <<< "$update"
    echo "  • $tool: $installed → $latest"
  done
  echo ""
fi

# Major updates
if [ "$MAJOR_COUNT" -gt 0 ]; then
  echo "🚨 Major updates (breaking changes - caution):"
  for update in "${MAJOR_UPDATES[@]}"; do
    IFS=':' read -r tool installed latest <<< "$update"
    echo "  • $tool: $installed → $latest"
  done
  echo ""
fi
```

### 6. Apply Updates (If Not Check-Only)

```bash
if [ "$CHECK_ONLY" = true ]; then
  echo "Check complete. No upgrades applied (--check mode)."
  echo ""
  echo "To apply upgrades, run: /istari-upgrade"
  exit 0
fi

echo "━━━ Applying Updates ━━━"
echo ""

# Apply patch updates (batch with confirmation)
if [ "$PATCH_COUNT" -gt 0 ]; then
  echo "📦 Patch Updates"
  echo ""
  read -p "Apply all $PATCH_COUNT patch update(s)? (y/n) " -n 1 -r
  echo ""

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    for update in "${PATCH_UPDATES[@]}"; do
      IFS=':' read -r tool installed latest <<< "$update"
      source="${TOOL_SOURCES[$tool]}"

      echo "Upgrading $tool: $installed → $latest..."

      case "$source" in
        cargo)
          cargo install "$tool" --force
          ;;
        bun)
          bun install -g "$tool"
          ;;
        brew)
          brew upgrade "$tool" 2>/dev/null || echo "  ℹ️  Manual upgrade may be required"
          ;;
      esac

      echo "✅ $tool upgraded"
      echo ""
    done
  else
    echo "Skipped patch updates."
    echo ""
  fi
fi

# Apply minor updates (individual confirmation)
if [ "$MINOR_COUNT" -gt 0 ]; then
  echo "⚠️  Minor Updates"
  echo ""

  for update in "${MINOR_UPDATES[@]}"; do
    IFS=':' read -r tool installed latest <<< "$update"
    source="${TOOL_SOURCES[$tool]}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$tool: $installed → $latest"
    echo "Changes: New features added"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    read -p "Apply this update? (y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo ""
      echo "Upgrading $tool..."

      case "$source" in
        cargo)
          cargo install "$tool" --force
          ;;
        bun)
          bun install -g "$tool"
          ;;
        brew)
          brew upgrade "$tool" 2>/dev/null || echo "  ℹ️  Manual upgrade may be required"
          ;;
      esac

      echo "✅ $tool upgraded"
    else
      echo "⏭️  Skipped $tool"
    fi
    echo ""
  done
fi

# Apply major updates (individual confirmation with warnings)
if [ "$MAJOR_COUNT" -gt 0 ]; then
  echo "🚨 Major Updates"
  echo ""

  for update in "${MAJOR_UPDATES[@]}"; do
    IFS=':' read -r tool installed latest <<< "$update"
    source="${TOOL_SOURCES[$tool]}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$tool: $installed → $latest"
    echo "⚠️  WARNING: Breaking changes"
    echo "Review: Check changelog/release notes"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    read -p "Apply this major update? (y/n) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo ""
      echo "Upgrading $tool..."

      case "$source" in
        cargo)
          cargo install "$tool" --force
          ;;
        bun)
          bun install -g "$tool"
          ;;
        brew)
          brew upgrade "$tool" 2>/dev/null || echo "  ℹ️  Manual upgrade may be required"
          ;;
      esac

      echo "✅ $tool upgraded"
    else
      echo "⏭️  Skipped $tool"
    fi
    echo ""
  done
fi
```

### 7. Summary

```bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Upgrade Complete"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Summary:"
echo "  • Patch updates: $PATCH_COUNT"
echo "  • Minor updates: $MINOR_COUNT"
echo "  • Major updates: $MAJOR_COUNT"
echo ""
echo "Run /istari-setup to verify all tools."
echo ""
```

## Error Handling

**No updates available:**
```
✅ All tools are up to date!
```

**Network error querying registries:**
```
⚠️  Could not fetch latest version for <tool>
   Network error or API unavailable
```

**Upgrade fails:**
```
❌ Failed to upgrade <tool>
   Error: <error-message>
   Try manually: cargo install <tool> --force
```

**Tool not managed by istari:**
```
ℹ️  <tool> not managed by istari-upgrade
   Install/upgrade manually
```

## Example Invocation

```
User: /istari-upgrade

━━━ Istari Upgrade ━━━

Mode: Interactive upgrade

━━━ Detecting Installed Versions ━━━

Checking Cargo tools...
  • beads: 0.3.5
  • ultimate-bug-scanner: 0.4.2
  • cass: 0.5.0

Checking Bun/npm tools...
  • @contrast/beads: 0.3.5
  • @contrast/beads-viewer: 0.2.8

Checking CLI utilities...
  • ripgrep: 14.1.0
  • fzf: 0.46.0
  • lazygit: 0.40.2

━━━ Querying Latest Versions ━━━

Querying crates.io...
  • beads: 0.3.8
  • ultimate-bug-scanner: 0.4.5
  • cass: 0.6.0

Querying npm registry...
  • @contrast/beads: 0.3.8
  • @contrast/beads-viewer: 0.3.0

System tools (brew):
  ℹ️  CLI utilities update via: brew upgrade <tool>

━━━ Analyzing Updates ━━━

Found 5 update(s):

📦 Patch updates (safe - bug fixes only):
  • beads: 0.3.5 → 0.3.8
  • @contrast/beads: 0.3.5 → 0.3.8
  • ultimate-bug-scanner: 0.4.2 → 0.4.5

⚠️  Minor updates (new features - review recommended):
  • @contrast/beads-viewer: 0.2.8 → 0.3.0
  • cass: 0.5.0 → 0.6.0

━━━ Applying Updates ━━━

📦 Patch Updates

Apply all 3 patch update(s)? (y/n) y

Upgrading beads: 0.3.5 → 0.3.8...
✅ beads upgraded

Upgrading @contrast/beads: 0.3.5 → 0.3.8...
✅ @contrast/beads upgraded

Upgrading ultimate-bug-scanner: 0.4.2 → 0.4.5...
✅ ultimate-bug-scanner upgraded

⚠️  Minor Updates

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
@contrast/beads-viewer: 0.2.8 → 0.3.0
Changes: New features added
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Apply this update? (y/n) y

Upgrading @contrast/beads-viewer...
✅ @contrast/beads-viewer upgraded

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
cass: 0.5.0 → 0.6.0
Changes: New features added
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Apply this update? (y/n) n
⏭️  Skipped cass

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Upgrade Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Summary:
  • Patch updates: 3
  • Minor updates: 2
  • Major updates: 0

Run /istari-setup to verify all tools.
```

## Design Philosophy

**Semantic versioning intelligence:**
- No manifest to maintain
- Categorizes by risk level automatically
- Patch updates are batched (safe)
- Minor/major require individual approval

**Safety first:**
- Always confirm before upgrading
- Major updates require explicit consent
- Clear warnings for breaking changes
- Provides context for each update

**Graceful degradation:**
- Works even if some tools can't be queried
- Handles network errors
- Skips tools not installed
- Provides manual upgrade instructions when needed

**Clear feedback:**
- Shows installed vs latest versions
- Groups by update category
- Progress indicators during upgrades
- Summary report at end

## Success Criteria

- ✅ Detects installed versions for cargo tools
- ✅ Detects installed versions for bun/npm tools
- ✅ Detects installed versions for CLI utilities
- ✅ Queries crates.io for latest cargo versions
- ✅ Queries npm registry for latest npm versions
- ✅ Parses semantic versions correctly
- ✅ Categorizes updates: patch/minor/major
- ✅ Prompts for batch patch updates
- ✅ Prompts individually for minor updates
- ✅ Prompts individually for major updates with warnings
- ✅ Applies upgrades via appropriate package manager
- ✅ Handles --check mode (no upgrades)
- ✅ Provides summary of what was upgraded
- ✅ Handles errors gracefully
- ✅ Works without version manifest file

## Future Enhancements

- Support for lock file generation (snapshot of current versions)
- Dry-run mode showing upgrade commands without executing
- Rollback capability if upgrade causes issues
- Integration with changelog/release notes display
- Support for downgrading tools
