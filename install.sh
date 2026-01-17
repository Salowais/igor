#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)}"
if [[ ! -d "$REPO_DIR/lib" ]]; then
    REPO_DIR="$(mktemp -d)"
    curl -fsSL https://api.github.com/repos/Salowais/igor/tarball/master | tar xz -C "$REPO_DIR" --strip-components=1
fi
IGOR_HOME="${IGOR_HOME:-${HOME}/.igor}"
IGOR_BIN_DIR="${IGOR_HOME}/bin"

echo "Installing Igor..."
echo "  Home: $IGOR_HOME"
echo "  Bin: $IGOR_BIN_DIR"
echo ""

mkdir -p "$IGOR_BIN_DIR"
mkdir -p "${IGOR_HOME}/lib"
mkdir -p "${IGOR_HOME}/memory/system"
mkdir -p "${IGOR_HOME}/memory/issues"
mkdir -p "${IGOR_HOME}/sessions"
mkdir -p "${IGOR_HOME}/cache"

cp "$REPO_DIR/igor" "$IGOR_BIN_DIR/igor"
cp "$REPO_DIR/lib"/*.sh "$IGOR_HOME/lib/" 2>/dev/null || true
chmod +x "$IGOR_BIN_DIR/igor"

if [[ ! -f "${IGOR_HOME}/config.yaml" ]]; then
    cp "$REPO_DIR/examples/config.yaml" "${IGOR_HOME}/config.yaml" 2>/dev/null || \
        "$IGOR_BIN_DIR/igor" --init
fi

export IGOR_HOME

add_to_path() {
    local shell_rc="$1"
    
    if [[ ! -f "$shell_rc" ]]; then
        return 0
    fi
    
    if ! grep -q "IGOR_HOME" "$shell_rc"; then
        echo "" >> "$shell_rc"
        echo "# Igor CLI" >> "$shell_rc"
        echo "export IGOR_HOME=\"${IGOR_HOME}\"" >> "$shell_rc"
        echo "export PATH=\"\${IGOR_HOME}/bin:\$PATH\"" >> "$shell_rc"
        echo "Added Igor to $shell_rc"
    fi
}

add_to_path "${HOME}/.bashrc"
add_to_path "${HOME}/.zshrc"

echo ""
echo "✓ Igor installed successfully!"
echo ""
echo "Next steps:"
echo "  1. Run: source ${HOME}/.bashrc  (or .zshrc for zsh)"
echo "  2. Try: igor --help"
echo "  3. Try diagnostics: igor --diagnose health"
echo "  4. Describe a problem: igor my nginx won't start"
echo ""
echo "Example: igor my service is failing"
