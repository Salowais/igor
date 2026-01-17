#!/usr/bin/env bash

set -euo pipefail

IGOR_HOME="${IGOR_HOME:-${HOME}/.igor}"
IGOR_BIN_DIR="${IGOR_HOME}/bin"
IGOR_LIB_DIR="${IGOR_HOME}/lib"
REPO_URL="https://github.com/Salowais/igor"
BRANCH="master"

echo "Installing Igor from $REPO_URL..."
echo "  Home: $IGOR_HOME"
echo "  Bin: $IGOR_BIN_DIR"
echo ""

mkdir -p "$IGOR_BIN_DIR"
mkdir -p "$IGOR_LIB_DIR"
mkdir -p "${IGOR_HOME}/memory/system"
mkdir -p "${IGOR_HOME}/memory/issues"
mkdir -p "${IGOR_HOME}/sessions"
mkdir -p "${IGOR_HOME}/cache"

echo "Downloading Igor files..."

for file in igor; do
    curl -fsSL "https://raw.githubusercontent.com/Salowais/igor/${BRANCH}/${file}" -o "$IGOR_BIN_DIR/${file}"
    chmod +x "$IGOR_BIN_DIR/${file}"
done

for file in config.sh session.sh memory.sh prompt.sh diagnostics.sh fixer.sh; do
    curl -fsSL "https://raw.githubusercontent.com/Salowais/igor/${BRANCH}/lib/${file}" -o "$IGOR_LIB_DIR/${file}"
    chmod +x "$IGOR_LIB_DIR/${file}"
done

if [[ ! -f "${IGOR_HOME}/config.yaml" ]]; then
    curl -fsSL "https://raw.githubusercontent.com/Salowais/igor/${BRANCH}/examples/config.yaml" -o "${IGOR_HOME}/config.yaml"
fi

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
    fi
}

add_to_path "${HOME}/.bashrc"
add_to_path "${HOME}/.zshrc"
add_to_path "${HOME}/.kshrc"
add_to_path "${HOME}/.profile"

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
