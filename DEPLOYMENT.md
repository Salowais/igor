# Igor v1.0 - Deployment & First Use

## Installation

### For Personal Use

```bash
# One-liner installation
curl -fsSL https://raw.githubusercontent.com/salowais/igor/master/install.sh | bash

# Then reload shell
source ~/.bashrc
```

### Manual Installation

```bash
git clone https://github.com/salowais/igor.git
cd igor
./install.sh
source ~/.bashrc
```

## Verification

```bash
# Check installation
$ igor --help
$ igor --version

# Test diagnostics
$ igor --diagnose health
```

## Your First Commands

### 1. System Health Check (Safe)

```bash
$ igor --diagnose health

# Shows:
# - Uptime and load
# - Memory usage
# - CPU load
# - Disk I/O
```

### 2. Check Services

```bash
$ igor --diagnose services

# Shows all running/failed services
```

### 3. Describe a Real Problem

```bash
$ igor my nginx server won't start

# Igor will:
# 1. Check service status
# 2. Read error logs
# 3. Diagnose the issue
# 4. Suggest a fix
# 5. Ask confirmation
# 6. Fix it (if approved)
# 7. Verify it works
```

### 4. Check What Igor Learned

```bash
$ igor --memory

# View system knowledge base
```

## Common First-Time Issues

### "igor command not found"

```bash
# Reload shell config
source ~/.bashrc

# Or check PATH
echo $PATH | grep .igor
```

### "Permission denied"

Some operations need sudo:

```bash
sudo igor fix my permissions
```

### "OpenCode not installed"

Igor requires OpenCode CLI:

```bash
# Check OpenCode
opencode --help

# Install if needed (follow OpenCode documentation)
```

## Recommended First Tasks

1. **Understand your system** 
   ```bash
   igor --diagnose health
   igor --diagnose services
   ```

2. **Fix a specific problem**
   ```bash
   igor my nginx won't start
   ```

3. **Check logs**
   ```bash
   igor --diagnose logs
   ```

4. **Learn what Igor knows**
   ```bash
   igor --memory
   ```

## Safety Checklist

- [ ] Installation successful (`igor --help` works)
- [ ] Diagnostics run without error (`igor --diagnose health` works)
- [ ] Understand confirmation levels (Igor shows what it will do)
- [ ] Read through examples in QUICKSTART.md
- [ ] Try a non-destructive operation first (`--diagnose`)

## Extending Igor

### Add Custom Knowledge

```bash
$ igor --memory edit

# Add knowledge about your systems:
# - Service locations
# - Custom configurations
# - Known issues and workarounds
```

### Add New Diagnostics

Edit `~/.igor/lib/diagnostics.sh`:

```bash
diagnose_myservice() {
    echo "=== My Service ==="
    systemctl status myservice --no-pager
    # Add more checks
}
```

Then use:
```bash
$ igor --diagnose myservice
```

## Troubleshooting

### Igor keeps asking before simple fixes

Check confirmation settings in `~/.igor/config.yaml`:

```yaml
confirm:
  file_write: false    # Don't ask for log writes
  shell_commands: false  # Don't ask for simple shell commands
```

### Igor doesn't remember issues

Enable memory in config:

```yaml
memory:
  enabled: true
  auto_update: true
```

View memory:
```bash
$ igor --memory
```

### Need to reset everything

```bash
# Clear session
$ igor --clear-history

# Or full reset
$ rm -rf ~/.igor/memory/
```

## Next Steps

1. Install Igor
2. Run `igor --diagnose health`
3. Try `igor --help` to see all options
4. Tackle a real system problem with `igor my issue description`
5. Check what it learned: `igor --memory`
6. Read ARCHITECTURE.md for deep technical details

## Support & Feedback

- Check README.md for full documentation
- Review ARCHITECTURE.md for technical details
- Edit QUICKSTART.md for common patterns
- Use `igor --help` for command reference

Good luck! 🚀
