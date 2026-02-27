---
description: Interactive setup verification for istari-plan and istari-work prerequisites
---

# Setup Command

When the user types the `/istari-setup` command, verify all required tools and plugins are installed and properly configured.

## Quick Start: Automated Installation

**For first-time setup, run the automated installer:**

```bash
# From the istari repository root
./install-prerequisites.sh
```

This script automatically installs and configures all required tools for istari. It handles:
- Language runtimes (bun, rust, go, uv)
- CLI utilities (ripgrep, fzf, lazygit, ast-grep, jq)
- Git infrastructure (git, gh)
- AI coding tools (beads_rust, abacus, beads_viewer, ultimate_bug_scanner, cass_memory_system, mcp_agent_mail)
- Command protection (destructive_command_guard)
- Oracle CLIs (copilot)
- PATH configuration
- Claude Code and Copilot configuration

After running the installer, use this `/istari-setup` command to verify everything is configured correctly.

---

## Migrating from bd (Original Beads)

**If you have an existing beads (bd) installation:**

The istari system uses `beads_rust` (command: `br`), which is the Rust rewrite of the original Python `beads` (command: `bd`). To migrate your existing issues:

```bash
# Import existing bd issues into br
br sync --import-only
```

This command:
- Reads your existing `.beads/issues.jsonl` file
- Imports all issues into the new `br` database
- Preserves issue IDs, status, dependencies, and metadata
- Does NOT modify your original data

After import, you can use `br` commands alongside or instead of `bd`. Both tools share the same `.beads/` directory structure.

**Learn more:** [beads_rust migration guide](https://github.com/Dicklesworthstone/beads_rust?tab=readme-ov-file#q-how-do-i-migrate-from-the-original-beads)

---

## Overview

This command performs a comprehensive health check of your AI coding environment, ensuring all prerequisites for `/istari-plan` and `/istari-work` are satisfied.

**Tools Verified and Installed:**
- Language runtimes (bun, rust, go, uv)
- CLI utilities (ripgrep, fzf, lazygit, ast-grep, jq)
- Git infrastructure (git, gh)
- AI coding tools (beads_rust, abacus, beads_viewer, ultimate_bug_scanner, cass_memory_system, coding_agent_session_search)
- Agent coordination (mcp_agent_mail)
- Command protection (destructive_command_guard) - **Blocks destructive git, filesystem, database operations**
- Oracles (copilot) - **Configured with maxTokens: 8192**
- Claude Code configuration - **maxTokens: 200000 for extended context**
- Claude Code plugins (Superpowers, Compound Engineering) - **Interactive installation**
- Claude Code skills (uncle-bob-clean-code) - **Java-focused Clean Code review**
- MCP servers (Sequential Thinking, Context7, Atlassian) - **Interactive installation with API key setup**

## Setup Verification Workflow

**OS Detection & Package Manager Check:**
```bash
# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  IS_MACOS=true
  echo "📍 Detected: macOS"
else
  IS_MACOS=false
  echo "📍 Detected: Linux"
fi

# Check for Homebrew on macOS
if [ "$IS_MACOS" = true ]; then
  if command -v brew &> /dev/null; then
    echo "✅ Homebrew: $(brew --version | head -1)"
    HAS_BREW=true
  else
    echo "⚠️  Homebrew: Not installed (recommended for macOS)"
    echo "Install: /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    read -p "Install Homebrew now? (y/n) " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      HAS_BREW=true
    else
      HAS_BREW=false
    fi
  fi
fi
echo ""
```

### 1. Language Runtimes

Check core language toolchains required for installing other tools:

**Bun (JavaScript/TypeScript runtime):**
```bash
if command -v bun &> /dev/null; then
  echo "✅ bun: $(bun --version)"
else
  echo "❌ bun: Not installed"
  if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
    echo "Install: brew install bun"
  else
    echo "Install: curl -fsSL https://bun.sh/install | bash"
  fi
  read -p "Install bun now? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
      brew install bun
    else
      curl -fsSL https://bun.sh/install | bash
      source ~/.bashrc  # or ~/.zshrc
    fi
  fi
fi
```

**Rust + Cargo:**
```bash
if command -v cargo &> /dev/null; then
  echo "✅ rust: $(rustc --version)"
  echo "✅ cargo: $(cargo --version)"
else
  echo "❌ rust/cargo: Not installed"
  echo "Install: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
  read -p "Install rust now? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source $HOME/.cargo/env
  fi
fi
```

**Go:**
```bash
if command -v go &> /dev/null; then
  echo "✅ go: $(go version)"
else
  echo "❌ go: Not installed"
  if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
    echo "Install: brew install go"
  else
    echo "Install: Download from https://go.dev/dl/"
  fi
  read -p "Install go now? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
      brew install go
    else
      echo "Download and install from https://go.dev/dl/"
      open https://go.dev/dl/
    fi
  fi
fi
```

**uv (Python package manager):**
```bash
if command -v uv &> /dev/null; then
  echo "✅ uv: $(uv --version)"
else
  echo "❌ uv: Not installed"
  if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
    echo "Install: brew install uv"
  else
    echo "Install: curl -LsSf https://astral.sh/uv/install.sh | sh"
  fi
  read -p "Install uv now? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
      brew install uv
    else
      curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
  fi
fi
```

### 2. CLI Utilities

**ripgrep (Fast grep):**
```bash
if command -v rg &> /dev/null; then
  echo "✅ ripgrep: $(rg --version | head -1)"
else
  echo "❌ ripgrep: Not installed"
  if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
    echo "Install: brew install ripgrep"
  else
    echo "Install: cargo install ripgrep"
  fi
  read -p "Install ripgrep? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
      brew install ripgrep
    else
      cargo install ripgrep
    fi
  fi
fi
```

**fzf (Fuzzy finder):**
```bash
if command -v fzf &> /dev/null; then
  echo "✅ fzf: $(fzf --version)"
else
  echo "❌ fzf: Not installed"
  if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
    echo "Install: brew install fzf"
  else
    echo "Install: git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install"
  fi
  read -p "Install fzf? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
      brew install fzf
    else
      git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
      ~/.fzf/install
    fi
  fi
fi
```

**lazygit (Git TUI):**
```bash
if command -v lazygit &> /dev/null; then
  echo "✅ lazygit: $(lazygit --version | head -1)"
else
  echo "❌ lazygit: Not installed"
  if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
    echo "Install: brew install lazygit"
  else
    echo "Install: go install github.com/jesseduffield/lazygit@latest"
  fi
  read -p "Install lazygit? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
      brew install lazygit
    else
      go install github.com/jesseduffield/lazygit@latest
    fi
  fi
fi
```

**ast-grep (Structural search):**
```bash
if command -v sg &> /dev/null; then
  echo "✅ ast-grep: $(sg --version)"
else
  echo "❌ ast-grep: Not installed"
  if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
    echo "Install: brew install ast-grep"
  else
    echo "Install: cargo install ast-grep"
  fi
  read -p "Install ast-grep? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
      brew install ast-grep
    else
      cargo install ast-grep
    fi
  fi
fi
```

**jq (JSON processor):**
```bash
if command -v jq &> /dev/null; then
  echo "✅ jq: $(jq --version)"
else
  echo "❌ jq: Not installed"
  echo "   (Required for Claude Code and Copilot config)"
  if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
    echo "Install: brew install jq"
  else
    echo "Install: apt install jq (Debian/Ubuntu) or yum install jq (RedHat/CentOS)"
  fi
  read -p "Install jq? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
      brew install jq
    else
      echo "Install using your system package manager"
    fi
  fi
fi
```

### 3. Git Infrastructure

**git:**
```bash
if command -v git &> /dev/null; then
  echo "✅ git: $(git --version)"
else
  echo "❌ git: Not installed (CRITICAL)"
  if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
    echo "Install: brew install git"
  else
    echo "Install: apt install git (Debian/Ubuntu) or yum install git (RedHat/CentOS)"
  fi
  read -p "Install git now? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
      brew install git
    fi
  fi
fi
```

**GitHub CLI (gh):**
```bash
if command -v gh &> /dev/null; then
  echo "✅ gh: $(gh --version | head -1)"
  
  # Check authentication
  if gh auth status &> /dev/null; then
    echo "✅ gh: Authenticated"
  else
    echo "⚠️  gh: Not authenticated"
    read -p "Run 'gh auth login' now? (y/n) " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      gh auth login
    fi
  fi
else
  echo "❌ gh: Not installed"
  if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
    echo "Install: brew install gh"
  else
    echo "Install: https://github.com/cli/cli#installation"
  fi
  read -p "Install gh? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [ "$IS_MACOS" = true ] && [ "$HAS_BREW" = true ]; then
      brew install gh
      gh auth login
    else
      echo "Install from: https://github.com/cli/cli#installation"
      [ "$IS_MACOS" = true ] && open https://github.com/cli/cli#installation
    fi
  fi
fi
```

### 4. AI Coding Tools

**beads_rust (Task management):**
```bash
if command -v br &> /dev/null; then
  echo "✅ beads_rust: $(br --version 2>/dev/null || echo 'installed')"
else
  echo "❌ beads_rust: Not installed"
  echo "Install: cargo install --git https://github.com/Dicklesworthstone/beads_rust.git"
  read -p "Install beads_rust? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cargo install --git https://github.com/Dicklesworthstone/beads_rust.git
  fi
fi
```

**beads_viewer (Robot planner):**
```bash
if command -v bv &> /dev/null; then
  echo "✅ beads_viewer: $(bv --version 2>/dev/null || echo 'installed')"
else
  echo "❌ beads_viewer: Not installed"
  echo "Install: curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/beads_viewer/main/install.sh | bash"
  read -p "Install beads_viewer? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/beads_viewer/main/install.sh | bash
  fi
fi
```

**abacus (Beads TUI for humans):**
```bash
if command -v abacus &> /dev/null; then
  echo "✅ abacus: installed"
else
  echo "❌ abacus: Not installed"
  echo "Install: cargo install --git https://github.com/ChrisEdwards/abacus"
  read -p "Install abacus? (y/n) " -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    cargo install --git https://github.com/ChrisEdwards/abacus
  fi
fi
```

**ultimate_bug_scanner:**
```bash
if command -v ubs &> /dev/null; then
  echo "✅ ultimate_bug_scanner: $(ubs --version 2>/dev/null || echo 'installed')"
else
  echo "❌ ultimate_bug_scanner: Not installed"
  echo "Install: curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/ultimate_bug_scanner/master/install.sh | bash -s -- --easy-mode"
  read -p "Install ultimate_bug_scanner with easy mode? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/ultimate_bug_scanner/master/install.sh | bash -s -- --easy-mode
  fi
fi
```

**cass_memory_system:**
```bash
if command -v cm &> /dev/null; then
  echo "✅ cass_memory_system: $(cm --version 2>/dev/null || echo 'installed')"
else
  echo "❌ cass_memory_system: Not installed"
  echo "Install: curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/cass_memory_system/main/install.sh | bash -s -- --easy-mode --verify"
  read -p "Install cass_memory_system? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/cass_memory_system/main/install.sh | bash -s -- --easy-mode --verify
  fi
fi
```

**coding_agent_session_search:**
```bash
if command -v cass &> /dev/null; then
  echo "✅ coding_agent_session_search: $(cass --version 2>/dev/null || echo 'installed')"
else
  echo "❌ coding_agent_session_search: Not installed"
  echo "Install: curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/coding_agent_session_search/main/install.sh | bash"
  read -p "Install coding_agent_session_search? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/coding_agent_session_search/main/install.sh | bash
  fi
fi
```

**mcp_agent_mail (Agent coordination):**
```bash
if command -v am &> /dev/null; then
  echo "✅ mcp_agent_mail: CLI installed"

  # Check if MCP server is running
  if curl -s http://localhost:8765/ &> /dev/null; then
    echo "✅ mcp_agent_mail: Server running on :8765"
  else
    echo "⚠️  mcp_agent_mail: Server not running"
    echo "Start with: am"
    read -p "Start server now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # Start in background and detach
      nohup am > /dev/null 2>&1 &
      echo "Server starting in background..."
      sleep 2
      if curl -s http://localhost:8765/ &> /dev/null; then
        echo "✅ Server is running"
      else
        echo "⚠️  Server may still be starting, check with: curl http://localhost:8765/"
      fi
    fi
  fi
else
  echo "❌ mcp_agent_mail: Not installed"
  echo "Install: curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/mcp_agent_mail/main/scripts/install.sh | bash -s -- --yes"
  read -p "Install mcp_agent_mail? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/mcp_agent_mail/main/scripts/install.sh | bash -s -- --yes
    echo ""
    echo "✅ mcp_agent_mail installed! The 'am' command starts the server."
    echo "   Server will auto-start in background on next shell session."
  fi
fi
```

### 5. Oracle CLIs

**Copilot CLI:**
```bash
if command -v copilot &> /dev/null; then
  echo "✅ copilot: installed"

  # Check config file
  if [ -f ~/.copilot/config.json ]; then
    echo "✅ copilot: Config file exists"
    echo "   Current model: $(cat ~/.copilot/config.json | grep -o '"model"[^,]*' || echo 'not set')"

    # Check if maxTokens is set
    if grep -q '"maxTokens"' ~/.copilot/config.json; then
      echo "   Max tokens: $(cat ~/.copilot/config.json | grep -o '"maxTokens"[^,]*' | grep -o '[0-9]*')"
    else
      echo "⚠️  copilot: maxTokens not configured"
      echo "   Adding maxTokens: 8192"
      # Backup existing config
      cp ~/.copilot/config.json ~/.copilot/config.json.bak
      # Add maxTokens if not present (requires jq)
      if command -v jq &> /dev/null; then
        cat ~/.copilot/config.json | jq '. + {maxTokens: 8192}' > ~/.copilot/config.json.tmp
        mv ~/.copilot/config.json.tmp ~/.copilot/config.json
        echo "✅ maxTokens set to 8192"
      else
        echo "⚠️  jq not installed. Please manually add '\"maxTokens\": 8192' to ~/.copilot/config.json"
      fi
    fi
  else
    echo "⚠️  copilot: No config file"
    echo "Create ~/.copilot/config.json with grok-code-fast-1 and maxTokens: 8192"
    read -p "Create config? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p ~/.copilot
      cat > ~/.copilot/config.json << 'EOF'
{
  "model": "grok-code-fast-1",
  "temperature": 0.2,
  "maxTokens": 8192
}
EOF
      echo "✅ Config created with grok-code-fast-1 and maxTokens: 8192"
    fi
  fi
else
  echo "❌ copilot: Not installed"
  echo "Install: curl -fsSL https://gh.io/copilot-install | bash"
  read -p "Install copilot CLI? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    curl -fsSL https://gh.io/copilot-install | bash

    # Create config with grok-code-fast-1 and maxTokens: 8192
    mkdir -p ~/.copilot
    cat > ~/.copilot/config.json << 'EOF'
{
  "model": "grok-code-fast-1",
  "temperature": 0.2,
  "maxTokens": 8192
}
EOF
    echo ""
    echo "✅ Copilot CLI installed and configured with grok-code-fast-1"
    echo ""
    echo "⚠️  IMPORTANT: Authenticate Copilot CLI"
    echo "   Run: copilot"
    echo "   Then use the /login slash command"
    echo "   Authorize via GitHub.com when prompted"
  fi
fi
```


### 6. Claude Code Configuration

**Set max token limits:**
```bash
echo "⚙️  Claude Code Configuration:"
echo ""

# Check if .claude.json exists
if [ -f ~/.claude.json ]; then
  echo "✅ Claude Code config exists"

  # Check if maxTokens is configured
  if grep -q '"maxTokens"' ~/.claude.json; then
    echo "   Max tokens: $(cat ~/.claude.json | grep -o '"maxTokens"[^,}]*' | grep -o '[0-9]*' || echo 'configured')"
  else
    echo "⚠️  maxTokens not configured in Claude Code"
    read -p "Set maxTokens to 200000 (200K)? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # Backup existing config
      cp ~/.claude.json ~/.claude.json.bak

      # Add maxTokens if not present (requires jq)
      if command -v jq &> /dev/null; then
        cat ~/.claude.json | jq '. + {maxTokens: 200000}' > ~/.claude.json.tmp
        mv ~/.claude.json.tmp ~/.claude.json
        echo "✅ maxTokens set to 200000"
      else
        echo "⚠️  jq not installed. Please manually add '\"maxTokens\": 200000' to ~/.claude.json"
        echo "   Install jq: brew install jq (macOS) or apt install jq (Linux)"
      fi
    fi
  fi
else
  echo "⚠️  ~/.claude.json not found"
  echo "   Claude Code config is typically created on first run"
  echo "   After running Claude Code once, re-run this setup to configure maxTokens"
fi
echo ""
```

### 7. Claude Code Plugins

These are Claude Code extensions that extend Claude's capabilities.

**Superpowers:**
```bash
echo "📦 Superpowers Plugin:"
echo ""

# Check if superpowers is available by checking the plugins directory
if [ -d ~/.claude/plugins/cache/superpowers-marketplace/superpowers ]; then
  echo "✅ Superpowers: installed"
else
  echo "❌ Superpowers: Not installed"
  echo ""
  echo "Installing Superpowers plugin..."
  read -p "Install Superpowers now? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running: claude plugin marketplace add obra/superpowers-marketplace"
    claude plugin marketplace add obra/superpowers-marketplace
    echo ""
    echo "Running: claude plugin install superpowers@superpowers-marketplace"
    claude plugin install superpowers@superpowers-marketplace
    echo ""
    echo "✅ Superpowers installed!"
  fi
fi
echo ""
```

**Compound Engineering:**
```bash
echo "📦 Compound Engineering Plugin:"
echo ""

# Check if compound-engineering is available
if [ -d ~/.claude/plugins/cache/every-marketplace/compound-engineering ]; then
  echo "✅ Compound Engineering: installed"
else
  echo "❌ Compound Engineering: Not installed"
  echo ""
  echo "Installing Compound Engineering plugin..."
  read -p "Install Compound Engineering now? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Running: claude plugin marketplace add every/every-marketplace"
    claude plugin marketplace add every/every-marketplace
    echo ""
    echo "Running: claude plugin install compound-engineering@every-marketplace"
    claude plugin install compound-engineering@every-marketplace
    echo ""
    echo "✅ Compound Engineering installed!"
  fi
fi
echo ""
```

**Destructive Command Guard (Command Protection):**
```bash
echo "🛡️  Destructive Command Guard:"
echo ""

# Check if dcg is installed
if command -v dcg &> /dev/null; then
  echo "✅ dcg (destructive_command_guard): $(dcg --version 2>/dev/null || echo 'installed')"

  # Check if config exists
  if [ -f ~/.config/dcg/config.toml ]; then
    echo "✅ dcg: Config file exists"
  else
    echo "⚠️  dcg: No config file"
    echo "   Creating default config with recommended packs..."
    mkdir -p ~/.config/dcg
    cat > ~/.config/dcg/config.toml << 'EOF'
[packs]
enabled = [
 "git.destructive",
 "filesystem.dangerous",
 "database.postgresql",
 "containers.docker"
]
EOF
    echo "✅ Config created with essential protection packs"
  fi
else
  echo "❌ dcg: Not installed"
  echo ""
  echo "Destructive Command Guard prevents accidental destructive commands."
  echo "It protects against:"
  echo "  - Destructive git operations (hard reset, force push)"
  echo "  - Dangerous filesystem commands (rm -rf)"
  echo "  - Database table/collection drops"
  echo "  - Container/Kubernetes deletions"
  echo ""
  read -p "Install dcg now? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing destructive_command_guard..."
    curl -fsSL "https://raw.githubusercontent.com/Dicklesworthstone/destructive_command_guard/master/install.sh?$(date +%s)" | bash

    # Create default config
    mkdir -p ~/.config/dcg
    cat > ~/.config/dcg/config.toml << 'EOF'
[packs]
enabled = [
 "git.destructive",
 "filesystem.dangerous",
 "database.postgresql",
 "containers.docker"
]
EOF
    echo ""
    echo "✅ dcg installed and configured!"
    echo "   Config: ~/.config/dcg/config.toml"
    echo "   Protection enabled for git, filesystem, database, and containers"
  fi
fi

# Configure Claude Code hook
echo "Configuring Claude Code PreToolUse hook..."
SETTINGS_FILE="$HOME/.claude/settings.json"

if [ -f "$SETTINGS_FILE" ]; then
  # Check if dcg hook is already configured
  if grep -q '"command".*"dcg"' "$SETTINGS_FILE"; then
    echo "✅ dcg hook already configured in Claude Code"
  else
    echo "⚠️  dcg installed but not configured as Claude Code hook"
    read -p "Add dcg as PreToolUse hook in Claude Code? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # Backup settings
      cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"

      # Add hook configuration using jq
      if command -v jq &> /dev/null; then
        # Check if hooks section exists
        if jq -e '.hooks' "$SETTINGS_FILE" > /dev/null 2>&1; then
          # Hooks exist, add to PreToolUse
          jq '.hooks.PreToolUse += [{"matcher": "Bash", "hooks": [{"type": "command", "command": "dcg"}]}]' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
          mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        else
          # No hooks section, create it
          jq '. + {"hooks": {"PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "dcg"}]}]}}' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
          mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
        fi
        echo "✅ dcg hook configured in Claude Code"
        echo "   Hook will activate on next Claude Code session"
      else
        echo "⚠️  jq not installed. Please manually add to $SETTINGS_FILE:"
        echo ''
        cat << 'EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "dcg"
          }
        ]
      }
    ]
  }
}
EOF
        echo ''
      fi
    fi
  fi
else
  echo "⚠️  $SETTINGS_FILE not found"
  echo "   Claude Code settings file will be created on first run"
  echo "   After running Claude Code once, manually add this to $SETTINGS_FILE:"
  echo ''
  cat << 'EOF'
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "dcg"
          }
        ]
      }
    ]
  }
}
EOF
  echo ''
fi
echo ""
```

**Configuring Destructive Command Guard:**

The protection system uses modular "packs" that can be enabled/disabled in `~/.config/dcg/config.toml`:

```toml
[packs]
enabled = [
 "git.destructive",          # Blocks: git reset --hard, git push --force
 "filesystem.dangerous",     # Blocks: rm -rf, dangerous deletes
 "database.postgresql",      # Blocks: DROP TABLE, TRUNCATE
 "database.mongodb",         # Blocks: dropDatabase, dropCollection
 "containers.docker",        # Blocks: docker rm, docker system prune
 "kubernetes"                # Blocks: kubectl delete
]
```

**How it works:**
- Uses a "whitelist-first" architecture for safety
- Scans commands (including heredocs) before execution
- Provides interactive prompts for blocked operations
- Zero performance overhead when commands are safe
- Can be temporarily bypassed with environment variables when needed

**Istari Skills:**
```bash
echo "📚 Istari Skills:"
echo ""

# Determine istari repo location
if [ -f "istari-setup.md" ]; then
  ISTARI_REPO=$(pwd)
elif [ -f ".claude/commands/istari-setup.md" ]; then
  ISTARI_REPO=$(dirname $(dirname $(pwd)/.claude))
else
  echo "⚠️  Cannot locate istari repository"
  echo "   Please run from istari repo or project with istari commands"
  ISTARI_REPO=""
fi

if [ -n "$ISTARI_REPO" ]; then
  # Check if uncle-bob-clean-code skill is installed
  if [ -f ~/.claude/skills/istari/uncle-bob-clean-code.md ]; then
    echo "✅ uncle-bob-clean-code skill: installed"
  else
    echo "❌ uncle-bob-clean-code skill: Not installed"

    if [ -f "$ISTARI_REPO/uncle-bob-clean-code-skill.md" ]; then
      echo ""
      echo "Installing uncle-bob-clean-code skill..."
      echo "This skill provides Java-focused Clean Code review following Robert C. Martin principles."
      read -p "Install uncle-bob-clean-code skill now? (y/n) " -n 1 -r
      echo ""
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        mkdir -p ~/.claude/skills/istari
        cp "$ISTARI_REPO/uncle-bob-clean-code-skill.md" ~/.claude/skills/istari/uncle-bob-clean-code.md
        echo "✅ uncle-bob-clean-code skill installed!"
        echo "   Skill location: ~/.claude/skills/istari/uncle-bob-clean-code.md"
        echo "   Invocation: /istari:uncle-bob-clean-code"
      fi
    else
      echo "⚠️  Source file not found: $ISTARI_REPO/uncle-bob-clean-code-skill.md"
      echo "   Run from istari repository or pull latest changes"
    fi
  fi
fi
echo ""
```

### 8. MCP Servers

**Context7 MCP Server (Documentation context provider):**
```bash
echo "📦 Context7 MCP Server:"
echo ""

# Check if context7 is configured by checking the claude config
if grep -q "context7" ~/.claude.json 2>/dev/null; then
  echo "✅ Context7: installed and configured"
else
  echo "❌ Context7: Not installed"
  echo ""
  echo "Context7 provides up-to-date documentation for any library via MCP."
  echo ""
  echo "Step 1: Get your Context7 API key"
  echo "   Visit: https://context7.com/dashboard"
  echo ""
  read -p "Open Context7 dashboard in browser? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
      open https://context7.com/dashboard
    else
      xdg-open https://context7.com/dashboard 2>/dev/null || echo "Please open: https://context7.com/dashboard"
    fi
  fi
  echo ""
  echo "Step 2: Enter your Context7 API key"
  read -p "Context7 API Key: " CONTEXT7_API_KEY
  echo ""

  if [ -n "$CONTEXT7_API_KEY" ]; then
    echo "Installing Context7 MCP server..."
    claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key "$CONTEXT7_API_KEY"
    echo ""
    echo "✅ Context7 installed and configured!"
  else
    echo "⚠️  No API key provided. Skipping Context7 installation."
  fi
fi
echo ""
```

**Sequential Thinking MCP Server (Structured problem-solving):**
```bash
echo "📦 Sequential Thinking MCP Server:"
echo ""

# Check if Sequential Thinking is configured
if grep -q "sequential-thinking" ~/.claude.json 2>/dev/null; then
  echo "✅ Sequential Thinking: installed and configured"
else
  echo "❌ Sequential Thinking: Not installed"
  echo ""
  echo "Sequential Thinking provides structured, step-by-step problem-solving via MCP."
  echo "It enables breaking down complex problems into manageable steps with support"
  echo "for revisions, branching, and dynamic adjustment of reasoning depth."
  echo ""
  read -p "Install Sequential Thinking MCP server? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Sequential Thinking MCP server..."
    claude mcp add sequential-thinking -- npx -y @modelcontextprotocol/server-sequential-thinking
    echo ""
    echo "✅ Sequential Thinking MCP server installed!"
  fi
fi
echo ""
```

**Atlassian MCP Server (Jira/Confluence integration):**
```bash
echo "📦 Atlassian MCP Server:"
echo ""

# Check if Atlassian is configured
if grep -q "atlassian" ~/.claude.json 2>/dev/null; then
  echo "✅ Atlassian: installed and configured"

  # Reminder about authentication
  echo ""
  echo "Note: You may need to authenticate by running '/mcp' in Claude Code"
else
  echo "❌ Atlassian: Not installed"
  echo ""
  echo "Atlassian MCP provides access to Jira issues and Confluence pages."
  echo ""
  read -p "Install Atlassian MCP server? (y/n) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing Atlassian MCP server..."
    claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
    echo ""
    echo "✅ Atlassian MCP server installed!"
    echo ""
    echo "IMPORTANT: You must authenticate by running '/mcp' in Claude Code"
    echo "           This will open a browser for OAuth authentication."
  fi
fi
echo ""
```

### 9. Summary Report

Generate comprehensive status report:

```bash
echo ""
echo "=========================================="
echo "  SETUP VERIFICATION SUMMARY"
echo "=========================================="
echo ""
echo "Language Runtimes:"
command -v bun &>/dev/null && echo "  ✅ bun" || echo "  ❌ bun"
command -v cargo &>/dev/null && echo "  ✅ rust/cargo" || echo "  ❌ rust/cargo"
command -v go &>/dev/null && echo "  ✅ go" || echo "  ❌ go"
command -v uv &>/dev/null && echo "  ✅ uv" || echo "  ❌ uv"

echo ""
echo "CLI Utilities:"
command -v rg &>/dev/null && echo "  ✅ ripgrep" || echo "  ❌ ripgrep"
command -v fzf &>/dev/null && echo "  ✅ fzf" || echo "  ❌ fzf"
command -v lazygit &>/dev/null && echo "  ✅ lazygit" || echo "  ❌ lazygit"
command -v sg &>/dev/null && echo "  ✅ ast-grep" || echo "  ❌ ast-grep"
command -v jq &>/dev/null && echo "  ✅ jq" || echo "  ❌ jq"

echo ""
echo "Git Infrastructure:"
command -v git &>/dev/null && echo "  ✅ git" || echo "  ❌ git"
command -v gh &>/dev/null && echo "  ✅ gh" || echo "  ❌ gh"

echo ""
echo "AI Coding Tools:"
command -v br &>/dev/null && echo "  ✅ beads_rust" || echo "  ❌ beads_rust"
command -v bv &>/dev/null && echo "  ✅ beads_viewer" || echo "  ❌ beads_viewer"
command -v abacus &>/dev/null && echo "  ✅ abacus" || echo "  ❌ abacus"
command -v ubs &>/dev/null && echo "  ✅ ultimate_bug_scanner" || echo "  ❌ ultimate_bug_scanner"
command -v cm &>/dev/null && echo "  ✅ cass_memory_system" || echo "  ❌ cass_memory_system"
command -v cass &>/dev/null && echo "  ✅ coding_agent_session_search" || echo "  ❌ coding_agent_session_search"
command -v am &>/dev/null && echo "  ✅ mcp_agent_mail" || echo "  ❌ mcp_agent_mail"

echo ""
echo "Oracle CLIs:"
command -v copilot &>/dev/null && echo "  ✅ copilot" || echo "  ❌ copilot"

echo ""
echo "Claude Code Plugins:"
[ -d ~/.claude/plugins/cache/superpowers-marketplace/superpowers ] && echo "  ✅ Superpowers" || echo "  ❌ Superpowers"
[ -d ~/.claude/plugins/cache/every-marketplace/compound-engineering ] && echo "  ✅ Compound Engineering" || echo "  ❌ Compound Engineering"

echo ""
echo "Command Protection:"
command -v dcg &>/dev/null && echo "  ✅ destructive_command_guard" || echo "  ❌ destructive_command_guard"

echo ""
echo "MCP Servers:"
grep -q "sequential-thinking" ~/.claude.json 2>/dev/null && echo "  ✅ Sequential Thinking" || echo "  ❌ Sequential Thinking"
grep -q "context7" ~/.claude.json 2>/dev/null && echo "  ✅ Context7" || echo "  ❌ Context7"
grep -q "atlassian" ~/.claude.json 2>/dev/null && echo "  ✅ Atlassian" || echo "  ❌ Atlassian"
echo ""
echo "=========================================="
```

**Final Check:**
```bash
# Count installed tools
INSTALLED=0
TOTAL=24

command -v bun &>/dev/null && ((INSTALLED++))
command -v cargo &>/dev/null && ((INSTALLED++))
command -v go &>/dev/null && ((INSTALLED++))
command -v uv &>/dev/null && ((INSTALLED++))
command -v rg &>/dev/null && ((INSTALLED++))
command -v fzf &>/dev/null && ((INSTALLED++))
command -v lazygit &>/dev/null && ((INSTALLED++))
command -v sg &>/dev/null && ((INSTALLED++))
command -v jq &>/dev/null && ((INSTALLED++))
command -v git &>/dev/null && ((INSTALLED++))
command -v gh &>/dev/null && ((INSTALLED++))
command -v br &>/dev/null && ((INSTALLED++))
command -v bv &>/dev/null && ((INSTALLED++))
command -v abacus &>/dev/null && ((INSTALLED++))
command -v ubs &>/dev/null && ((INSTALLED++))
command -v cm &>/dev/null && ((INSTALLED++))
command -v cass &>/dev/null && ((INSTALLED++))
command -v am &>/dev/null && ((INSTALLED++))
command -v copilot &>/dev/null && ((INSTALLED++))
command -v dcg &>/dev/null && ((INSTALLED++))

PERCENTAGE=$((INSTALLED * 100 / TOTAL))

echo ""
echo "Installation Progress: $INSTALLED/$TOTAL tools ($PERCENTAGE%)"
echo ""

if [ $INSTALLED -eq $TOTAL ]; then
  echo "🎉 All CLI tools installed!"
  echo ""
  echo "Next steps:"
  echo "1. Verify Claude Code plugins (Superpowers, Compound Engineering)"
  echo "2. Verify MCP servers (Sequential Thinking, Context7, Atlassian)"
  echo "3. Run '/istari-plan <ticket-or-description>' to start planning!"
else
  echo "⚠️  Some tools are missing. Review the checks above."
  echo ""
  echo "Critical for /istari-plan:"
  echo "  - beads_rust, beads_viewer (task management)"
  echo "  - Superpowers, Compound Engineering (planning)"
  echo ""
  echo "Critical for /istari-work:"
  echo "  - All of the above"
  echo "  - mcp_agent_mail, ultimate_bug_scanner, cass_memory_system, coding_agent_session_search"
  echo "  - copilot (oracle)"
fi
```

## Post-Setup Configuration

### mcp_agent_mail Server

If installed, start the server:
```bash
am server start
# Server runs on http://localhost:8765
```

Add to shell startup (~/.zshrc or ~/.bashrc):
```bash
# Auto-start agent mail server
if command -v am &> /dev/null; then
  am server status &>/dev/null || am server start &>/dev/null &
fi
```

### Copilot Configuration

Create config file with preferred model:
```bash
mkdir -p ~/.copilot
cat > ~/.copilot/config.json << 'EOF'
{
  "model": "grok-code-fast-1",
  "temperature": 0.2,
  "maxTokens": 8192
}
EOF
```

Recommended models:
- `grok-code-fast-1` - Fast code queries (default)
- `gpt-5` - Deep reasoning
- `claude-sonnet-3.5` - Balanced performance

### Claude Code Configuration

Set token limits for better context handling:
```bash
# Requires jq to be installed
if command -v jq &> /dev/null; then
  # Backup config
  cp ~/.claude.json ~/.claude.json.bak

  # Set maxTokens to 200K
  cat ~/.claude.json | jq '. + {maxTokens: 200000}' > ~/.claude.json.tmp
  mv ~/.claude.json.tmp ~/.claude.json
else
  echo "Install jq first: brew install jq (macOS) or apt install jq (Linux)"
fi
```

### CASS Memory Initialization

Initialize procedural memory for new projects:
```bash
cd ~/your-project
cm init

# Note: Knowledge accumulates naturally through work sessions
# Use 'cm reflect --json' after coding sessions to extract learnings
# Use 'cm context "<topic>" --json' to query existing knowledge
```

### Beads Initialization

Initialize beads_rust in existing project:
```bash
cd ~/your-project
br init
```

This creates `.beads/` directory for task tracking.

## Troubleshooting

**Cargo install failures:**
```bash
# Update rust toolchain
rustup update stable
rustc --version
```

**PATH issues (tools installed but not found):**
```bash
# Check your PATH includes:
echo $PATH | grep -E "(cargo/bin|\.local/bin|go/bin)"

# Add to ~/.zshrc or ~/.bashrc:
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/go/bin:$PATH"

source ~/.zshrc  # or ~/.bashrc
```

**MCP server connection issues:**
```bash
# Check if port 8765 is already in use
lsof -i :8765

# Restart agent mail server
am server stop
am server start

# Check logs
am server logs
```

**Plugin not showing in Claude Code:**
```bash
# Restart Claude Code completely
# Then check Extensions view again
# Some plugins require workspace reload
```

## Quick Install Script

For completely fresh setup, run all installs non-interactively:

```bash
# WARNING: This will install ALL tools without prompting
# Review before running!

# Detect macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  IS_MACOS=true
  echo "Installing on macOS using Homebrew where possible..."
  
  # Ensure Homebrew is installed
  if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  
  # Language runtimes (via brew)
  brew install bun
  brew install go
  brew install uv
  
  # CLI tools (via brew)
  brew install ripgrep
  brew install fzf
  brew install lazygit
  brew install ast-grep
  brew install jq
  brew install git
  brew install gh
  
  # Rust (for cargo-based tools)
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source $HOME/.cargo/env
else
  echo "Installing on Linux using standard methods..."

  # Language runtimes
  curl -fsSL https://bun.sh/install | bash
  curl -LsSf https://astral.sh/uv/install.sh | sh
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source $HOME/.cargo/env

  # CLI tools
  cargo install ripgrep
  cargo install ast-grep

  # jq (via system package manager)
  if command -v apt &> /dev/null; then
    sudo apt install -y jq
  elif command -v yum &> /dev/null; then
    sudo yum install -y jq
  fi
fi

# AI coding tools (cargo only - no brew formulae available)
cargo install --git https://github.com/Dicklesworthstone/beads_rust.git
cargo install --git https://github.com/Dicklesworthstone/beads_viewer
cargo install --git https://github.com/ChrisEdwards/abacus
cargo install --git https://github.com/Dicklesworthstone/ultimate_bug_scanner
cargo install --git https://github.com/Dicklesworthstone/cass_memory_system
cargo install --git https://github.com/Dicklesworthstone/mcp_agent_mail

# GitHub CLI auth
gh auth login

# Configure Copilot with maxTokens
mkdir -p ~/.copilot
cat > ~/.copilot/config.json << 'EOF'
{
  "model": "grok-code-fast-1",
  "temperature": 0.2,
  "maxTokens": 8192
}
EOF

# Configure Claude Code with maxTokens (if config exists)
if [ -f ~/.claude.json ]; then
  cp ~/.claude.json ~/.claude.json.bak
  cat ~/.claude.json | jq '. + {maxTokens: 200000}' > ~/.claude.json.tmp
  mv ~/.claude.json.tmp ~/.claude.json
  echo "✅ Claude Code maxTokens configured"
else
  echo "⚠️  Run Claude Code once to create ~/.claude.json, then re-run this script"
fi

# Start agent mail
am server start

echo "✅ CLI tools installed. Now install Claude Code plugins manually."
```

## Success Criteria

Setup is complete when:
- ✅ All CLI tools return version info
- ✅ GitHub CLI is authenticated
- ✅ Agent mail server is running on :8765
- ✅ Superpowers plugin is installed in `~/.claude/plugins/cache/superpowers-marketplace/`
- ✅ Compound Engineering is installed in `~/.claude/plugins/cache/every-marketplace/`
- ✅ Destructive Command Guard (dcg) is installed and configured at `~/.config/dcg/config.toml`
- ✅ Sequential Thinking MCP server is configured in `~/.claude.json`
- ✅ Context7 MCP server is configured in `~/.claude.json`
- ✅ Atlassian MCP server is configured and authenticated (run `/mcp` if needed)
- ✅ Copilot config file exists with preferred model and maxTokens: 8192
- ✅ Claude Code config has maxTokens: 200000 set
- ✅ Test project has `.beads/` directory after `br init`

**Ready to code!** Run `/istari-plan <description>` to start your first planning session.
