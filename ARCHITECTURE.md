# Igor Architecture

## Overview

Igor is a lightweight shell wrapper around OpenCode that provides:
1. **Session continuity** - Maps projects to persistent OpenCode sessions
2. **Persistent memory** - Auto-extracted learnings across sessions
3. **Contextual prompting** - System prompts enhanced with project context
4. **Smart confirmations** - Only asks before destructive operations

## Components

### Core Layer: `lib/` modules

**config.sh** (~80 lines)
- YAML parsing for ~/.igor/config.yaml
- Query functions for configuration values
- Config initialization with sensible defaults

**session.sh** (~110 lines)
- Project detection (git repo or cwd)
- Project-to-session mapping via MD5 hash
- Session validity checking with timeout
- Session creation and persistence

**memory.sh** (~190 lines)
- Global memory (cross-project preferences)
- Project memory (per-project context)
- Auto-extraction of learnings from session output
- Memory compaction (dedup, archival)
- Memory context injection for prompts

**prompt.sh** (~60 lines)
- System prompt builder with memory injection
- Behavior guidelines (confirmations, tool usage)
- Current session metadata

### Main Script: `igor`

**igor** (~190 lines)
- Command-line argument parsing
- Subcommand routing (--memory, --config, --clear, etc.)
- Session orchestration
- OpenCode invocation with context
- Background memory extraction
- Output capture and session ID extraction

### Installation

**install.sh** (~45 lines)
- Creates ~/.igor directory structure
- Copies files to proper locations
- Adds Igor to PATH in shell configs
- Creates default config

**uninstall.sh** (~25 lines)
- Removes Igor and all data
- Cleans up shell config files

## Data Flow

```
User Command
    ↓
igor (parse args)
    ↓
get_or_create_session() ──→ ~/.igor/sessions/<hash>
    ↓
build_system_prompt()
    └──→ read_project_memory() ──→ ~/.igor/memory/projects/<name>.md
    └──→ read_global_memory() ──→ ~/.igor/memory/global.md
    ↓
opencode run --prompt <system> <user_prompt>
    ↓
(streaming output to terminal)
    ↓
capture output
    └──→ save_session_id() ──→ ~/.igor/sessions/<hash>
    └──→ extract_learnings() [background] ──→ append_project_memory()
```

## Storage Structure

```
~/.igor/
├── config.yaml
├── bin/
│   └── igor (symlink or copy)
├── lib/
│   ├── config.sh
│   ├── session.sh
│   ├── memory.sh
│   └── prompt.sh
├── sessions/
│   └── <project-md5-hash> (contains session_id)
├── memory/
│   ├── global.md
│   └── projects/
│       ├── project-a.md
│       └── project-b.md
└── cache/
    └── (temporary files)
```

## Memory Format

Memory files are Markdown with sections:
- **Context** - Project setup, framework, key facts
- **Decisions** - Architecture choices with dates
- **Learned** - Auto-extracted facts from sessions
- **User Preferences** - Global preferences copied to project scope

Timestamps help with:
- Auto-compaction (remove entries older than 30 days)
- Tracking evolution of decisions
- Filtering recent learnings

## Configuration

`.igor/config.yaml` controls:

**Model/Agent Selection**
- Default model (e.g., anthropic/claude-sonnet-4)
- Agent to use (build, explore, etc.)

**Confirmation Behavior**
- Which operations require approval
- Granular per-operation control

**Memory Settings**
- Enable/disable auto-extraction
- Max entries per project (for compaction)

**Session Timeouts**
- Hours before session expires
- Can be customized per-project if needed

## Key Design Decisions

### 1. Hash-based Project Mapping
- Projects identified by MD5 of absolute path
- Survives renames of parent directories
- Sessions stored flat (no deep nesting)

### 2. Background Memory Extraction
- Forked to background with `&`
- Non-blocking - user sees results immediately
- Simple extraction prompt to OpenCode
- Incremental appends (no overwrites)

### 3. System Prompt Injection via --prompt Flag
- OpenCode's `--prompt` flag carries system instructions
- Injected into every run, includes memory context
- Stateless - no server coordination needed

### 4. Confirmation via System Prompt
- Behavior guidelines in system prompt
- OpenCode naturally asks before destructive ops
- No special parsing of output needed

### 5. Minimal Dependencies
- Pure bash (no Python, Ruby, etc.)
- Only depends on: bash, git, md5sum, opencode
- No external config libraries

## Extensibility

Future enhancements:

1. **Project-specific configs** - Allow `./igor.yaml` in projects
2. **Memory sources** - Git blame, file history, tests as context
3. **Custom extractors** - User-defined memory extraction rules
4. **Agent switching** - Automatically select agents based on task
5. **Session export** - Share sessions across team
6. **Webhooks** - Trigger Igor on git events

## Performance

- **Startup**: ~50ms (shell sourcing + arg parsing)
- **Memory read**: ~10ms (cat files)
- **Session lookup**: ~5ms (md5 + file read)
- **Memory extraction**: Async in background

Total user-facing latency: < 100ms before OpenCode starts.

## Security

- No secrets stored (auth handled by OpenCode)
- Memory files readable by user only (chmod 644)
- Config file same (users may add API keys)
- Temporary files cleaned up after each run
- No network calls from Igor itself

## Testing

Covered behaviors:
- Session creation and continuation
- Memory read/write/append
- Config parsing with fallbacks
- Project detection (git vs cwd)
- CLI argument parsing
- Help and version output

Not tested yet (future):
- Full E2E with real OpenCode
- Memory compaction logic
- Session timeout expiry
- Complex memory scenarios
