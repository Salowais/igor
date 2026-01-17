# Igor - Natural Language CLI Assistant

A powerful shell wrapper that lets you use OpenCode directly from the command line with natural language. Say "igor do this" and watch it think, reason, and use tools to accomplish your task—all while asking for confirmation before anything destructive.

## Features

- **Natural language commands** - No quotes needed, just type naturally
- **Session continuity** - Igor remembers your project context across sessions
- **Persistent memory** - Auto-extracted learnings about your project
- **Streaming output** - Watch Igor think in real-time
- **Smart confirmations** - Only asks before destructive operations
- **Simple to install** - One command setup

## Installation

### Option 1: Quick Install (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/yourusername/igor/main/install.sh | bash
```

Then reload your shell:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Option 2: Manual Install

```bash
git clone https://github.com/yourusername/igor.git
cd igor
./install.sh
source ~/.bashrc  # or source ~/.zshrc
```

## Usage

### Basic Commands

```bash
# Simple natural language - no quotes needed
igor find all TODO comments in this project

igor refactor the authentication module to use async/await

igor explain the database schema

igor add a login page with email and password
```

### Memory Management

```bash
# View current project memory
igor --memory

# View global memory (cross-project preferences)
igor --memory global

# Edit project memory
igor --memory edit

# Compact memory (remove duplicates, merge related items)
igor --memory compact
```

### Session Management

```bash
# Start a fresh session (don't continue previous)
igor --new explain this codebase to me

# Clear current session
igor --clear
```

### Other Commands

```bash
# Show help
igor --help

# Show version
igor --version

# Show config file location and contents
igor --config
```

## How It Works

### Session Continuity

Igor automatically maps each project (git repo or directory) to an OpenCode session. This means:

- You can switch between projects and Igor remembers each one's context
- Sessions timeout after 24 hours by default (configurable)
- You can force a fresh session with `--new`

**Project Detection:**
- Uses git repository root if available
- Falls back to current working directory

### Memory System

Igor has two levels of memory:

1. **Global Memory** (`~/.igor/memory/global.md`)
   - Cross-project preferences
   - General learnings about your workflow
   - Shared across all projects

2. **Project Memory** (`~/.igor/memory/projects/<project>.md`)
   - Project-specific context
   - Architecture decisions made
   - Auto-extracted learnings from sessions

**Auto-Update:**
- After each session, Igor extracts 2-3 key learnings
- Runs in background (non-blocking)
- Includes timestamp for easy filtering

**Manual Compaction:**
- Run `igor --memory compact` to clean up old entries
- Removes duplicates and merges related items
- Keeps memory fresh and relevant

### Confirmation Behavior

Igor asks for confirmation before:
- Writing or editing files
- Deleting files
- Git operations (commit, push, reset, etc.)
- Running shell commands that modify state
- Batch operations affecting 5+ files

For read-only operations (viewing, searching, listing), Igor proceeds without asking.

## Configuration

Igor stores its config at `~/.igor/config.yaml`:

```yaml
# Default model (optional, uses OpenCode default if not set)
# model: anthropic/claude-sonnet-4

# Agent to use
agent: build

# What requires confirmation
confirm:
  file_write: true
  file_delete: true
  git_operations: true
  shell_commands: true
  batch_operations: true

# Memory settings
memory:
  enabled: true
  auto_update: true
  max_entries: 50

# Session settings
session:
  timeout_hours: 24
```

## Directory Structure

```
~/.igor/
├── config.yaml              # Main configuration
├── bin/
│   └── igor                 # Main executable
├── lib/
│   ├── config.sh            # Configuration parsing
│   ├── session.sh           # Session management
│   ├── memory.sh            # Memory operations
│   └── prompt.sh            # System prompt builder
├── sessions/
│   └── <project-hash>       # Maps projects to session IDs
├── memory/
│   ├── global.md            # Global memory
│   └── projects/
│       ├── my-app.md
│       └── another-project.md
└── cache/                   # Temporary files
```

## Examples

### Example 1: Adding a Feature

```bash
$ cd ~/projects/my-app
$ igor add a contact form to the home page with email validation
```

Igor will:
1. Ask what framework you're using (checks memory)
2. Ask for confirmation before writing files
3. Create/update components
4. Extract learnings about your setup

Next time you say something about this project, Igor remembers what framework and patterns you use.

### Example 2: Exploring Code

```bash
$ igor show me all the API endpoints and what they do
```

Igor will:
1. Search for API routes
2. Read relevant files
3. Summarize the endpoints
4. No confirmation needed (read-only)

### Example 3: Refactoring

```bash
$ igor --new refactor this project to use TypeScript strict mode
```

The `--new` flag forces a fresh session, so Igor gets a clean slate for analyzing the current state.

## Uninstall

```bash
~/code/igor/uninstall.sh
```

This removes Igor and cleans up your shell configuration.

## Architecture

Igor is built as a thin shell wrapper around OpenCode with these responsibilities:

1. **Session Management** - Maps projects to OpenCode sessions
2. **Memory** - Persists learnings and context between sessions
3. **Prompting** - Builds enhanced system prompts with context
4. **Configuration** - Manages user preferences and settings

The actual work is delegated to OpenCode, which has access to all its tools (LSP, bash, file operations, etc.).

## Tips & Tricks

**Combine with other shell commands:**
```bash
$ igor <command> > output.txt
$ igor <command> | grep something
```

**Quick iteration:**
```bash
$ igor implement feature X
$ igor now add tests for this
$ igor fix the failing test
```

Each command continues the session, so context carries over.

**Manual memory editing:**
```bash
$ igor --memory edit
# Opens $EDITOR with project memory
# Edit directly, save, and it's stored
```

**See what Igor is remembering:**
```bash
$ igor --memory        # Current project
$ igor --memory global # Global prefs
$ igor --memory all    # Everything
```

## Troubleshooting

**"Igor not found"**
- Make sure you ran `source ~/.bashrc` or restarted your terminal
- Check that `~/.igor/bin` is in your PATH: `echo $PATH`

**"Config file not found"**
- Run `igor --init` to create a default config

**Memory not updating**
- Check if memory is enabled: `cat ~/.igor/config.yaml | grep enabled`
- Memory extraction runs in background - give it a moment

**Session not continuing**
- Sessions timeout after 24 hours (configurable)
- Use `igor --new` to force a fresh session
- Check session status: look at `~/.igor/sessions/`

## Contributing

Igor is designed to be simple and self-contained. Feel free to:
- Fork and customize for your workflow
- Improve the shell scripts
- Add new memory features
- Optimize the prompting

## License

MIT

## Inspiration

Named after the ancient myth of Sisyphus - like pushing a boulder up a hill, we write code every day. Igor helps make that daily push a bit easier by being your intelligent assistant in the shell.
