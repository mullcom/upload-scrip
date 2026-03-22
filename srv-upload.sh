#!/usr/bin/env bash

# start-upload.sh - TEMPORÄR UPLOAD-SERVER (drag & drop)
# Kör: ./start-upload.sh [port]   (default 8000)

set -euo pipefail
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

IP-lista (robust, ingen exit vid fel)
echo "Nätverks-IP:er (välj den telefonen når):"
ip -4 addr show scope global 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 | grep -v '^127.' | while read -r ip; do
echo "  http://\( {ip}: \){PORT}/upload"
done || echo "  (Kör 'ip addr show' för att se IP:er manuellt)"
echo
echo "→ Öppna länken, ange användarnamn + lösenord"
echo "→ Ladda upp fil (drag & drop OK)"
echo "→ När klar: Ctrl+C här"
echo "==========================================="

cd "$UPLOAD_DIR" || exit 1

if [ "$USE_AUTH" = true ]; then
    exec python3 -m uploadserver "\( {PORT}" --basic-auth " \){AUTH}"
else
    exec python3 -m uploadserver "${PORT}"
fi
EOF
