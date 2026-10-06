#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$PROJECT_DIR/.venv"
PYTHON="python3"

echo "================================"
echo "        NEXUS INSTALLER"
echo "================================"
echo

# Check Python
if ! command -v "$PYTHON" >/dev/null 2>&1; then
    echo "ERROR: python3 is not installed."
    exit 1
fi

echo "[1/5] Checking Python..."
"$PYTHON" --version

# Create virtual environment
if [ ! -d "$VENV_DIR" ]; then
    echo "[2/5] Creating virtual environment..."
    "$PYTHON" -m venv "$VENV_DIR"
else
    echo "[2/5] Virtual environment already exists."
fi

VENV_PYTHON="$VENV_DIR/bin/python"
VENV_PIP="$VENV_DIR/bin/pip"

# Install dependencies
echo "[3/5] Installing dependencies..."

if [ -f "$PROJECT_DIR/requirements.txt" ]; then
    "$VENV_PIP" install --upgrade pip
    "$VENV_PIP" install -r "$PROJECT_DIR/requirements.txt"
else
    echo "WARNING: requirements.txt not found."
fi

# Application launcher
echo "[4/5] Creating application launcher..."

APP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
mkdir -p "$APP_DIR"

APP_LAUNCHER="$APP_DIR/NEXUS.desktop"

cat > "$APP_LAUNCHER" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=NEXUS
Comment=Personal AI Assistant
Exec="$VENV_PYTHON" "$PROJECT_DIR/main.py"
Icon=$PROJECT_DIR/config/nexus.png
Terminal=false
Categories=Utility;
Path=$PROJECT_DIR
StartupNotify=true
EOF

chmod +x "$APP_LAUNCHER"

# Desktop shortcut
echo "[5/5] Creating desktop shortcut..."

DESKTOP_DIR="$HOME/Desktop"

if command -v xdg-user-dir >/dev/null 2>&1; then
    DETECTED_DESKTOP="$(xdg-user-dir DESKTOP 2>/dev/null || true)"

    if [ -n "$DETECTED_DESKTOP" ] && [ "$DETECTED_DESKTOP" != "undefined" ]; then
        DESKTOP_DIR="$DETECTED_DESKTOP"
    fi
fi

mkdir -p "$DESKTOP_DIR"

DESKTOP_LAUNCHER="$DESKTOP_DIR/NEXUS.desktop"

cp "$APP_LAUNCHER" "$DESKTOP_LAUNCHER"
chmod +x "$DESKTOP_LAUNCHER"

echo
echo "================================"
echo "       NEXUS INSTALLED"
echo "================================"
echo
echo "Project : $PROJECT_DIR"
echo "Python  : $VENV_PYTHON"
echo "Launcher: $APP_LAUNCHER"
echo "Desktop : $DESKTOP_LAUNCHER"
echo
echo "You can now launch NEXUS from:"
echo "  • Applications menu"
echo "  • Desktop shortcut"
echo
echo "To run manually:"
echo "  $VENV_PYTHON $PROJECT_DIR/main.py"
echo
