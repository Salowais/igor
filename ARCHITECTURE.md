# Igor v1.0 Architecture - Autonomous System Agent

## Overview

Igor is an intelligent system diagnostics and repair agent that:
1. **Understands natural language** about system problems
2. **Runs diagnostic checks** autonomously
3. **Identifies root causes** and suggests fixes
4. **Executes safe operations** without asking
5. **Asks for confirmation** on potentially destructive changes
6. **Learns from experience** - remembers issues it's fixed

## Core Design Philosophy

Igor follows this principle: **Be autonomous but safe**
- Auto-approve read-only operations (diagnostics, viewing logs, understanding)
- Auto-approve common safe fixes (restart services, fix permissions)
- Always ask before anything destructive (delete, modify critical config, install packages)

## Components

### Core Modules (`lib/`)

**config.sh** (~80 lines)
- YAML configuration parsing
- Query functions with sensible defaults
- Auto-initialization of config

**session.sh** (~110 lines)
- Project/system detection (git root or cwd)
- MD5-based session mapping
- Session persistence and timeout checking
- Works at system level (hostname-based by default)

**memory.sh** (~190 lines)
- System knowledge base storage
- Issue history logging
- Learn operations (append findings)
- Automatic and manual memory management

**diagnostics.sh** (NEW - ~200 lines)
- System health checking (CPU, memory, disk, I/O)
- Service status and logging
- Network diagnostics
- Process analysis
- Docker/container checks
- Permission auditing
- Package manager inspection

**fixer.sh** (NEW - ~150 lines)
- Permission fixing (chmod)
- Service management (restart, start, stop, enable)
- Disk space optimization suggestions
- Package update checking
- Docker troubleshooting
- Network issue fixes
- Memory pressure analysis

**prompt.sh** (~60 lines)
- System prompt builder
- Memory context injection
- Behavior guidelines for OpenCode

### Main Script

**igor** (~130 lines)
- Command-line argument parsing
- Diagnostic mode (--diagnose with types)
- Memory management (view, edit, clear history)
- Agent orchestration
- OpenCode integration

## Data Flow

```
User Request
    ↓
Igor Script (parse command)
    ↓
┌─────────────────────────────────┐
│   DIAGNOSTIC MODE?              │
│   (--diagnose)                  │
│   Yes → Run diagnostics.sh      │
│   No  → Continue to agent       │
└─────────────────────────────────┘
    ↓
Load System Knowledge
(~/.igor/memory/system/knowledge.md)
    ↓
Build System Prompt with Guidelines
(behavior rules, tools available, knowledge)
    ↓
opencode run --prompt <prompt> <task>
    ↓
OpenCode analyzes & executes (with agent tools)
    ↓
Output captured & logged
    ↓
Update system knowledge (background)
    ↓
Log any fixes executed
```

## Storage Structure

```
~/.igor/
├── config.yaml                 User configuration
├── bin/
│   └── igor                    Main executable
├── lib/
│   ├── config.sh
│   ├── session.sh
│   ├── memory.sh
│   ├── diagnostics.sh
│   ├── fixer.sh
│   └── prompt.sh
├── memory/
│   ├── system/
│   │   └── knowledge.md        System knowledge base
│   └── issues/
│       └── fixed.log           Log of fixed issues
└── sessions/
    └── <hostname-hash>         Session ID storage
```

## System Knowledge Base

Format: `~/.igor/memory/system/knowledge.md` (Markdown)

```markdown
# System Knowledge Base

## Installed Services
- nginx at /etc/nginx/
- postgresql on port 5432
- docker running

## Configuration Locations
- SSH: /etc/ssh/sshd_config
- Nginx: /etc/nginx/nginx.conf

## Common Issues (and fixes)
- Port already in use: find with lsof, restart service
- Permission denied on .ssh: chmod 600 /root/.ssh/id_rsa
- Disk full: clean apt cache, old logs

## Fixed Issues
- 2025-01-17: Nginx wouldn't start due to syntax error in config
- 2025-01-16: Docker socket permission issue fixed with group membership
```

## Autonomous Execution Strategy

### Three Levels of Operations

**Level 1: Auto-Execute (no confirmation)**
```
- View operations: cat, ls, tail, head
- Status checks: systemctl status, docker ps
- Diagnostics: logs, metrics, service info
- List operations: ps, netstat, df
- Safe reads: /var/log/*, /etc/* (non-critical)
```

**Level 2: Confirm (ask user first)**
```
- File operations: write, edit, create
- Dangerous commands: rm, mv (files)
- Service changes: restart, enable (minor)
- Config changes: /etc/* modifications
- Package ops: apt install, yum install (major)
```

**Level 3: Strongly Confirm (critical)**
```
- Destructive: rm -rf, format, wipe
- Critical config: /root/*, /boot/*, /etc/passwd
- System changes: kernel, init system, users
- Batch operations: changes affecting multiple systems
```

OpenCode is instructed via system prompt to respect these levels.

## Confirmation in Practice

User says: "My nginx won't start"

Igor runs: 
1. `systemctl status nginx` → shows error (auto, no confirm)
2. `journalctl -u nginx -n 50` → shows config syntax error (auto)
3. "Configuration has syntax error at line 42"
4. Suggests: "Fix the config?" 
5. User: "yes"
6. OpenCode uses system tools to fix it
7. "Testing fix with: nginx -t" (auto)
8. "✓ Nginx now running"

User says: "Delete all old docker images"

Igor stops and asks:
"I found 5 unused Docker images totaling 2GB. Deleting images cannot be undone. Confirm? (yes/no)"
User confirms → proceeds

## Learning Mechanism

### Automatic Learning
After each successful fix, Igor extracts and stores:
- Issue description
- Root cause identified
- Fix applied
- Verification step
- Timestamp

### Manual Learning
Users can:
```bash
igor --memory edit      # Add custom knowledge
```

Edit knowledge.md directly to record:
- New service locations
- Custom configurations
- Organization-specific workarounds
- Performance baselines

## Configuration

Default `~/.igor/config.yaml`:

```yaml
agent: build                    # OpenCode agent to use

confirm:
  file_write: true             # Prompt before file operations
  file_delete: true            # Prompt before deletions
  git_operations: true         # Prompt before git ops
  shell_commands: true         # Prompt before shell commands
  batch_operations: true       # Prompt for multi-system changes

memory:
  enabled: true                # Enable learning
  auto_update: true            # Auto-extract learnings
```

## Performance Characteristics

| Operation | Time |
|-----------|------|
| Startup | ~50ms (shell sourcing) |
| Diagnostics | 1-5s (system dependent) |
| Service restart | <2s |
| Permission fix | <1s |
| Log analysis | 2-10s |
| Total fix cycle | 5-30s (typical) |

## Security Considerations

1. **No credential storage** - All auth via OpenCode
2. **Audit trail** - All fixes logged with timestamps
3. **Conservative defaults** - Asks before anything risky
4. **Clear communication** - Users see exactly what's happening
5. **Safe ownership** - Igor runs as current user (or sudo when needed)
6. **No privilege escalation** - User controls when sudo is used

## Extensibility

### Adding Diagnostics

```bash
# In lib/diagnostics.sh
diagnose_myservice() {
    echo "=== My Service Status ==="
    systemctl status myservice --no-pager
    # ... more checks
}
```

### Adding Fixes

```bash
# In lib/fixer.sh
fix_myservice() {
    local issue="$1"
    echo "Fixing myservice: $issue"
    # ... fix logic
}
```

### Adding to Learning

```bash
# In any script
learn_system_info "PostgreSQL installed at /usr/lib/postgresql"
```

## Future Enhancements

1. **Multi-system support** - SSH into remote servers
2. **Health monitoring** - Continuous checking, alerts
3. **Predictive fixes** - "Your /var is 80% full, will be full in 3 days"
4. **Package management** - Smart dependency resolution
5. **Config backup** - Auto-backup before changes
6. **Team knowledge base** - Share system knowledge across team
7. **Metrics export** - Prometheus-compatible metrics
8. **Agent selection** - Auto-choose agent based on task

## Testing Approach

Core functionality tested:
- Diagnostic functions execute without errors
- Session management (creation, persistence)
- Memory read/write operations
- Config parsing with fallbacks
- Command-line argument routing
- Help and version output

Real-world testing:
- Run `igor --diagnose health` on live system
- Check memory with `igor --memory`
- Try actual fixes on test system
- Verify logs in `~/.igor/memory/issues/fixed.log`

## Comparison to Alternatives

| Feature | Igor | Manual | Ansible | Puppet |
|---------|------|--------|---------|--------|
| Natural language | ✓ | ✗ | ✗ | ✗ |
| Interactive | ✓ | ✓ | ✓ | ✗ |
| One-liner | ✓ | ✗ | ✓ | ✗ |
| Learning | ✓ | ✗ | ✗ | ✗ |
| Local focus | ✓ | ✓ | ✗ | ✗ |
| Zero config | ✓ | ✓ | ✗ | ✗ |
| Instant feedback | ✓ | ✓ | ✗ | ✗ |

Igor is designed for **interactive, single-system, ad-hoc administration with learning**.
