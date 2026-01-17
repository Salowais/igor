# Igor v1.0 - Autonomous System Agent

An intelligent system diagnostics and repair agent that understands natural language and autonomously fixes Linux system issues. Think of it as having a senior sysadmin in your terminal who proactively identifies and resolves problems.

## Features

- **Natural Language Understanding** - Describe your problem in plain English, Igor figures out what to fix
- **Autonomous Diagnostics** - Runs detailed system checks without you having to know what commands to run
- **Smart Fixes** - Autonomously executes safe operations (restart services, fix permissions, update packages)
- **Safety First** - Always asks before destructive operations
- **Learning System** - Remembers issues it's fixed and patterns it's learned
- **Streaming Output** - See Igor thinking in real-time as it analyzes your system

## What Igor Can Do

### Service Management
```bash
$ igor my nginx server won't start
# Igor checks nginx status, reads logs, suggests and applies fixes

$ igor docker service keeps crashing
# Igor analyzes Docker issues, checks logs, recommends solutions
```

### Permission Fixes
```bash
$ igor fix my .ssh permissions
# Igor automatically fixes SSH directory and file permissions

$ igor why can't I access my home directory
# Igor diagnoses and fixes permission issues
```

### System Health
```bash
$ igor diagnose my system
# Full system health check with disk, memory, CPU, services

$ igor I'm running out of disk space
# Igor analyzes usage, suggests cleanup, helps free space
```

### Performance Issues
```bash
$ igor my system is slow
# Igor profiles CPU, memory, disk I/O and suggests optimizations

$ igor which process is using all my memory
# Igor identifies resource hogs and suggests fixes
```

### Network Problems
```bash
$ igor I can't reach the internet
# Igor tests connectivity, checks DNS, fixes network issues

$ igor diagnose my network
# Comprehensive network diagnostics
```

### Application Debugging
```bash
$ igor my postgresql won't connect
# Igor checks service status, logs, connection issues

$ igor ssh isn't working
# Igor diagnoses SSH configuration and permission issues
```

## Installation

### Quick Install

**Recommended (git clone):**
```bash
git clone https://github.com/Salowais/igor.git && cd igor && bash install.sh
source ~/.bashrc
```

**Via curl (if git unavailable):**
```bash
curl -fsSL https://github.com/Salowais/igor/archive/refs/heads/master.tar.gz | tar xz && cd igor-master && bash install.sh
source ~/.bashrc
```

### Manual Install

```bash
git clone https://github.com/salowais/igor.git
cd igor
./install.sh
source ~/.bashrc
```

## Usage

### Basic Interaction

```bash
# Igor runs diagnostics and suggests fixes
$ igor my service is failing

# Igor shows what's wrong, asks for confirmation, then fixes it
$ igor fix my permissions problems

# Get diagnostics without fixes
$ igor --diagnose disk

# Igor continues from previous context
$ igor now check if that fixed the issue
```

### Command Reference

```bash
igor <description>              Main agent - analyze and fix system issues
igor --diagnose [type]          Run diagnostics only (no fixes)
                                Types: services, disk, permissions, network,
                                       processes, logs, docker, health
igor --memory                   Show learned system knowledge
igor --memory edit              Edit system knowledge manually
igor --clear-history            Clear history of fixed issues
igor --dry-run <task>           Show what would be done without executing
igor --help                     Show help
igor --version                  Show version
```

## How Igor Works

### The Diagnostic Process

1. **Listen** - Understand your problem from natural language description
2. **Analyze** - Run appropriate system diagnostics
3. **Investigate** - Read logs, check configuration, understand root cause
4. **Explain** - Tell you clearly what's wrong and why
5. **Suggest** - Recommend specific fixes
6. **Confirm** - Ask for approval (when appropriate)
7. **Execute** - Apply the fix
8. **Verify** - Check that the fix worked
9. **Learn** - Remember the issue for future reference

### Confirmation Strategy

**Auto-Approved (no confirmation needed):**
- Restarting failed services
- Fixing obvious permission issues
- Viewing logs and diagnostics
- Updating package lists
- Enabling disabled services

**Always Asks First:**
- Deleting files or directories
- Modifying critical system configs
- Installing/removing packages
- Any operation affecting multiple systems

## Examples

### Example 1: Diagnose Service Failure

```bash
$ igor my nginx service won't start

Igor will:
1. Check if nginx is installed
2. Check service status with systemctl
3. Read recent logs from journalctl
4. Identify the problem (e.g., port in use, config error)
5. Suggest a fix
6. Ask for approval and apply it
7. Verify the service is running
```

### Example 2: Fix Permission Issues

```bash
$ igor I can't ssh into my server

Igor will:
1. Check ~/.ssh directory permissions
2. Check authorized_keys permissions
3. Check SSH service status
4. Fix permission issues automatically (knows safe values)
5. Suggest SSH config changes if needed
6. Test SSH connection
```

### Example 3: Diagnose Performance

```bash
$ igor my system is slow

Igor will:
1. Check CPU load
2. Check memory usage
3. Check disk I/O
4. Check for resource-hogging processes
5. Show top consumers
6. Suggest which processes to optimize or stop
```

## Configuration

Igor stores configuration at `~/.igor/config.yaml`:

```yaml
agent: build              # Agent to use
confirm:
  file_write: true       # Ask before writing files
  file_delete: true      # Ask before deleting
  git_operations: true   # Ask before git operations
  shell_commands: true   # Ask before shell commands
  batch_operations: true # Ask before batch ops
memory:
  enabled: true          # Enable learning
  auto_update: true      # Auto-extract learnings
```

## Data Storage

Igor stores information at `~/.igor/`:

```
~/.igor/
├── config.yaml                 Configuration
├── memory/
│   ├── system/
│   │   └── knowledge.md       What Igor learned about your system
│   └── issues/
│       └── fixed.log          Log of all fixed issues
└── sessions/                  Conversation history
```

## Learning System

Igor maintains a knowledge base at `~/.igor/memory/system/knowledge.md` that includes:

- Installed services and their locations
- Configuration file paths
- Common issues and how they were resolved
- System quirks and workarounds
- Performance baselines

You can view and edit this:

```bash
$ igor --memory              # View knowledge
$ igor --memory edit         # Edit manually
$ igor --clear-history       # Clear fixed issues log
```

## Safety & Security

- **No automatic changes without context** - Igor explains what it's doing
- **Clear confirmation requests** - Never changes system without approval
- **Audit trail** - All fixes logged in `~/.igor/memory/issues/fixed.log`
- **Safe defaults** - Uses standard, well-tested approaches
- **No credentials stored** - All auth via OpenCode's existing setup

## Troubleshooting

**"Igor command not found"**
```bash
source ~/.bashrc  # Reload shell
```

**"Permission denied"**
```bash
# Some operations require sudo
sudo igor fix my service issues
```

**"OpenCode not working"**
```bash
# Make sure OpenCode is installed and configured
opencode --help
```

**See what Igor learned**
```bash
igor --memory
```

## Requirements

- Bash 4.0+
- OpenCode CLI installed and configured
- Linux system (tested on Ubuntu, Debian, CentOS, Arch)
- Sudo access for system-level fixes

## Performance

- **Startup** - ~50ms (shell sourcing)
- **Diagnostics** - ~1-5s depending on system size
- **Execution** - Varies by operation (typically instant to a few seconds)
- **Learning** - Background, non-blocking

## Architecture

See `ARCHITECTURE.md` for technical design, data structures, and extensibility notes.

## Contributing

Igor is designed to be simple and extensible:

- Add new diagnostic functions to `lib/diagnostics.sh`
- Add new fix procedures to `lib/fixer.sh`
- Improve the system prompt in `igor` for better understanding
- Share learned configurations

## Tips & Tricks

**Understand what Igor will do**
```bash
igor --diagnose disk        # See issues without fixes
```

**Check what Igor learned**
```bash
igor --memory
```

**Run repeatedly**
```bash
igor my issue
igor is it fixed
igor what else needs fixing
# Igor maintains context across commands
```

**Force diagnosis and analysis**
```bash
igor --new analyze my system from scratch
```

**Combine with other tools**
```bash
igor my service won't start | tee issue-report.txt
```

## Limitations

- Requires system access (not remote by default, but can be extended)
- Works on Linux systems (macOS and Windows support possible)
- Some operations require sudo
- Depends on common Linux utilities being available

## Uninstall

```bash
~/code/igor/uninstall.sh
```

## License

MIT

## Inspiration

Named after Sisyphus - like daily system administration work, Igor helps push problems away so you can focus on what matters. No TUI, no bloat, just intelligent diagnostics and fixes.
