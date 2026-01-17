# Igor Quick Start - Autonomous System Agent v1.0

Igor is like having a senior sysadmin in your terminal. Tell it what's wrong, and it diagnoses and fixes it.

## Install

```bash
git clone https://github.com/Salowais/igor.git && cd igor && bash install.sh
source ~/.bashrc
```

## Quick Examples

### Fix a Service That Won't Start

```bash
$ igor my nginx won't start

Igor will:
1. Check if nginx is installed
2. Check service status
3. Read error logs
4. Identify the problem (config error, port in use, etc)
5. Fix it
6. Verify it's running
```

### Fix Permission Issues

```bash
$ igor fix my .ssh permissions

Igor will:
1. Check .ssh directory and key files
2. Fix permissions to standard values (700 for dir, 600 for keys)
3. Verify SSH works
```

### Check System Health

```bash
$ igor diagnose health
# Shows disk, memory, CPU, services, errors

$ igor diagnose docker
# Checks Docker service, containers, images, issues

$ igor diagnose network
# Checks network connectivity, DNS, interfaces
```

### Understand Problems

```bash
$ igor why is docker service failing
# Igor analyzes logs and explains the root cause

$ igor my system is slow
# Igor profiles and shows resource issues

$ igor what services are failing
# Shows all non-running services and why
```

## Interaction Style

Igor:
- **Thinks out loud** - explains its reasoning
- **Asks before destructive ops** - deletes, config changes
- **Auto-fixes safe operations** - restarts services, fixes permissions
- **Learns over time** - remembers issues it's solved

## Commands

```bash
igor <natural language>         Main agent - diagnose and fix

# Diagnostics only (no fixes)
igor --diagnose health          System health
igor --diagnose services        Service status
igor --diagnose docker          Docker issues
igor --diagnose disk            Disk usage
igor --diagnose network         Network status
igor --diagnose logs            System logs

# Memory
igor --memory                   View learned knowledge
igor --memory edit              Edit knowledge manually
igor --clear-history            Clear fixed issues log

# Help
igor --help                     Show help
igor --version                  Show version
```

## Common Patterns

**Debug a failing service:**
```bash
$ igor my postgres won't connect
$ igor are the logs showing any hints
$ igor how do I restart the postgres service
```

**System audit:**
```bash
$ igor audit my system for issues
$ igor what should I fix first
$ igor --diagnose services
```

**Learn what Igor knows:**
```bash
$ igor --memory
```

**Run diagnostics only:**
```bash
$ igor --diagnose health      (don't fix, just show problems)
```

## What Gets Auto-Fixed

Igor doesn't ask before:
- Restarting failed services
- Fixing obvious permission issues (chmod 600 ~/.ssh/id_rsa)
- Updating package lists
- Viewing logs and diagnostics
- Enabling important services

Igor ALWAYS asks before:
- Deleting files
- Modifying critical configs (/etc/*, /root)
- Installing/removing packages
- Anything potentially destructive

## Tips

1. **Be specific** - "my docker service crashed" better than "things broken"
2. **Use diagnostics** - `igor --diagnose health` shows what's wrong
3. **Igor remembers** - Past issues and fixes are remembered
4. **Check logs** - `igor --diagnose logs` for recent errors
5. **Small asks** - "restart nginx" better than "fix everything"

## Troubleshooting

**Igor not found:**
```bash
source ~/.bashrc
```

**Permission denied:**
```bash
sudo igor fix my service
# Some system operations need sudo
```

**Want to see what Igor would do:**
```bash
igor --diagnose health   # Just show, don't fix
```

**Understand a service:**
```bash
igor tell me about postgres
igor what config does nginx use
```

## Next Steps

1. Try a simple diagnostic: `igor --diagnose health`
2. Describe a real problem: `igor my service won't start`
3. Check what Igor learned: `igor --memory`
4. Read full README for details: `cat README.md`

Enjoy! 🚀
