#!/usr/bin/env bash
# Autonomous fix execution with smart confirmation levels

set -euo pipefail

fix_permissions() {
    local path="$1"
    local mode="${2:-755}"
    local recursive="${3:-false}"
    
    if [[ ! -e "$path" ]]; then
        echo "Path not found: $path"
        return 1
    fi
    
    if [[ "$recursive" == "true" ]]; then
        echo "Fixing permissions recursively: $path (mode: $mode)"
        chmod -R "$mode" "$path"
    else
        echo "Fixing permissions: $path (mode: $mode)"
        chmod "$mode" "$path"
    fi
    
    learn_fix "Fixed permissions on $path to $mode"
}

fix_service() {
    local service="$1"
    local action="${2:-restart}"
    
    case "$action" in
        restart|start|stop|reload|enable|disable)
            echo "Running: systemctl $action $service"
            systemctl "$action" "$service"
            learn_fix "Fixed service $service with action: $action"
            ;;
        *)
            echo "Unknown action: $action"
            return 1
            ;;
    esac
}

fix_disk_space() {
    echo "Analyzing disk usage for cleanup opportunities..."
    
    local cache_dirs=(
        "/var/cache/apt"
        "/var/cache/yum"
        "/tmp"
        "~/.cache"
    )
    
    local total_freed=0
    
    for dir in "${cache_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "0")
            echo "  $dir: $size"
        fi
    done
    
    echo ""
    echo "To free disk space (non-destructive):"
    echo "  - apt-get clean && apt-get autoclean"
    echo "  - journalctl --vacuum=30d"
    echo "  - rm -rf ~/.cache/*"
}

fix_package_updates() {
    echo "Checking for package updates..."
    
    if command -v apt &>/dev/null; then
        echo "Running apt update..."
        apt-get update
        echo ""
        echo "Available updates:"
        apt list --upgradable
        echo ""
        echo "To apply: apt-get upgrade (requires confirmation)"
    elif command -v yum &>/dev/null; then
        echo "Checking yum updates..."
        yum check-update || true
    fi
}

fix_docker_issues() {
    if ! command -v docker &>/dev/null; then
        echo "Docker not installed"
        return 1
    fi
    
    echo "Analyzing Docker issues..."
    
    echo ""
    echo "Containers in error state:"
    docker ps -a --filter "status=exited" --format "{{.Names}}: {{.Status}}" 2>/dev/null || echo "None"
    
    echo ""
    echo "Dangling images (unused):"
    docker images -f "dangling=true" --format "{{.ID}}: {{.Size}}" 2>/dev/null || echo "None"
    
    echo ""
    echo "Available fixes:"
    echo "  - docker restart <container>    (restart stopped container)"
    echo "  - docker system prune            (remove unused resources)"
    echo "  - docker logs <container>        (view container logs)"
}

fix_network_issues() {
    echo "Analyzing network issues..."
    
    echo ""
    echo "Testing connectivity:"
    ping -c 3 -W 2 8.8.8.8 2>/dev/null && echo "Internet: OK" || echo "Internet: FAILED"
    
    echo ""
    echo "DNS test:"
    nslookup google.com 2>/dev/null | grep -A2 "Non-authoritative" || echo "DNS resolution: FAILED"
    
    echo ""
    echo "Available fixes:"
    echo "  - systemctl restart networking"
    echo "  - systemctl restart systemd-resolved"
    echo "  - dhclient -r && dhclient (get new DHCP lease)"
}

fix_memory_pressure() {
    echo "Analyzing memory usage..."
    
    echo ""
    free -h
    
    echo ""
    echo "Top memory consumers:"
    ps aux --sort=-%mem | head -5
    
    echo ""
    echo "Available fixes:"
    echo "  - sync; echo 3 > /proc/sys/vm/drop_caches  (drop caches)"
    echo "  - kill <pid>  (stop memory-heavy process)"
    echo "  - Add swap space if available"
}

execute_fix() {
    local fix_type="$1"
    shift
    local args=("$@")
    
    case "$fix_type" in
        permissions)
            fix_permissions "${args[@]}"
            ;;
        service)
            fix_service "${args[@]}"
            ;;
        disk-space)
            fix_disk_space
            ;;
        updates)
            fix_package_updates
            ;;
        docker)
            fix_docker_issues
            ;;
        network)
            fix_network_issues
            ;;
        memory)
            fix_memory_pressure
            ;;
        *)
            echo "Unknown fix type: $fix_type"
            return 1
            ;;
    esac
}

learn_fix() {
    local fix_description="$1"
    local issues_log="${IGOR_HOME}/memory/issues/fixed.log"
    
    mkdir -p "$(dirname "$issues_log")"
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $fix_description" >> "$issues_log"
}

suggest_fixes() {
    local issue="$1"
    
    case "$issue" in
        *permission*)
            echo "Suggested fix: fix_permissions <path> <mode>"
            ;;
        *service*|*daemon*)
            echo "Suggested fix: fix_service <name> restart|start|stop"
            ;;
        *disk*|*space*)
            echo "Suggested fix: fix_disk_space"
            ;;
        *update*)
            echo "Suggested fix: fix_package_updates"
            ;;
        *docker*)
            echo "Suggested fix: fix_docker_issues"
            ;;
        *network*|*connection*)
            echo "Suggested fix: fix_network_issues"
            ;;
        *memory*)
            echo "Suggested fix: fix_memory_pressure"
            ;;
        *)
            echo "Unable to suggest fix for: $issue"
            ;;
    esac
}
