#!/usr/bin/env bash

# start-upload.sh - TEMPORÄR UPLOAD-SERVER (drag & drop)
# Kör: ./start-upload.sh [port]   (default 8000)

PORT="${1:-8000}"
UPLOAD_DIR="${HOME}/uploads"
USERNAME="upload"
USE_AUTH=true

# Installera uploadserver om det saknas
if ! python3 -m uploadserver --help >/dev/null 2>&1; then
    echo "Installerar uploadserver..."
    python3 -m pip install --user uploadserver || {
        echo "Pip saknas → kör: apt update && apt install python3-pip -y"
        exit 1
    }
fi

mkdir -p "$UPLOAD_DIR"
echo "Filer sparas i: $UPLOAD_DIR"

# Lösenord (ingen broken pipe)
PASSWORD=$(LC_ALL=C tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 16 2>/dev/null)
AUTH="\( {USERNAME}: \){PASSWORD}"

if [ "$USE_AUTH" = true ]; then
    echo
    echo "=== LÖSENORD (basic auth) ==="
    echo "Användarnamn: ${USERNAME}"
    echo "Lösenord:     ${PASSWORD}"
    echo "===================================="
fi

echo
echo "SERVER STARTAD på port ${PORT}"
echo "Öppna i telefonens browser NU:"

echo "  http://127.0.0.1:${PORT}/upload"

# Fixad IP-detektering (tvingar aldrig exit)
IPS=$(ip -4 addr show scope global 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | grep -v '^127\.' || true)
if [ -n "$IPS" ]; then
    echo "$IPS" | while read -r ip; do
        echo "  http://\( {ip}: \){PORT}/upload"
    done
else
    echo "  (Kolla manuellt med: ip addr show)"
fi

echo
echo "→ Öppna länken på telefonen, ange användarnamn + lösenord"
echo "→ Ladda upp filen (drag & drop fungerar)"
echo "→ När klar: Ctrl+C här i terminalen"
echo "==========================================="

cd "$UPLOAD_DIR" || exit 1

if [ "$USE_AUTH" = false ]; then
    exec python3 -m uploadserver "\({PORT}" --basic-auth " \){AUTH}"
else
    exec python3 -m uploadserver "${PORT}"
fi
