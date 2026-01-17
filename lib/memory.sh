#!/usr/bin/env bash
# Memory system - persistent learning across sessions

set -euo pipefail

init_memory() {
    mkdir -p "${IGOR_HOME}/memory/system"
    mkdir -p "${IGOR_HOME}/memory/issues"
    mkdir -p "${IGOR_HOME}/cache"
}

# Get project memory file
get_project_memory_file() {
    local project_name="$1"
    echo "${IGOR_HOME}/memory/projects/${project_name}.md"
}

# Get global memory file
get_global_memory_file() {
    echo "${IGOR_HOME}/memory/global.md"
}

# Read global memory
read_global_memory() {
    local mem_file=$(get_global_memory_file)
    if [[ -f "$mem_file" ]]; then
        cat "$mem_file"
    else
        echo ""
    fi
}

# Read project memory
read_project_memory() {
    local project_name="$1"
    local mem_file=$(get_project_memory_file "$project_name")
    if [[ -f "$mem_file" ]]; then
        cat "$mem_file"
    else
        echo ""
    fi
}

# Initialize project memory file if it doesn't exist
init_project_memory() {
    local project_name="$1"
    local project_path="$2"
    
    local mem_file=$(get_project_memory_file "$project_name")
    
    if [[ ! -f "$mem_file" ]]; then
        cat > "$mem_file" << EOF
# Project: $project_name
# Path: $project_path

## Context
(Auto-populated from codebase)

## Decisions

## Learned (auto-extracted)

## User Preferences (from global memory)
EOF
    fi
}

# Append to project memory
append_project_memory() {
    local project_name="$1"
    local content="$2"
    
    init_memory
    init_project_memory "$project_name" "."
    
    local mem_file=$(get_project_memory_file "$project_name")
    echo "" >> "$mem_file"
    echo "$content" >> "$mem_file"
}

# Append to global memory
append_global_memory() {
    local content="$1"
    
    init_memory
    
    local mem_file=$(get_global_memory_file)
    if [[ ! -f "$mem_file" ]]; then
        echo "# Global Igor Memory" > "$mem_file"
        echo "" >> "$mem_file"
    fi
    
    echo "" >> "$mem_file"
    echo "$content" >> "$mem_file"
}

# Extract learnings from session output using opencode
# This is the "memory extraction" pass
extract_learnings() {
    local session_output="$1"
    local project_name="$2"
    
    # Check if memory is enabled
    source "${IGOR_HOME}/lib/config.sh"
    if ! is_memory_enabled; then
        return 0
    fi
    
    # Call opencode to extract learnings
    # This runs in background, non-blocking
    (
        local extraction_prompt="Analyze this session output and extract 2-3 key learnings or facts worth remembering about the project.
Return ONLY the bullet points in this format:
- <learning>

If nothing notable, return nothing.

Session output:
---
$session_output
---"
        
        local learnings=$(opencode run --prompt "You are a memory extraction system." "$extraction_prompt" 2>/dev/null || echo "")
        
        if [[ -n "$learnings" ]] && [[ "$learnings" != *"nothing notable"* ]]; then
            local timestamp=$(date '+%Y-%m-%d')
            local formatted="## Learned (auto-extracted)
$learnings"
            
            append_project_memory "$project_name" "$formatted"
        fi
    ) &
}

# Compact memory (remove duplicates, old entries)
compact_memory() {
    local project_name="$1"
    
    source "${IGOR_HOME}/lib/config.sh"
    local max_entries=$(get_max_memory_entries)
    
    local mem_file=$(get_project_memory_file "$project_name")
    if [[ ! -f "$mem_file" ]]; then
        return 0
    fi
    
    # Use opencode to compact the memory file
    (
        local compaction_prompt="Review this project memory file and:
1. Remove duplicate entries
2. Merge related items
3. Remove outdated information (older than 30 days)
4. Keep max $max_entries items
5. Preserve all sections (Context, Decisions, Learned)

Return the cleaned markdown file, preserving the original format.

Memory file:
---
$(cat "$mem_file")
---"
        
        local compacted=$(opencode run --prompt "You are a memory compaction system." "$compaction_prompt" 2>/dev/null || echo "")
        
        if [[ -n "$compacted" ]]; then
            echo "$compacted" > "$mem_file"
        fi
    ) &
}

# Show memory
show_memory() {
    local scope="${1:-project}"
    local project_name="${2:-}"
    
    if [[ -z "$project_name" ]]; then
        project_name=$(basename "$(pwd)")
    fi
    
    if [[ "$scope" == "global" ]]; then
        echo "=== Global Memory ==="
        read_global_memory || echo "(empty)"
    elif [[ "$scope" == "project" ]]; then
        echo "=== Project: $project_name ==="
        read_project_memory "$project_name" || echo "(empty)"
    elif [[ "$scope" == "all" ]]; then
        echo "=== Global Memory ==="
        read_global_memory || echo "(empty)"
        echo ""
        echo "=== Project Memory ==="
        for mem_file in "${IGOR_HOME}/memory/projects"/*.md; do
            if [[ -f "$mem_file" ]]; then
                echo ""
                cat "$mem_file"
            fi
        done
    fi
}

# Edit memory in $EDITOR
edit_memory() {
    local scope="${1:-project}"
    local project_name="${2:-}"
    
    if [[ -z "$project_name" ]]; then
        project_name=$(basename "$(pwd)")
    fi
    
    local mem_file=""
    
    if [[ "$scope" == "global" ]]; then
        mem_file=$(get_global_memory_file)
    elif [[ "$scope" == "project" ]]; then
        mem_file=$(get_project_memory_file "$project_name")
        init_project_memory "$project_name" "."
    fi
    
    if [[ -z "$mem_file" ]]; then
        echo "Could not determine memory file"
        return 1
    fi
    
    ${EDITOR:-nano} "$mem_file"
}

# Get context string for system prompt (memory summary)
get_memory_context() {
    local project_name="$1"
    
    local global_mem=$(read_global_memory)
    local project_mem=$(read_project_memory "$project_name")
    
    local context=""
    
    if [[ -n "$global_mem" ]]; then
        context+="## Global Preferences & Learnings
$global_mem

"
    fi
    
    if [[ -n "$project_mem" ]]; then
        context+="## Project Memory
$project_mem"
    fi
    
    echo "$context"
}
