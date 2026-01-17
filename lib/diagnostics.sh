#!/usr/bin/env bash
# System diagnostics - gather information about system state

set -euo pipefail

diagnose_services() {
    local service_name="${1:-}"
    
    if [[ -n "$service_name" ]]; then
        echo "=== Service: $service_name ==="
        systemctl is-active "$service_name" 2>/dev/null && echo "Status: RUNNING" || echo "Status: STOPPED/FAILED"
        systemctl is-enabled "$service_name" 2>/dev/null && echo "Enabled: YES" || echo "Enabled: NO"
        echo ""
        echo "Recent logs:"
        journalctl -u "$service_name" -n 20 --no-pager 2>/dev/null || echo "(No logs available)"
        return 0
    fi
    
    echo "=== System Services ==="
    systemctl list-units --type=service --state=running --all --no-pager 2>/dev/null | head -20
}

diagnose_disk() {
    echo "=== Disk Usage ==="
    df -h | head -10
    echo ""
    echo "=== Large Directories ==="
    du -sh /* 2>/dev/null | sort -rh | head -10
}

diagnose_permissions() {
    local path="${1:-.}"
    
    if [[ ! -e "$path" ]]; then
        echo "Path not found: $path"
        return 1
    fi
    
    echo "=== Permissions: $path ==="
    ls -ld "$path"
    echo ""
    
    if [[ -d "$path" ]]; then
        echo "Contents:"
        ls -la "$path" 2>/dev/null | head -20
    fi
}

diagnose_network() {
    echo "=== Network Status ==="
    if command -v ip &>/dev/null; then
        echo "Interfaces:"
        ip link show | grep -E '^\d+:|^[a-z]' | head -10
    fi
    
    echo ""
    echo "DNS:"
    cat /etc/resolv.conf 2>/dev/null | grep nameserver | head -5 || echo "Could not read DNS config"
    
    echo ""
    echo "Connectivity:"
    ping -c 1 -W 1 8.8.8.8 &>/dev/null && echo "Internet: YES" || echo "Internet: NO"
}

diagnose_processes() {
    local process_name="${1:-}"
    
    if [[ -n "$process_name" ]]; then
        echo "=== Processes matching: $process_name ==="
        ps aux | grep "$process_name" | grep -v grep || echo "No matching processes"
        return 0
    fi
    
    echo "=== Top Processes (CPU) ==="
    ps aux --sort=-%cpu | head -10
    
    echo ""
    echo "=== Top Processes (Memory) ==="
    ps aux --sort=-%mem | head -10
}

diagnose_logs() {
    local service="${1:-}"
    
    if [[ -n "$service" ]]; then
        echo "=== Recent logs for: $service ==="
        journalctl -u "$service" -n 50 --no-pager 2>/dev/null || tail -50 "/var/log/$service.log" 2>/dev/null || echo "No logs found"
        return 0
    fi
    
    echo "=== System Logs (Last 20 lines) ==="
    journalctl -n 20 --no-pager 2>/dev/null || tail -20 /var/log/syslog 2>/dev/null || echo "Could not read logs"
    
    echo ""
    echo "=== Errors in Recent Logs ==="
    journalctl -n 100 --no-pager 2>/dev/null | grep -i "error\|fail\|warn" | tail -10 || echo "No errors found"
}

diagnose_package_manager() {
    echo "=== Package Manager ==="
    
    if command -v apt &>/dev/null; then
        echo "System: Debian/Ubuntu"
        echo "Pending updates:"
        apt list --upgradable 2>/dev/null | wc -l
        echo ""
        echo "Recently installed:"
        dpkg -l | tail -10
    elif command -v yum &>/dev/null; then
        echo "System: RedHat/CentOS"
        echo "Pending updates:"
        yum check-update 2>/dev/null | wc -l || echo "Unknown"
    elif command -v pacman &>/dev/null; then
        echo "System: Arch"
        echo "Pending updates:"
        pacman -Qu 2>/dev/null | wc -l || echo "Unknown"
    else
        echo "Unknown package manager"
    fi
}

diagnose_docker() {
    if ! command -v docker &>/dev/null; then
        echo "Docker not installed"
        return 1
    fi
    
    echo "=== Docker Status ==="
    docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}" 2>/dev/null || echo "Docker daemon not running or permission denied"
    
    echo ""
    echo "=== Docker Volumes ==="
    docker volume ls 2>/dev/null || echo "Could not list volumes"
    
    echo ""
    echo "=== Docker Images ==="
    docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}" 2>/dev/null | head -10 || echo "Could not list images"
}

diagnose_system_health() {
    echo "=== System Health Check ==="
    
    echo ""
    echo "Uptime:"
    uptime
    
    echo ""
    echo "Memory:"
    free -h | head -2
    
    echo ""
    echo "CPU Load:"
    cat /proc/loadavg 2>/dev/null
    
    echo ""
    echo "Disk I/O (last minute):"
    iostat -x 1 2 2>/dev/null | tail -5 || echo "iostat not available"
}

diagnose_common_issues() {
    local issue_type="${1:-general}"
    
    case "$issue_type" in
        ssh)
            echo "=== SSH Issues ==="
            echo "SSH service status:"
            systemctl status ssh --no-pager 2>/dev/null || systemctl status sshd --no-pager 2>/dev/null
            echo ""
            echo "SSH config:"
            head -20 /etc/ssh/sshd_config 2>/dev/null
            ;;
        postgres)
            echo "=== PostgreSQL Issues ==="
            systemctl status postgresql --no-pager 2>/dev/null || echo "PostgreSQL service not found"
            echo ""
            echo "Connection test:"
            psql -U postgres -c "SELECT version();" 2>/dev/null || echo "Could not connect to PostgreSQL"
            ;;
        nginx|apache)
            echo "=== Web Server Issues ==="
            systemctl status "$issue_type" --no-pager 2>/dev/null
            echo ""
            echo "Config test:"
            if [[ "$issue_type" == "nginx" ]]; then
                nginx -t 2>&1 || true
            else
                apachectl configtest 2>&1 || true
            fi
            ;;
        *)
            echo "=== General System Diagnostics ==="
            diagnose_system_health
            ;;
    esac
}

get_system_knowledge() {
    local knowledge_file="${IGOR_HOME}/memory/system/knowledge.md"
    
    if [[ -f "$knowledge_file" ]]; then
        cat "$knowledge_file"
    else
        echo ""
    fi
}

learn_system_info() {
    local info="$1"
    local knowledge_file="${IGOR_HOME}/memory/system/knowledge.md"
    
    mkdir -p "$(dirname "$knowledge_file")"
    
    if [[ ! -f "$knowledge_file" ]]; then
        cat > "$knowledge_file" << 'EOF'
# System Knowledge Base

## Installed Services

## Configuration Locations

## Common Issues

## Fixed Issues

EOF
    fi
    
    echo "" >> "$knowledge_file"
    echo "- $info" >> "$knowledge_file"
}
