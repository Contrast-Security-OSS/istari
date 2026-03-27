#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================"
echo "  Istari Prerequisites Installer"
echo "========================================"
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
  IS_MACOS=true
  echo "📍 Detected: macOS"
else
  IS_MACOS=false
  echo "📍 Detected: Linux"
fi
echo ""

# Function to check if command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to install with error handling
install_tool() {
  local tool_name=$1
  local install_cmd=$2

  echo -e "${YELLOW}Installing $tool_name...${NC}"
  if eval "$install_cmd"; then
    echo -e "${GREEN}✅ $tool_name installed successfully${NC}"
    return 0
  else
    echo -e "${RED}❌ Failed to install $tool_name${NC}"
    return 1
  fi
}

# ========================================
# 1. Package Manager Setup
# ========================================
echo "=== Package Manager Setup ==="
echo ""

if [ "$IS_MACOS" = true ]; then
  if ! command_exists brew; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  else
    echo -e "${GREEN}✅ Homebrew already installed${NC}"
  fi
fi
echo ""

# ========================================
# 2. Language Runtimes
# ========================================
echo "=== Language Runtimes ==="
echo ""

# Rust + Cargo
if ! command_exists cargo; then
  install_tool "Rust/Cargo" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
  source "$HOME/.cargo/env"
else
  echo -e "${GREEN}✅ Rust/Cargo already installed${NC}"
fi

# Bun
if ! command_exists bun; then
  if [ "$IS_MACOS" = true ]; then
    install_tool "Bun" "brew install bun"
  else
    install_tool "Bun" "curl -fsSL https://bun.sh/install | bash"
    export BUN_INSTALL="$HOME/.bun"
    export PATH="$BUN_INSTALL/bin:$PATH"
  fi
else
  echo -e "${GREEN}✅ Bun already installed${NC}"
fi

# Go
if ! command_exists go; then
  if [ "$IS_MACOS" = true ]; then
    install_tool "Go" "brew install go"
  else
    echo -e "${YELLOW}Please install Go from https://go.dev/dl/${NC}"
  fi
else
  echo -e "${GREEN}✅ Go already installed${NC}"
fi

# uv (Python package manager)
if ! command_exists uv; then
  if [ "$IS_MACOS" = true ]; then
    install_tool "uv" "brew install uv"
  else
    install_tool "uv" "curl -LsSf https://astral.sh/uv/install.sh | sh"
  fi
else
  echo -e "${GREEN}✅ uv already installed${NC}"
fi
echo ""

# ========================================
# 3. CLI Utilities
# ========================================
echo "=== CLI Utilities ==="
echo ""

# ripgrep
if ! command_exists rg; then
  if [ "$IS_MACOS" = true ]; then
    install_tool "ripgrep" "brew install ripgrep"
  else
    install_tool "ripgrep" "cargo install ripgrep"
  fi
else
  echo -e "${GREEN}✅ ripgrep already installed${NC}"
fi

# fzf
if ! command_exists fzf; then
  if [ "$IS_MACOS" = true ]; then
    install_tool "fzf" "brew install fzf"
  else
    install_tool "fzf" "git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all"
  fi
else
  echo -e "${GREEN}✅ fzf already installed${NC}"
fi

# lazygit
if ! command_exists lazygit; then
  if [ "$IS_MACOS" = true ]; then
    install_tool "lazygit" "brew install lazygit"
  else
    install_tool "lazygit" "go install github.com/jesseduffield/lazygit@latest"
  fi
else
  echo -e "${GREEN}✅ lazygit already installed${NC}"
fi

# ast-grep
if ! command_exists sg; then
  if [ "$IS_MACOS" = true ]; then
    install_tool "ast-grep" "brew install ast-grep"
  else
    install_tool "ast-grep" "cargo install ast-grep"
  fi
else
  echo -e "${GREEN}✅ ast-grep already installed${NC}"
fi

# jq
if ! command_exists jq; then
  if [ "$IS_MACOS" = true ]; then
    install_tool "jq" "brew install jq"
  else
    echo -e "${YELLOW}Please install jq using your system package manager:${NC}"
    echo "  Debian/Ubuntu: sudo apt install -y jq"
    echo "  RedHat/CentOS: sudo yum install -y jq"
  fi
else
  echo -e "${GREEN}✅ jq already installed${NC}"
fi
echo ""

# ========================================
# 4. Git Infrastructure
# ========================================
echo "=== Git Infrastructure ==="
echo ""

# git
if ! command_exists git; then
  if [ "$IS_MACOS" = true ]; then
    install_tool "git" "brew install git"
  else
    echo -e "${YELLOW}Please install git using your system package manager:${NC}"
    echo "  Debian/Ubuntu: sudo apt install -y git"
    echo "  RedHat/CentOS: sudo yum install -y git"
  fi
else
  echo -e "${GREEN}✅ git already installed${NC}"
fi

# GitHub CLI (gh)
if ! command_exists gh; then
  if [ "$IS_MACOS" = true ]; then
    install_tool "GitHub CLI" "brew install gh"
  else
    echo -e "${YELLOW}Please install gh from https://github.com/cli/cli#installation${NC}"
  fi
else
  echo -e "${GREEN}✅ GitHub CLI already installed${NC}"
fi
echo ""

# ========================================
# 5. AI Coding Tools (Cargo-based)
# ========================================
echo "=== AI Coding Tools ==="
echo ""

# beads_rust
if ! command_exists br; then
  install_tool "beads_rust" "cargo install --git https://github.com/Dicklesworthstone/beads_rust.git"
else
  echo -e "${GREEN}✅ beads_rust already installed${NC}"
fi

# beads_viewer
if ! command_exists bv; then
  install_tool "beads_viewer" "curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/beads_viewer/main/install.sh | bash"
else
  echo -e "${GREEN}✅ beads_viewer already installed${NC}"
fi

# abacus
if ! command_exists abacus; then
  if [ "$IS_MACOS" = true ]; then
    echo -e "${YELLOW}Installing abacus via Homebrew tap...${NC}"
    brew tap ChrisEdwards/tap
    install_tool "abacus" "brew install abacus"
  else
    install_tool "abacus" "cargo install --git https://github.com/ChrisEdwards/abacus"
  fi
else
  echo -e "${GREEN}✅ abacus already installed${NC}"
fi

# ultimate_bug_scanner
if ! command_exists ubs; then
  install_tool "ultimate_bug_scanner" "curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/ultimate_bug_scanner/master/install.sh | bash -s -- --easy-mode"
else
  echo -e "${GREEN}✅ ultimate_bug_scanner already installed${NC}"
fi

# cass_memory_system
if ! command_exists cm; then
  install_tool "cass_memory_system" "curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/cass_memory_system/main/install.sh | bash -s -- --easy-mode --verify"
else
  echo -e "${GREEN}✅ cass_memory_system already installed${NC}"
fi

# coding_agent_session_search
#if ! command_exists cass; then
#  if [ "$IS_MACOS" = true ]; then
#    echo -e "${YELLOW}Installing coding_agent_session_search via Homebrew tap...${NC}"
#    brew tap dicklesworthstone/tap
#    install_tool "coding_agent_session_search" "brew install dicklesworthstone/tap/cass"
#  else
#    install_tool "coding_agent_session_search" "curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/coding_agent_session_search/main/install.sh | bash"
#  fi
#else
#  echo -e "${GREEN}✅ coding_agent_session_search already installed${NC}"
#fi

# mcp_agent_mail
if ! command_exists am; then
  install_tool "mcp_agent_mail" "curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/mcp_agent_mail/main/scripts/install.sh | bash -s -- --yes"
else
  echo -e "${GREEN}✅ mcp_agent_mail already installed${NC}"
fi
echo ""

# ========================================
# 6. Destructive Command Guard
# ========================================
echo "=== Destructive Command Guard ==="
echo ""

if ! command_exists dcg; then
  install_tool "destructive_command_guard" "curl -fsSL \"https://raw.githubusercontent.com/Dicklesworthstone/destructive_command_guard/master/install.sh?\$(date +%s)\" | bash"

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
  echo -e "${GREEN}✅ dcg config created at ~/.config/dcg/config.toml${NC}"
else
  echo -e "${GREEN}✅ destructive_command_guard already installed${NC}"
fi
echo ""

# ========================================
# 7. Copilot CLI
# ========================================
echo "=== Copilot CLI ==="
echo ""

if ! command_exists copilot; then
  install_tool "Copilot CLI" "curl -fsSL https://gh.io/copilot-install | bash"

  # Create config with recommended settings
  mkdir -p ~/.copilot
  cat > ~/.copilot/config.json << 'EOF'
{
  "model": "grok-code-fast-1",
  "temperature": 0.2,
  "maxTokens": 8192
}
EOF
  echo -e "${GREEN}✅ Copilot config created with grok-code-fast-1 and maxTokens: 8192${NC}"
  echo -e "${YELLOW}⚠️  IMPORTANT: Run 'copilot' and use /login to authenticate${NC}"
else
  echo -e "${GREEN}✅ Copilot CLI already installed${NC}"
fi
echo ""

# ========================================
# 8. Claude Code Configuration
# ========================================
echo "=== Claude Code Configuration ==="
echo ""

if [ -f ~/.claude.json ]; then
  if ! grep -q '"maxTokens"' ~/.claude.json; then
    echo "Setting maxTokens to 200000 in Claude Code config..."
    cp ~/.claude.json ~/.claude.json.bak
    if command_exists jq; then
      cat ~/.claude.json | jq '. + {maxTokens: 200000}' > ~/.claude.json.tmp
      mv ~/.claude.json.tmp ~/.claude.json
      echo -e "${GREEN}✅ Claude Code maxTokens set to 200000${NC}"
    else
      echo -e "${YELLOW}⚠️  jq not available. Please manually add '\"maxTokens\": 200000' to ~/.claude.json${NC}"
    fi
  else
    echo -e "${GREEN}✅ Claude Code maxTokens already configured${NC}"
  fi
else
  echo -e "${YELLOW}⚠️  ~/.claude.json not found. Run Claude Code once, then re-run this script.${NC}"
fi
echo ""

# ========================================
# 8a. Claude Code Plugins
# ========================================
echo "=== Claude Code Plugins ==="
echo ""

# Check if GitHub is authenticated (required for plugin marketplaces)
if ! gh auth status &> /dev/null; then
  echo -e "${YELLOW}⚠️  GitHub authentication required for plugin installation${NC}"
  echo "   Skipping automatic plugin installation"
  echo "   After running 'gh auth login', install plugins with:"
  echo ""
  echo "   claude plugin marketplace add obra/superpowers-marketplace"
  echo "   claude plugin install superpowers@superpowers-marketplace"
  echo ""
  echo "   claude plugin marketplace add every/every-marketplace"
  echo "   claude plugin install compound-engineering@every-marketplace"
  echo ""
elif command_exists claude; then
  echo -e "${YELLOW}Note: Plugin installation may take 30-60 seconds${NC}"
  echo ""
  PLUGIN_ERRORS=false

  echo "Installing Superpowers plugin..."
  if [ -d ~/.claude/plugins/cache/superpowers-marketplace/superpowers ]; then
    echo -e "${GREEN}✅ Superpowers already installed${NC}"
  else
    # Check if marketplace already exists
    if [ ! -d ~/.claude/plugins/marketplaces/obra-superpowers-marketplace ]; then
      echo "   Adding marketplace..."
      if ! claude plugin marketplace add obra/superpowers-marketplace 2>&1; then
        echo -e "${YELLOW}⚠️  Failed to add marketplace (may already exist)${NC}"
      fi
    fi

    echo "   Installing plugin..."
    if claude plugin install superpowers@superpowers-marketplace 2>&1; then
      echo -e "${GREEN}✅ Superpowers installation initiated${NC}"
      sleep 2
    else
      echo -e "${YELLOW}⚠️  Superpowers installation failed${NC}"
      PLUGIN_ERRORS=true
    fi
  fi

  echo ""
  echo "Installing Compound Engineering plugin..."
  if [ -d ~/.claude/plugins/cache/every-marketplace/compound-engineering ]; then
    echo -e "${GREEN}✅ Compound Engineering already installed${NC}"
  else
    # Check if marketplace already exists
    if [ ! -d ~/.claude/plugins/marketplaces/every-every-marketplace ]; then
      echo "   Adding marketplace..."
      if ! claude plugin marketplace add every/every-marketplace 2>&1; then
        echo -e "${YELLOW}⚠️  Failed to add marketplace${NC}"
        echo "   This usually means GitHub authentication is needed"
        echo "   Run 'gh auth login' first, then try again"
        PLUGIN_ERRORS=true
      fi
    fi

    if [ "$PLUGIN_ERRORS" = false ]; then
      echo "   Installing plugin..."
      if claude plugin install compound-engineering@every-marketplace 2>&1; then
        echo -e "${GREEN}✅ Compound Engineering installation initiated${NC}"
        sleep 2
      else
        echo -e "${YELLOW}⚠️  Compound Engineering installation failed${NC}"
        PLUGIN_ERRORS=true
      fi
    fi
  fi

  echo ""
  if [ "$PLUGIN_ERRORS" = true ]; then
    echo -e "${YELLOW}⚠️  Some plugins failed to install${NC}"
    echo "   This is usually due to GitHub authentication"
    echo "   Run these commands to install manually:"
    echo ""
    echo "   1. Authenticate GitHub CLI:"
    echo "      gh auth login"
    echo ""
    echo "   2. Install plugins in Claude Code:"
    echo "      claude plugin marketplace add obra/superpowers-marketplace"
    echo "      claude plugin install superpowers@superpowers-marketplace"
    echo ""
    echo "      claude plugin marketplace add every/every-marketplace"
    echo "      claude plugin install compound-engineering@every-marketplace"
    echo ""
  else
    echo -e "${GREEN}✅ Plugin installation complete${NC}"
    echo "   Restart Claude Code to activate plugins"
  fi
elif ! command_exists claude; then
  echo -e "${YELLOW}⚠️  'claude' CLI not found. Install Claude Code first.${NC}"
  echo "   Download from: https://docs.anthropic.com/en/docs/claude-code"
fi
echo ""

# ========================================
# 8b. Configure DCG Hook in Claude Code
# ========================================
echo "=== Configuring DCG Hook ==="
echo ""

SETTINGS_FILE="$HOME/.claude/settings.json"

if [ -f "$SETTINGS_FILE" ] && command_exists dcg && command_exists jq; then
  if grep -q '"command".*"dcg"' "$SETTINGS_FILE"; then
    echo -e "${GREEN}✅ dcg hook already configured${NC}"
  else
    echo "Adding dcg PreToolUse hook..."
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak"

    # Check if hooks section exists
    if jq -e '.hooks' "$SETTINGS_FILE" > /dev/null 2>&1; then
      # Hooks exist, check if PreToolUse exists
      if jq -e '.hooks.PreToolUse' "$SETTINGS_FILE" > /dev/null 2>&1; then
        # PreToolUse exists, append to it
        jq '.hooks.PreToolUse += [{"matcher": "Bash", "hooks": [{"type": "command", "command": "dcg"}]}]' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
      else
        # PreToolUse doesn't exist, create it
        jq '.hooks.PreToolUse = [{"matcher": "Bash", "hooks": [{"type": "command", "command": "dcg"}]}]' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
      fi
    else
      # No hooks section, create everything
      jq '. + {"hooks": {"PreToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "dcg"}]}]}}' "$SETTINGS_FILE" > "$SETTINGS_FILE.tmp"
    fi

    mv "$SETTINGS_FILE.tmp" "$SETTINGS_FILE"
    echo -e "${GREEN}✅ dcg hook configured${NC}"
  fi
elif [ ! -f "$SETTINGS_FILE" ]; then
  echo -e "${YELLOW}⚠️  $SETTINGS_FILE not found. Run Claude Code once to create it.${NC}"
elif ! command_exists dcg; then
  echo -e "${YELLOW}⚠️  dcg not installed. Hook configuration skipped.${NC}"
elif ! command_exists jq; then
  echo -e "${YELLOW}⚠️  jq not installed. Manual hook configuration required.${NC}"
fi
echo ""

# ========================================
# 8c. Install Istari Skills
# ========================================
echo "=== Istari Skills ==="
echo ""

# Determine istari repository location
ISTARI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create skills directory
SKILLS_DIR="$HOME/.claude/skills/istari"
mkdir -p "$SKILLS_DIR"

# Install uncle-bob-clean-code skill
if [ -f "$ISTARI_DIR/uncle-bob-clean-code-skill.md" ]; then
  if [ -f "$SKILLS_DIR/uncle-bob-clean-code.md" ]; then
    echo -e "${GREEN}✅ uncle-bob-clean-code skill already installed${NC}"
  else
    cp "$ISTARI_DIR/uncle-bob-clean-code-skill.md" "$SKILLS_DIR/uncle-bob-clean-code.md"
    echo -e "${GREEN}✅ uncle-bob-clean-code skill installed${NC}"
    echo "   Location: $SKILLS_DIR/uncle-bob-clean-code.md"
    echo "   Invoke with: /istari:uncle-bob-clean-code"
  fi
else
  echo -e "${YELLOW}⚠️  uncle-bob-clean-code-skill.md not found in $ISTARI_DIR${NC}"
fi
echo ""

# ========================================
# 9. Symlink Istari Commands
# ========================================
echo "=== Istari Commands ==="
echo ""

# Determine istari repository location
ISTARI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Istari repository: $ISTARI_DIR"
echo ""

# Create .claude/commands directory
COMMANDS_DIR="$HOME/.claude/commands"
mkdir -p "$COMMANDS_DIR"
echo "✅ Commands directory: $COMMANDS_DIR"

# List of command files to symlink
COMMAND_FILES=(
  "istari-setup.md"
  "istari-plan.md"
  "istari-work.md"
  "istari-update.md"
  "istari-upgrade.md"
  "istari-review.md"
  "istari-skill-builder.md"
  "istari-help.md"
)

echo "Creating symlinks for istari commands..."
echo ""

LINKED=0
FAILED=0

for cmd_file in "${COMMAND_FILES[@]}"; do
  source_file="$ISTARI_DIR/$cmd_file"
  target_link="$COMMANDS_DIR/$cmd_file"

  if [ -f "$source_file" ]; then
    # Remove existing file or symlink
    if [ -e "$target_link" ] || [ -L "$target_link" ]; then
      rm -f "$target_link"
    fi

    # Create symlink
    if ln -s "$source_file" "$target_link" 2>/dev/null; then
      echo -e "${GREEN}✅ $cmd_file${NC}"
      LINKED=$((LINKED + 1))
    else
      echo -e "${RED}❌ Failed to link $cmd_file${NC}"
      FAILED=$((FAILED + 1))
    fi
  else
    echo -e "${YELLOW}⚠️  $cmd_file not found in repository${NC}"
    FAILED=$((FAILED + 1))
  fi
done

echo ""
if [ $FAILED -eq 0 ]; then
  echo -e "${GREEN}✅ All $LINKED istari commands symlinked successfully${NC}"
else
  echo -e "${YELLOW}⚠️  $LINKED commands linked, $FAILED skipped${NC}"
fi
echo ""

# ========================================
# 10. PATH Configuration
# ========================================
echo "=== PATH Configuration ==="
echo ""

# Determine shell config file
if [ -f ~/.zshrc ]; then
  SHELL_RC=~/.zshrc
elif [ -f ~/.bashrc ]; then
  SHELL_RC=~/.bashrc
else
  SHELL_RC=~/.profile
fi

echo "Ensuring PATH includes necessary directories..."

# Add cargo bin to PATH
if ! grep -q 'export PATH="$HOME/.cargo/bin:$PATH"' "$SHELL_RC"; then
  echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "$SHELL_RC"
  echo -e "${GREEN}✅ Added ~/.cargo/bin to PATH in $SHELL_RC${NC}"
fi

# Add go bin to PATH
if ! grep -q 'export PATH="$HOME/go/bin:$PATH"' "$SHELL_RC"; then
  echo 'export PATH="$HOME/go/bin:$PATH"' >> "$SHELL_RC"
  echo -e "${GREEN}✅ Added ~/go/bin to PATH in $SHELL_RC${NC}"
fi

# Add local bin to PATH
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$SHELL_RC"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
  echo -e "${GREEN}✅ Added ~/.local/bin to PATH in $SHELL_RC${NC}"
fi

# Add bun bin to PATH (for Linux)
if [ "$IS_MACOS" = false ] && ! grep -q 'export PATH="$HOME/.bun/bin:$PATH"' "$SHELL_RC"; then
  echo 'export PATH="$HOME/.bun/bin:$PATH"' >> "$SHELL_RC"
  echo -e "${GREEN}✅ Added ~/.bun/bin to PATH in $SHELL_RC${NC}"
fi

echo ""
echo -e "${YELLOW}⚠️  Run 'source $SHELL_RC' to apply PATH changes${NC}"
echo ""

# ========================================
# 11. Service Authentication
# ========================================
echo "=== Service Authentication ==="
echo ""

# GitHub CLI authentication
if command_exists gh; then
  if gh auth status &> /dev/null; then
    echo -e "${GREEN}✅ GitHub CLI already authenticated${NC}"
  else
    echo "Authenticating GitHub CLI..."
    echo -e "${YELLOW}This will open a browser for OAuth authentication.${NC}"
    read -p "Authenticate GitHub CLI now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      gh auth login --web
      if gh auth status &> /dev/null; then
        echo -e "${GREEN}✅ GitHub CLI authenticated${NC}"
      else
        echo -e "${YELLOW}⚠️  GitHub CLI authentication may have failed${NC}"
      fi
    else
      echo -e "${YELLOW}⚠️  Skipped. Run 'gh auth login' manually later.${NC}"
    fi
  fi
else
  echo -e "${YELLOW}⚠️  GitHub CLI not installed. Skipping authentication.${NC}"
fi
echo ""

# Copilot CLI authentication
if command_exists copilot; then
  # Check if copilot is authenticated by running a test command
  if copilot --version &> /dev/null 2>&1; then
    echo -e "${GREEN}✅ Copilot CLI installed${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  Copilot CLI requires manual authentication${NC}"
    echo "   Run: copilot"
    echo "   Then use: /login"
    echo "   This will open a browser for GitHub authentication."
    echo ""
    read -p "Open copilot CLI now for authentication? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      echo "Launching copilot CLI..."
      echo "Type '/login' in the CLI to authenticate, then '/exit' to return here."
      copilot || true
    else
      echo -e "${YELLOW}⚠️  Skipped. Run 'copilot' manually and use '/login' command.${NC}"
    fi
  fi
else
  echo -e "${YELLOW}⚠️  Copilot CLI not installed. Skipping authentication.${NC}"
fi
echo ""

# Start mcp_agent_mail server
if command_exists am; then
  if curl -s http://localhost:8765/ &> /dev/null; then
    echo -e "${GREEN}✅ mcp_agent_mail server already running${NC}"
  else
    echo "Starting mcp_agent_mail server..."
    read -p "Start agent mail server now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      # Start in background and detach
      nohup am > /tmp/am-server.log 2>&1 &
      echo "Server starting in background..."
      sleep 2
      if curl -s http://localhost:8765/ &> /dev/null; then
        echo -e "${GREEN}✅ mcp_agent_mail server running on :8765${NC}"
      else
        echo -e "${YELLOW}⚠️  Server may still be starting. Check with: curl http://localhost:8765/${NC}"
        echo "   Logs: /tmp/am-server.log"
      fi
    else
      echo -e "${YELLOW}⚠️  Skipped. Run 'am' manually to start the server.${NC}"
    fi
  fi
else
  echo -e "${YELLOW}⚠️  mcp_agent_mail not installed. Skipping server start.${NC}"
fi
echo ""

# ========================================
# 12. MCP Server Configuration
# ========================================
echo "=== MCP Server Configuration ==="
echo ""

if command_exists claude; then
  # Context7 MCP Server
  if grep -q "context7" ~/.claude.json 2>/dev/null; then
    echo -e "${GREEN}✅ Context7 MCP server already configured${NC}"
  else
    echo "Context7 provides up-to-date documentation for any library via MCP."
    echo ""
    echo "Get your API key from: https://context7.com/dashboard"
    echo ""
    read -p "Configure Context7 now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      if [ "$IS_MACOS" = true ]; then
        open https://context7.com/dashboard 2>/dev/null || true
      else
        xdg-open https://context7.com/dashboard 2>/dev/null || true
      fi
      echo "Enter your Context7 API key (or press Enter to skip):"
      read -r CONTEXT7_API_KEY
      if [ -n "$CONTEXT7_API_KEY" ]; then
        claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key "$CONTEXT7_API_KEY"
        echo -e "${GREEN}✅ Context7 configured${NC}"
      else
        echo -e "${YELLOW}⚠️  Skipped. Configure later with: claude mcp add context7${NC}"
      fi
    else
      echo -e "${YELLOW}⚠️  Skipped. Configure later with: claude mcp add context7${NC}"
    fi
  fi
  echo ""

  # Atlassian MCP Server
  if grep -q "atlassian" ~/.claude.json 2>/dev/null; then
    echo -e "${GREEN}✅ Atlassian MCP server already configured${NC}"
  else
    echo "Atlassian MCP provides access to Jira and Confluence."
    echo ""
    read -p "Configure Atlassian MCP now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse
      echo -e "${GREEN}✅ Atlassian MCP server installed${NC}"
      echo ""
      echo -e "${YELLOW}⚠️  You must authenticate by running '/mcp' in Claude Code${NC}"
      echo "   This will open a browser for OAuth authentication."
    else
      echo -e "${YELLOW}⚠️  Skipped. Configure later with: claude mcp add atlassian${NC}"
    fi
  fi
else
  echo -e "${YELLOW}⚠️  'claude' CLI not found. Install Claude Code first.${NC}"
  echo "   Download from: https://docs.anthropic.com/en/docs/claude-code"
  echo ""
  echo "After installing Claude Code, configure MCP servers with:"
  echo "   Context7: claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key YOUR_KEY"
  echo "   Atlassian: claude mcp add --transport sse atlassian https://mcp.atlassian.com/v1/sse"
fi
echo ""

# ========================================
# 13. Summary
# ========================================
echo "========================================"
echo "  Installation Summary"
echo "========================================"
echo ""

INSTALLED=0
TOTAL=24

# Count installed tools
command_exists bun && ((INSTALLED++))
command_exists cargo && ((INSTALLED++))
command_exists go && ((INSTALLED++))
command_exists uv && ((INSTALLED++))
command_exists rg && ((INSTALLED++))
command_exists fzf && ((INSTALLED++))
command_exists lazygit && ((INSTALLED++))
command_exists sg && ((INSTALLED++))
command_exists jq && ((INSTALLED++))
command_exists git && ((INSTALLED++))
command_exists gh && ((INSTALLED++))
command_exists br && ((INSTALLED++))
command_exists bv && ((INSTALLED++))
command_exists abacus && ((INSTALLED++))
command_exists ubs && ((INSTALLED++))
command_exists cm && ((INSTALLED++))
command_exists cass && ((INSTALLED++))
command_exists am && ((INSTALLED++))
command_exists copilot && ((INSTALLED++))
command_exists dcg && ((INSTALLED++))

echo "Language Runtimes:"
command_exists bun && echo -e "  ${GREEN}✅ bun${NC}" || echo -e "  ${RED}❌ bun${NC}"
command_exists cargo && echo -e "  ${GREEN}✅ rust/cargo${NC}" || echo -e "  ${RED}❌ rust/cargo${NC}"
command_exists go && echo -e "  ${GREEN}✅ go${NC}" || echo -e "  ${RED}❌ go${NC}"
command_exists uv && echo -e "  ${GREEN}✅ uv${NC}" || echo -e "  ${RED}❌ uv${NC}"

echo ""
echo "CLI Utilities:"
command_exists rg && echo -e "  ${GREEN}✅ ripgrep${NC}" || echo -e "  ${RED}❌ ripgrep${NC}"
command_exists fzf && echo -e "  ${GREEN}✅ fzf${NC}" || echo -e "  ${RED}❌ fzf${NC}"
command_exists lazygit && echo -e "  ${GREEN}✅ lazygit${NC}" || echo -e "  ${RED}❌ lazygit${NC}"
command_exists sg && echo -e "  ${GREEN}✅ ast-grep${NC}" || echo -e "  ${RED}❌ ast-grep${NC}"
command_exists jq && echo -e "  ${GREEN}✅ jq${NC}" || echo -e "  ${RED}❌ jq${NC}"

echo ""
echo "Git Infrastructure:"
command_exists git && echo -e "  ${GREEN}✅ git${NC}" || echo -e "  ${RED}❌ git${NC}"
command_exists gh && echo -e "  ${GREEN}✅ gh${NC}" || echo -e "  ${RED}❌ gh${NC}"

echo ""
echo "AI Coding Tools:"
command_exists br && echo -e "  ${GREEN}✅ beads_rust${NC}" || echo -e "  ${RED}❌ beads_rust${NC}"
command_exists bv && echo -e "  ${GREEN}✅ beads_viewer${NC}" || echo -e "  ${RED}❌ beads_viewer${NC}"
command_exists abacus && echo -e "  ${GREEN}✅ abacus${NC}" || echo -e "  ${RED}❌ abacus${NC}"
command_exists ubs && echo -e "  ${GREEN}✅ ultimate_bug_scanner${NC}" || echo -e "  ${RED}❌ ultimate_bug_scanner${NC}"
command_exists cm && echo -e "  ${GREEN}✅ cass_memory_system${NC}" || echo -e "  ${RED}❌ cass_memory_system${NC}"
command_exists cass && echo -e "  ${GREEN}✅ coding_agent_session_search${NC}" || echo -e "  ${RED}❌ coding_agent_session_search${NC}"
command_exists am && echo -e "  ${GREEN}✅ mcp_agent_mail${NC}" || echo -e "  ${RED}❌ mcp_agent_mail${NC}"

echo ""
echo "Command Protection:"
command_exists dcg && echo -e "  ${GREEN}✅ destructive_command_guard${NC}" || echo -e "  ${RED}❌ destructive_command_guard${NC}"

echo ""
echo "Oracle CLIs:"
command_exists copilot && echo -e "  ${GREEN}✅ copilot${NC}" || echo -e "  ${RED}❌ copilot${NC}"

echo ""
echo "Claude Code:"
command_exists claude && echo -e "  ${GREEN}✅ claude CLI${NC}" || echo -e "  ${RED}❌ claude CLI${NC}"
[ -d ~/.claude/plugins/cache/superpowers-marketplace/superpowers ] && echo -e "  ${GREEN}✅ Superpowers plugin${NC}" || echo -e "  ${YELLOW}⚠️  Superpowers plugin${NC}"
[ -d ~/.claude/plugins/cache/every-marketplace/compound-engineering ] && echo -e "  ${GREEN}✅ Compound Engineering plugin${NC}" || echo -e "  ${YELLOW}⚠️  Compound Engineering plugin${NC}"
[ -f ~/.claude/skills/istari/uncle-bob-clean-code.md ] && echo -e "  ${GREEN}✅ istari skills${NC}" || echo -e "  ${YELLOW}⚠️  istari skills${NC}"
[ -f ~/.claude/settings.json ] && grep -q '"command".*"dcg"' ~/.claude/settings.json 2>/dev/null && echo -e "  ${GREEN}✅ dcg hook configured${NC}" || echo -e "  ${YELLOW}⚠️  dcg hook not configured${NC}"

echo ""
echo "MCP Servers:"
grep -q "context7" ~/.claude.json 2>/dev/null && echo -e "  ${GREEN}✅ Context7${NC}" || echo -e "  ${YELLOW}⚠️  Context7${NC}"
grep -q "atlassian" ~/.claude.json 2>/dev/null && echo -e "  ${GREEN}✅ Atlassian${NC}" || echo -e "  ${YELLOW}⚠️  Atlassian${NC}"

echo ""
echo "Service Authentication:"
gh auth status &> /dev/null && echo -e "  ${GREEN}✅ GitHub CLI${NC}" || echo -e "  ${YELLOW}⚠️  GitHub CLI${NC}"
command_exists am && curl -s http://localhost:8765/ &> /dev/null && echo -e "  ${GREEN}✅ agent mail server${NC}" || echo -e "  ${YELLOW}⚠️  agent mail server${NC}"

echo ""
PERCENTAGE=$((INSTALLED * 100 / TOTAL))
echo "Installation Progress: $INSTALLED/$TOTAL tools ($PERCENTAGE%)"
echo ""

if [ $INSTALLED -eq $TOTAL ]; then
  echo -e "${GREEN}🎉 All CLI tools installed successfully!${NC}"
else
  echo -e "${YELLOW}⚠️  Some tools may need manual installation. Review the output above.${NC}"
fi

echo ""
echo "========================================"
echo "  📋 MANUAL STEPS REQUIRED"
echo "========================================"
echo ""

MANUAL_STEPS=0

# Check what needs to be done
NEED_SOURCE=true
NEED_GH_AUTH=false
NEED_COPILOT_AUTH=false
NEED_AM_START=false
NEED_CONTEXT7=false
NEED_ATLASSIAN_OAUTH=false
NEED_CLAUDE_SETUP=false
NEED_PLUGIN_CHECK=false

# Service auth checks
if ! gh auth status &> /dev/null 2>&1; then
  NEED_GH_AUTH=true
fi

if command_exists copilot; then
  NEED_COPILOT_AUTH=true  # Always show since we can't reliably check auth
fi

if command_exists am && ! curl -s http://localhost:8765/ &> /dev/null; then
  NEED_AM_START=true
fi

# MCP server checks
if ! grep -q "context7" ~/.claude.json 2>/dev/null; then
  NEED_CONTEXT7=true
fi

if grep -q "atlassian" ~/.claude.json 2>/dev/null; then
  NEED_ATLASSIAN_OAUTH=true  # If installed, OAuth is likely needed
fi

# Claude Code checks
if [ ! -f ~/.claude.json ]; then
  NEED_CLAUDE_SETUP=true
fi

if [ ! -d ~/.claude/plugins/cache/superpowers-marketplace/superpowers ] || \
   [ ! -d ~/.claude/plugins/cache/every-marketplace/compound-engineering ]; then
  NEED_PLUGIN_CHECK=true
fi

# If GitHub isn't authenticated, plugins definitely need to be installed
if ! gh auth status &> /dev/null 2>&1; then
  NEED_PLUGIN_CHECK=true
fi

# Display steps
echo -e "${GREEN}Step 1: Apply PATH changes${NC}"
echo "   Run this command now:"
echo -e "   ${YELLOW}source $SHELL_RC${NC}"
echo ""
((MANUAL_STEPS++))

if [ "$NEED_CLAUDE_SETUP" = true ]; then
  echo -e "${GREEN}Step $((MANUAL_STEPS + 1)): Install Claude Code${NC}"
  echo "   Claude Code is not installed yet."
  echo "   Download from: https://docs.anthropic.com/en/docs/claude-code"
  echo "   After installation, re-run this script to complete setup."
  echo ""
  ((MANUAL_STEPS++))
fi

if [ "$NEED_GH_AUTH" = true ]; then
  echo -e "${GREEN}Step $((MANUAL_STEPS + 1)): Authenticate GitHub CLI${NC}"
  echo "   Run:"
  echo -e "   ${YELLOW}gh auth login${NC}"
  echo "   This will open a browser for OAuth authentication."
  echo ""
  ((MANUAL_STEPS++))
fi

if [ "$NEED_COPILOT_AUTH" = true ]; then
  echo -e "${GREEN}Step $((MANUAL_STEPS + 1)): Authenticate Copilot CLI${NC}"
  echo "   Run:"
  echo -e "   ${YELLOW}copilot${NC}"
  echo "   Then in the CLI, use the command:"
  echo -e "   ${YELLOW}/login${NC}"
  echo "   This will open a browser for GitHub authentication."
  echo ""
  ((MANUAL_STEPS++))
fi

if [ "$NEED_AM_START" = true ]; then
  echo -e "${GREEN}Step $((MANUAL_STEPS + 1)): Start Agent Mail Server${NC}"
  echo "   Run:"
  echo -e "   ${YELLOW}am${NC}"
  echo "   Server will run on http://localhost:8765"
  echo "   (Or add to shell startup to auto-start)"
  echo ""
  ((MANUAL_STEPS++))
fi

if [ "$NEED_CONTEXT7" = true ]; then
  echo -e "${GREEN}Step $((MANUAL_STEPS + 1)): Configure Context7 MCP Server${NC}"
  echo "   Get your API key from: https://context7.com/dashboard"
  echo "   Then run:"
  echo -e "   ${YELLOW}claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key YOUR_KEY${NC}"
  echo ""
  ((MANUAL_STEPS++))
fi

if [ "$NEED_ATLASSIAN_OAUTH" = true ]; then
  echo -e "${GREEN}Step $((MANUAL_STEPS + 1)): Authenticate Atlassian MCP${NC}"
  echo "   Open Claude Code and run:"
  echo -e "   ${YELLOW}/mcp${NC}"
  echo "   This will open a browser for Atlassian OAuth authentication."
  echo ""
  ((MANUAL_STEPS++))
fi

if [ "$NEED_PLUGIN_CHECK" = true ]; then
  echo -e "${GREEN}Step $((MANUAL_STEPS + 1)): Install Claude Code Plugins${NC}"
  if ! gh auth status &> /dev/null 2>&1; then
    echo "   First authenticate GitHub CLI, then install plugins:"
    echo -e "   ${YELLOW}gh auth login${NC}"
    echo ""
  else
    echo "   Install plugins with:"
  fi
  echo -e "   ${YELLOW}claude plugin marketplace add obra/superpowers-marketplace${NC}"
  echo -e "   ${YELLOW}claude plugin install superpowers@superpowers-marketplace${NC}"
  echo ""
  echo -e "   ${YELLOW}claude plugin marketplace add every/every-marketplace${NC}"
  echo -e "   ${YELLOW}claude plugin install compound-engineering@every-marketplace${NC}"
  echo ""
  ((MANUAL_STEPS++))
fi

echo -e "${GREEN}Step $((MANUAL_STEPS + 1)): Verify Installation${NC}"
echo "   Open Claude Code and run:"
echo -e "   ${YELLOW}/istari-setup${NC}"
echo "   This will verify all components are working correctly."
echo ""
((MANUAL_STEPS++))

echo -e "${GREEN}Step $((MANUAL_STEPS + 1)): Initialize Your Project${NC}"
echo "   In your project directory, run:"
echo -e "   ${YELLOW}br init${NC}"
echo "   This creates the .beads/ directory for task tracking."
echo ""
((MANUAL_STEPS++))

echo "========================================"
echo -e "${GREEN}🚀 Ready to Start!${NC}"
echo "========================================"
echo ""

# Write next steps to a file for easy reference
NEXT_STEPS_FILE="$HOME/istari-next-steps.txt"
cat > "$NEXT_STEPS_FILE" << EOF
==========================================
  📋 ISTARI INSTALLATION - NEXT STEPS
==========================================

Step 1: Apply PATH changes
   Run: source $SHELL_RC

EOF

if [ "$NEED_CLAUDE_SETUP" = true ]; then
  cat >> "$NEXT_STEPS_FILE" << 'EOF'
Step X: Install Claude Code
   Download from: https://docs.anthropic.com/en/docs/claude-code
   After installation, re-run this script.

EOF
fi

if [ "$NEED_GH_AUTH" = true ]; then
  cat >> "$NEXT_STEPS_FILE" << 'EOF'
Step X: Authenticate GitHub CLI
   Run: gh auth login

EOF
fi

if [ "$NEED_COPILOT_AUTH" = true ]; then
  cat >> "$NEXT_STEPS_FILE" << 'EOF'
Step X: Authenticate Copilot CLI
   Run: copilot
   Then: /login

EOF
fi

if [ "$NEED_AM_START" = true ]; then
  cat >> "$NEXT_STEPS_FILE" << 'EOF'
Step X: Start Agent Mail Server
   Run: am

EOF
fi

if [ "$NEED_CONTEXT7" = true ]; then
  cat >> "$NEXT_STEPS_FILE" << 'EOF'
Step X: Configure Context7 MCP Server
   Get API key from: https://context7.com/dashboard
   Run: claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key YOUR_KEY

EOF
fi

if [ "$NEED_ATLASSIAN_OAUTH" = true ]; then
  cat >> "$NEXT_STEPS_FILE" << 'EOF'
Step X: Authenticate Atlassian MCP
   In Claude Code, run: /mcp

EOF
fi

if [ "$NEED_PLUGIN_CHECK" = true ]; then
  if ! gh auth status &> /dev/null 2>&1; then
    cat >> "$NEXT_STEPS_FILE" << 'EOF'
Step X: Install Claude Code Plugins
   First authenticate GitHub CLI:
   Run: gh auth login

   Then install plugins:
   Run: claude plugin marketplace add obra/superpowers-marketplace
   Run: claude plugin install superpowers@superpowers-marketplace
   Run: claude plugin marketplace add every/every-marketplace
   Run: claude plugin install compound-engineering@every-marketplace

EOF
  else
    cat >> "$NEXT_STEPS_FILE" << 'EOF'
Step X: Install Claude Code Plugins
   Run: claude plugin marketplace add obra/superpowers-marketplace
   Run: claude plugin install superpowers@superpowers-marketplace
   Run: claude plugin marketplace add every/every-marketplace
   Run: claude plugin install compound-engineering@every-marketplace

EOF
  fi
fi

cat >> "$NEXT_STEPS_FILE" << 'EOF'
Step X: Verify Installation
   In Claude Code, run: /istari-setup

Step X: Initialize Your Project
   In your project directory, run: br init

==========================================
🚀 ISTARI COMMANDS
==========================================

/istari-plan <description>    - Plan your work
/istari-work <bead-id>        - Execute implementation
/istari-review <pr-url>       - Review pull requests
/istari-update                - Sync latest commands
/istari-help                  - Display help

==========================================
EOF

echo -e "${GREEN}✅ Next steps saved to: ${YELLOW}$NEXT_STEPS_FILE${NC}"
echo ""

echo "Once setup is complete, you can use istari commands:"
echo ""
echo -e "  ${YELLOW}/istari-plan <description>${NC}"
echo "    Plan your work by decomposing Jira tickets into beads"
echo ""
echo -e "  ${YELLOW}/istari-work <bead-id>${NC}"
echo "    Execute implementation with TDD and code review"
echo ""
echo -e "  ${YELLOW}/istari-review <pr-url>${NC}"
echo "    Comprehensive PR code review"
echo ""
echo -e "  ${YELLOW}/istari-update${NC}"
echo "    Sync latest istari commands from repo"
echo ""
echo -e "  ${YELLOW}/istari-help${NC}"
echo "    Display help for all istari commands"
echo ""
echo "========================================"
echo ""
echo -e "${YELLOW}Need help?${NC} Check out the documentation:"
echo "  - README.md: Overview and getting started"
echo "  - istari-setup.md: Detailed setup guide"
echo "  - istari-plan.md: Planning workflow"
echo "  - istari-work.md: Development workflow"
echo ""
echo ""
echo "╔════════════════════════════════════════════════════╗"
echo "║                                                    ║"
echo "║  ⚠️  SCROLL UP to see detailed instructions       ║"
echo "║     OR view saved file:                            ║"
echo "║                                                    ║"
echo "║     cat ~/istari-next-steps.txt                    ║"
echo "║                                                    ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""
