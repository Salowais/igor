#!/usr/bin/env bash
set -euo pipefail

IGOR_HOME="${IGOR_HOME:-${HOME}/.igor}"

read -p "Are you sure you want to uninstall Igor? This will remove all Igor files. (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Uninstall cancelled."
    exit 0
fi

echo "Uninstalling Igor..."

rm -rf "$IGOR_HOME"

remove_from_rc() {
    local shell_rc="$1"
    
    if [[ ! -f "$shell_rc" ]]; then
        return 0
    fi
    
    if grep -q "IGOR_HOME" "$shell_rc"; then
        sed -i.bak '/# Igor CLI/,/export PATH.*IGOR_HOME/d' "$shell_rc"
        rm -f "${shell_rc}.bak"
        echo "Removed Igor from $shell_rc"
    fi
}

remove_from_rc "${HOME}/.bashrc"
remove_from_rc "${HOME}/.zshrc"

echo "✓ Igor uninstalled successfully!"
