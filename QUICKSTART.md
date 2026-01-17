# Igor Quick Start

## Install

```bash
# Option 1: Curl (easiest)
curl -fsSL https://raw.githubusercontent.com/yourusername/igor/main/install.sh | bash

# Option 2: Git
git clone https://github.com/yourusername/igor.git
cd igor
./install.sh

# Then reload shell
source ~/.bashrc  # or source ~/.zshrc
```

## Your First Command

Go to any project and run:

```bash
$ cd ~/my-project
$ igor what does this codebase do
```

Igor will:
1. Detect your project
2. Load project context (from memory if exists)
3. Send your question to OpenCode
4. Stream the response back
5. Auto-save learnings for next time

## Session Continuity in Action

```bash
$ igor add email validation to the login form
# Igor completes the task, saves session ID

$ igor now add password strength indicator
# Igor continues the same session - remembers what you did!

$ cd ~/other-project
$ igor explain the database schema
# New project = new session automatically

$ cd ~/my-project
$ igor what did we last do here
# Back to original project, continues from where you left off
```

## Memory in Action

```bash
# See what Igor learned about this project
$ igor --memory

# See global preferences
$ igor --memory global

# Edit memory directly
$ igor --memory edit

# Clean up old entries
$ igor --memory compact
```

## Important Behaviors

### Asks for Confirmation Before:
- Writing/editing files
- Deleting files
- Git operations (commit, push, etc.)
- Running shell commands that modify state
- Batch operations (5+ files)

### Proceeds Without Asking:
- Reading files
- Searching code
- Listing contents
- Exploratory operations

### Force Fresh Session:
```bash
$ igor --new explain this codebase from scratch
```

## Config

Edit `~/.igor/config.yaml` to:
- Change default model
- Enable/disable confirmations
- Adjust session timeout
- Control memory behavior

Default config works great - only customize if needed.

## Common Patterns

**Iterative Development:**
```bash
$ igor create a user authentication module
$ igor add unit tests for auth
$ igor fix the failing test about password hashing
```

**Exploration:**
```bash
$ igor --new show me the API endpoints
$ igor what do the auth endpoints do
$ igor which endpoints need rate limiting
```

**Refactoring:**
```bash
$ igor --new refactor this module to TypeScript
$ igor add the missing type annotations
$ igor run tests and fix any failures
```

**Learning:**
```bash
$ igor explain the data model
$ igor what are the key design patterns used here
$ igor how does the caching system work
```

## Troubleshooting

**Command not found**
```bash
# Reload your shell
source ~/.bashrc

# Or check PATH
echo $PATH | grep .igor
```

**Want a fresh start**
```bash
# Clear current session
$ igor --clear

# Or start completely fresh
$ igor --new <task>

# Or see what's stored
$ ls ~/.igor/
```

**Memory acting weird**
```bash
# Check what's stored
$ igor --memory

# Clear old entries
$ igor --memory compact

# Edit directly
$ igor --memory edit
```

## Next Steps

1. **Read the README** - Full feature documentation
2. **Check ARCHITECTURE.md** - How Igor works internally
3. **Customize config** - Add default model, adjust confirmations
4. **Try with your projects** - Experience session continuity

## Tips

- Igor works best with projects using git
- Memory grows over time - use `--memory compact` monthly
- Sessions timeout after 24 hours (configurable)
- Share memory across team by checking in `~/.igor/memory/` to git
- Use `--new` when starting big refactors

Enjoy! 🚀
