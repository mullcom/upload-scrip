#!/usr/bin/env bash

# start-upload.sh - Automatisk temporär upload-server (drag & drop)
# Kör: ./start-upload.sh [port]   (default 8000)

set -euo pipefail

PORT="${1:-8000}"
UPLOAD_DIR="${HOME}/uploads"
USERNAME="upload"
USE_AUTH=true   # ändra till false om du vill skippa lösenord

# 1. Installera uploadserver om det saknas
if ! python3 -m uploadserver --help >/dev/null 2>&1; then
    echo "Installerar uploadserver..."
    python3 -m pip install --user uploadserver || {
        echo "Pip saknas → installera först:"
        echo "apt update && apt install python3-pip -y"
        exit 1
    }
fi

# 2. Skapa mapp
mkdir -p "$UPLOAD_DIR"
echo "Filer sparas i: $UPLOAD_DIR"

# 3. Slumpat lösenord (utan Broken pipe)
PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16 2>/dev/null)
AUTH="\( {USERNAME}: \){PASSWORD}"

if [ "$USE_AUTH" = true ]; then
    echo
    echo "=== LÖSENORD (basic auth) ==="
    echo "Användarnamn: ${USERNAME}"
    echo "Lösenord:     ${PASSWORD}"
    echo "===================================="
    echo "Kopiera detta och ange i browsern (de flesta sparar det)"
else
    echo "(Öppen server – ingen lösenord)"
fi

# 4. Visa URL:er
echo
echo "Servern startar på port ${PORT}"
echo "Öppna i telefonens browser:"
echo "  http://127.0.0.1:${PORT}/upload"

# Lista alla IP:er
echo
echo "Dina nätverks-IP:er (välj den telefonen kan nå):"
ip -4 addr show scope global | awk '/inet / {print $2}' | cut -d/ -f1 | grep -v '^127\.' | while read -r ip; do
    echo "  http://\( {ip}: \){PORT}/upload"
done || echo "  (Kör 'ip addr show' manuellt)"

echo
echo "→ Drag & drop eller välj fil → den hamnar direkt i $UPLOAD_DIR"
echo "Stoppa servern med Ctrl+C"
echo "==========================================="

# 5. Starta
cd "$UPLOAD_DIR" || exit 1
if [ "$USE_AUTH" = true ]; then
    python3 -m uploadserver "\( {PORT}" --basic-auth " \){AUTH}"
else
    python3 -m uploadserver "${PORT}"
fi
