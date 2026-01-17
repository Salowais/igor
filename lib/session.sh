#!/usr/bin/env bash
# Session management - maps projects to OpenCode sessions

set -euo pipefail

# Get the project root (git repo root or current directory)
get_project_root() {
    local cwd="${1:-.}"
    if git -C "$cwd" rev-parse --show-toplevel &>/dev/null; then
        git -C "$cwd" rev-parse --show-toplevel
    else
        cd "$cwd" && pwd
    fi
}

# Hash a path to get a unique project identifier
hash_project() {
    local path="$1"
    echo -n "$path" | md5sum | cut -d' ' -f1
}

# Get session file path for a project
get_session_file() {
    local project_root="$1"
    local project_hash=$(hash_project "$project_root")
    echo "${IGOR_HOME}/sessions/${project_hash}"
}

# Check if a session file exists and is still valid
is_session_valid() {
    local session_file="$1"
    local timeout_hours=$(source "${IGOR_HOME}/lib/config.sh" && get_session_timeout_hours)
    
    if [[ ! -f "$session_file" ]]; then
        return 1
    fi
    
    # Check if file is older than timeout
    local file_age_seconds=$(($(date +%s) - $(stat -c %Y "$session_file" 2>/dev/null || echo 0)))
    local timeout_seconds=$((timeout_hours * 3600))
    
    [[ $file_age_seconds -lt $timeout_seconds ]]
}

# Get or create session for a project
# Returns: session_id
# Sets: IGOR_SESSION_ID, IGOR_SESSION_CONTINUE
get_or_create_session() {
    local project_root="$1"
    local force_new="${2:-false}"
    
    mkdir -p "${IGOR_HOME}/sessions"
    
    local session_file=$(get_session_file "$project_root")
    
    if [[ "$force_new" == "true" ]]; then
        # Force new session
        rm -f "$session_file"
        export IGOR_SESSION_ID=""
        export IGOR_SESSION_CONTINUE="false"
        return 0
    fi
    
    if is_session_valid "$session_file"; then
        # Reuse existing session
        local session_id=$(cat "$session_file")
        export IGOR_SESSION_ID="$session_id"
        export IGOR_SESSION_CONTINUE="true"
        return 0
    else
        # Start new session
        rm -f "$session_file"
        export IGOR_SESSION_ID=""
        export IGOR_SESSION_CONTINUE="false"
        return 0
    fi
}

# Save session ID after running opencode
save_session_id() {
    local project_root="$1"
    local session_id="$2"
    
    local session_file=$(get_session_file "$project_root")
    mkdir -p "$(dirname "$session_file")"
    echo "$session_id" > "$session_file"
}

# Extract session ID from opencode output
# The output format from opencode run has session ID in it
extract_session_id_from_output() {
    local output="$1"
    # Look for patterns like "Session ID: ses_xxxxx" or similar
    echo "$output" | grep -oP 'ses_[a-zA-Z0-9]+' | head -1 || echo ""
}

# Clear session for current project (start fresh next time)
clear_session() {
    local project_root="$1"
    local session_file=$(get_session_file "$project_root")
    rm -f "$session_file"
}

# List all active sessions with their projects
list_sessions() {
    local sessions_dir="${IGOR_HOME}/sessions"
    
    if [[ ! -d "$sessions_dir" ]]; then
        echo "No sessions yet."
        return 0
    fi
    
    echo "Active Sessions:"
    echo "==============="
    
    for session_file in "$sessions_dir"/*; do
        if [[ -f "$session_file" ]]; then
            local session_id=$(cat "$session_file")
            local hash=$(basename "$session_file")
            local modified=$(date -r "$session_file" '+%Y-%m-%d %H:%M:%S')
            echo "  ID: $session_id"
            echo "  Modified: $modified"
            echo ""
        fi
    done
}
