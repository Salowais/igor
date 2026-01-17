#!/usr/bin/env bash
# Config parsing for Igor
# Simple YAML parser for config.yaml

set -euo pipefail

# Get the config file path
get_config_file() {
    local config_file="${IGOR_CONFIG_FILE:-${IGOR_HOME}/config.yaml}"
    if [[ ! -f "$config_file" ]]; then
        # Return default config if file doesn't exist
        echo ""
        return 0
    fi
    echo "$config_file"
}

# Parse YAML config and return a value
# Usage: config_get "key.subkey" "default_value"
config_get() {
    local key="$1"
    local default="${2:-}"
    local config_file=$(get_config_file)
    
    if [[ -z "$config_file" || ! -f "$config_file" ]]; then
        echo "$default"
        return 0
    fi
    
    # Simple YAML parsing - handles flat and nested keys
    # key = "model" or "memory.enabled"
    local value=""
    
    if [[ "$key" == *"."* ]]; then
        # Nested key like "memory.enabled"
        local parent="${key%%.*}"
        local child="${key#*.}"
        
        # Find the parent section and extract child value
        local in_section=0
        while IFS= read -r line; do
            # Check if we're entering the section
            if [[ "$line" =~ ^[[:space:]]*${parent}: ]]; then
                in_section=1
                continue
            fi
            
            # Check if we're leaving the section (new root key)
            if [[ $in_section -eq 1 && "$line" =~ ^[a-z] ]]; then
                in_section=0
            fi
            
            # Extract the value if we're in the right section
            if [[ $in_section -eq 1 && "$line" =~ ^[[:space:]]*${child}:[[:space:]]*(.*)$ ]]; then
                value="${BASH_REMATCH[1]}"
                # Handle boolean values
                if [[ "$value" == "true" ]]; then
                    echo "true"
                elif [[ "$value" == "false" ]]; then
                    echo "false"
                else
                    # Remove quotes if present
                    echo "${value%\"}" | sed 's/^"//'
                fi
                return 0
            fi
        done < "$config_file"
    else
        # Root level key
        while IFS= read -r line; do
            if [[ "$line" =~ ^${key}:[[:space:]]*(.*)$ ]]; then
                value="${BASH_REMATCH[1]}"
                # Handle boolean values
                if [[ "$value" == "true" ]]; then
                    echo "true"
                elif [[ "$value" == "false" ]]; then
                    echo "false"
                else
                    # Remove quotes if present
                    echo "${value%\"}" | sed 's/^"//'
                fi
                return 0
            fi
        done < "$config_file"
    fi
    
    echo "$default"
}

# Initialize default config if it doesn't exist
init_default_config() {
    local config_file="${IGOR_HOME}/config.yaml"
    
    if [[ ! -f "$config_file" ]]; then
        mkdir -p "$(dirname "$config_file")"
        cat > "$config_file" << 'EOF'
# Igor Configuration

# Default model (optional, uses OpenCode default if not set)
# model: anthropic/claude-sonnet-4

# Agent to use
agent: build

# What requires confirmation (all true by default)
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
EOF
    fi
}

# Get confirmation setting
should_confirm() {
    local operation="$1"  # file_write, file_delete, git_operations, shell_commands, batch_operations
    local default="true"
    
    local result=$(config_get "confirm.${operation}" "$default")
    [[ "$result" == "true" ]]
}

# Check if memory is enabled
is_memory_enabled() {
    local result=$(config_get "memory.enabled" "true")
    [[ "$result" == "true" ]]
}

# Get session timeout in hours
get_session_timeout_hours() {
    config_get "session.timeout_hours" "24"
}

# Get default model
get_default_model() {
    config_get "model" ""
}

# Get default agent
get_default_agent() {
    config_get "agent" "build"
}

# Get max memory entries
get_max_memory_entries() {
    config_get "memory.max_entries" "50"
}
