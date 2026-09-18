#!/usr/bin/env bash
# Starts a real bash terminal (via ttyd) and the console API server, both
# bound to 127.0.0.1 only. Requires `ttyd` and `node` on your PATH.
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v ttyd >/dev/null 2>&1; then
  echo "ttyd not found. Install the static binary (no root needed):"
  echo '  curl -fsSL -o ~/.local/bin/ttyd \'
  echo '    "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64"'
  echo '  chmod +x ~/.local/bin/ttyd'
  exit 1
fi
if ! command -v node >/dev/null 2>&1; then
  echo "node not found — install Node.js to run the console API server."
  exit 1
fi

echo "Starting real terminal on 127.0.0.1:7681 (bash, your current kubectl context)..."
ttyd --interface 127.0.0.1 --port 7681 --writable bash &
TTYD_PID=$!

echo "Starting console API server on 127.0.0.1:7680..."
node server.js &
SERVER_PID=$!

cleanup() {
  echo ""
  echo "Stopping..."
  kill "$TTYD_PID" "$SERVER_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo ""
echo "Open http://127.0.0.1:7680 in your browser."
echo "Left: current scenario's context/objective/definition of done."
echo "Right: a REAL terminal in this shell, with your real kubectl context."
echo "Press Ctrl+C here to stop both."
echo ""

wait
