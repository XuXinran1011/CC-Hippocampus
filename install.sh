#!/bin/bash
# CC-Hippocampus - One-Click Installation from GitHub
# Usage: curl -fsSL https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main/install.sh | bash
# Or: bash <(curl -fsSL https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main/install.sh)

set -e

echo "╔════════════════════════════════════════════════════════╗"
echo "║     CC-Hippocampus - One-Click Installation          ║"
echo "║         (No git clone required!)                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get Claude Code configuration directory
CLAUDE_DIR="${HOME}/.claude"
PLUGINS_DIR="${CLAUDE_DIR}/plugins"
SKILLS_DIR="${CLAUDE_DIR}/skills"
HOOKS_DIR="${CLAUDE_DIR}/hooks"
TEMP_DIR=$(mktemp -d)

# GitHub raw URL
GITHUB_RAW="https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main"

cleanup() {
  rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

echo -e "${BLUE}[1/5]${NC} Creating directories..."
mkdir -p "${CLAUDE_DIR}" 2>/dev/null || true
mkdir -p "${PLUGINS_DIR}" 2>/dev/null || true
mkdir -p "${SKILLS_DIR}" 2>/dev/null || true
mkdir -p "${HOOKS_DIR}" 2>/dev/null || true
echo -e "${GREEN}  ✓ Directories ready${NC}"
echo ""

# Download plugin files
echo -e "${BLUE}[2/5]${NC} Downloading plugin from GitHub..."
PLUGIN_NAME="CC-Hippocampus"
PLUGIN_DEST="${PLUGINS_DIR}/${PLUGIN_NAME}"

# Check if running in pipe mode (non-interactive)
IS_PIPE=false
[ -t 0 ] || IS_PIPE=true

if [ -d "${PLUGIN_DEST}" ]; then
    echo -e "${YELLOW}  ⚠ Plugin already installed at: ${PLUGIN_DEST}${NC}"

    if [ "$IS_PIPE" = true ]; then
        echo "   Running in non-interactive mode. Skipping overwrite."
        echo "   Use: bash <(curl -fsSL https://raw.githubusercontent.com/XuXinran1011/CC-Hippocampus/main/install.sh) --force"
        exit 0
    fi

    read -p "   Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "   Installation cancelled."
        exit 1
    fi
    rm -rf "${PLUGIN_DEST}"
fi

mkdir -p "${PLUGIN_DEST}/tools"
mkdir -p "${PLUGIN_DEST}/rules"

# Download core files
curl -fsSL "${GITHUB_RAW}/tools/hippocampus.py" -o "${PLUGIN_DEST}/tools/hippocampus.py"
curl -fsSL "${GITHUB_RAW}/rules/hippocampus_policy.md" -o "${PLUGIN_DEST}/rules/hippocampus_policy.md"

echo -e "${GREEN}  ✓ Plugin installed to: ${PLUGIN_DEST}${NC}"
echo ""

# Download skills
echo -e "${BLUE}[3/5]${NC} Downloading skills..."
SKILLS_DEST="${SKILLS_DIR}/hippocampus"
rm -rf "${SKILLS_DEST}" 2>/dev/null || true
mkdir -p "${SKILLS_DEST}"

curl -fsSL "${GITHUB_RAW}/skills/hippocampus/SKILL.md" -o "${SKILLS_DEST}/SKILL.md"
curl -fsSL "${GITHUB_RAW}/skills/hippocampus/load.js" -o "${SKILLS_DEST}/load.js"
curl -fsSL "${GITHUB_RAW}/skills/hippocampus/save.js" -o "${SKILLS_DEST}/save.js"
curl -fsSL "${GITHUB_RAW}/skills/hippocampus/clear.js" -o "${SKILLS_DEST}/clear.js"
curl -fsSL "${GITHUB_RAW}/skills/hippocampus/stats.js" -o "${SKILLS_DEST}/stats.js"

echo -e "${GREEN}  ✓ Skills installed to: ${SKILLS_DEST}${NC}"
echo ""

# Setup hook
echo -e "${BLUE}[4/5]${NC} Setting up automatic hook..."
curl -fsSL "${GITHUB_RAW}/hooks/post-session-start.js" -o "${HOOKS_DIR}/post-session-start.js"
echo -e "${GREEN}  ✓ Hook created: ${HOOKS_DIR}/post-session-start.js${NC}"
echo ""

# Verify Python
echo -e "${BLUE}[5/5]${NC} Verifying Python installation..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d ' ' -f 2)
    echo -e "${GREEN}  ✓ Python 3 found: ${PYTHON_VERSION}${NC}"
    echo -e "${GREEN}  ✓ Python 3.7+ is required${NC}"
elif command -v python &> /dev/null; then
    PYTHON_VERSION=$(python --version 2>&1 | cut -d ' ' -f 2)
    echo -e "${GREEN}  ✓ Python found: ${PYTHON_VERSION}${NC}"
    echo -e "${GREEN}  ✓ Python 3.7+ is required${NC}"
else
    echo -e "${YELLOW}  ⚠ Python not found. Please install Python 3.7+${NC}"
    echo -e "${YELLOW}  The plugin will not work without Python.${NC}"
fi
echo ""

# Final summary
echo "╔════════════════════════════════════════════════════════╗"
echo "║              Installation Complete!                    ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo -e "${BLUE}📦 Installed:${NC}"
echo "  • Plugin: $PLUGIN_DEST"
echo "  • Skills: $SKILLS_DEST"
echo "  • Hook:   $HOOKS_DIR/post-session-start.js"
echo ""
echo -e "${BLUE}⚠️ Important Notes:${NC}"
echo "  • This installation does NOT modify your existing Claude Code settings"
echo "  • Only adds CC-Hippocampus plugin, skills, and one hook file"
echo "  • Your existing plugins and settings remain unchanged"
echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
echo "  1. Restart Claude Code to activate hooks"
echo "  2. Memory will auto-load on session start"
echo "  3. Use skills: /hippocampus-load, /hippocampus-save, etc."
echo ""
echo -e "${GREEN}🎉 Done! No git clone required.${NC}"
echo ""
