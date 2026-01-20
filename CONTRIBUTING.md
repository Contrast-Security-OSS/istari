# Contributing to Istari

Thank you for your interest in contributing to Istari! This guide will help you get set up for development.

## 🔀 Branching Strategy

**Important**: All development should be based on the `main` branch:

- **Feature branches**: Branch from `main`
- **Pull requests**: Merge into `main`

```bash
# Create a new feature branch from main
git checkout main
git pull origin main
git checkout -b feature/your-feature-name

# When ready to submit
# Create PR targeting main
```

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/Contrast-Security-OSS/istari.git
cd istari

# Verify all prerequisites are installed
/istari-setup
```

### 2. Install Dependencies

Istari requires several tools for full functionality:

```bash
# Core dependencies (installed via istari-setup):
# - beads & beads_viewer (task management)
# - mcp_agent_mail (agent coordination)
# - ultimate_bug_scanner (security scanning)
# - Context7 (documentation lookup)
# - cass_memory_system (procedural memory)
# - copilot CLI (AI assistance)
# - CLI utilities: ripgrep, fzf, ast-grep, jq
# - Git tools: git, gh

# Run istari-setup to verify and install:
/istari-setup
```

### 3. Verify Setup

```bash
# Check all prerequisites are installed
/istari-setup

# Should show all green checkmarks for installed tools
```

## 🔧 Development Workflow

### Beads Task Management

Istari uses the **beads** workflow for task tracking:

```bash
# See available work
bd ready

# Create a new task
bd create --title="Add new feature" --type=task --priority=1

# Start working on a task
bd update <bead-id> --status=in_progress

# Close completed task
bd close <bead-id>

# Sync beads to git
bd sync
```

### Code Quality

- Follow command file conventions (YAML frontmatter + markdown)
- Test commands interactively before committing
- Document all new features in command files

### Running Tests

```bash
# Test individual commands by invoking them:
/istari-setup   # Verify setup checks work
/istari-plan    # Test planning workflow
/istari-work    # Test autonomous work execution
/istari-update  # Test command syncing
/istari-upgrade # Test version management
/istari-review  # Test review orchestration
```

### Code Style Guidelines

- **Command files**: Use clear section headers (##, ###)
- **Shell commands**: Include comments explaining complex logic
- **Examples**: Provide realistic example invocations
- **Error handling**: Show clear error messages with recovery steps

## 🧪 Testing Guidelines

- Test commands in real development scenarios
- Verify beads workflow integration
- Test with both project-local and global .claude directories
- Ensure commands work from different directory contexts

## 📋 Pull Request Process

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make Changes**
   - Write/update command files following conventions
   - Update istari-setup.md if adding new dependencies
   - Test commands interactively
   - Track work with beads:
     ```bash
     bd create --title="Your feature"
     bd update <bead-id> --status=in_progress
     ```

3. **Commit Changes**
   ```bash
   git add .
   git commit -m "Add feature: description of changes"

   # Close associated beads
   bd close <bead-id>
   bd sync
   ```

4. **Push and Create PR**
   ```bash
   git push origin feature/your-feature-name
   # Create pull request on GitHub
   ```

5. **PR Requirements**
   - ✅ All commands tested interactively
   - ✅ Documentation updated (README.md, command files)
   - ✅ Beads synced to git
   - ✅ Code review approval

## 🔍 Development Commands

### Local Development Cycle

```bash
# Full development cycle
/istari-setup              # Verify prerequisites
bd create --title="..."    # Create task
bd update <id> --status=in_progress  # Start work
# ... make changes ...
git commit                 # Commit changes
bd close <id>              # Mark complete
bd sync                    # Sync beads to git
```

### Testing New Commands

```bash
# Test command from repository
cd /path/to/istari
/command-name

# Test after installing to .claude directory
/istari-update             # Sync to target directory
cd /path/to/project
/command-name              # Test from project
```

## 🐛 Troubleshooting

#### Commands Not Found After Update

```bash
# Verify commands were synced correctly
ls -la ~/.claude/commands/istari-*.md

# If missing, re-run update:
cd /path/to/istari
/istari-update
```

#### Beads Sync Issues

```bash
# Check sync status
bd sync --status

# Pull latest from main
bd sync --from-main

# Run beads doctor for diagnostics
bd doctor
```

#### Prerequisites Not Installed

```bash
# Run setup to identify missing tools
/istari-setup

# Install missing tools as indicated
# Then re-run setup to verify
```

## 📝 Command File Conventions

When creating new istari commands:

1. **YAML Frontmatter**: Include description
   ```yaml
   ---
   description: Brief description of what this command does
   ---
   ```

2. **Sections**:
   - Overview: What the command does
   - Prerequisites: Required tools/setup
   - Workflow: Step-by-step execution
   - Error Handling: Common issues and fixes
   - Examples: Real invocation examples

3. **Shell Commands**: Use bash code blocks with clear comments

4. **User Interaction**: Clear prompts and confirmation steps

Thank you for contributing to Istari! 🙏
