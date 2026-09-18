# CKNE Live Console

A local web UI that pairs a **real terminal** (connected to your real
kubectl context) with the current scenario's instructions, side by side —
left panel shows context/objective/definition-of-done, right panel is an
actual shell, and a "Verify" button runs the scenario's real `verify.sh`
against your real cluster and shows you the result.

This is not a simulator: the terminal is your actual shell, and "Verify"
executes the actual script from `lab/`. It's a UI wrapper around the same
workflow described in [`../lab/README.md`](../lab/README.md), not a
replacement for it.

## ⚠️ Security — read this before running it

- Both the terminal (`ttyd`) and the API server bind to **127.0.0.1 only**.
  Never change that to `0.0.0.0`, never port-forward it, never put it behind
  a reverse proxy reachable from outside your machine. `ttyd --writable`
  gives anyone who can reach it a real, unauthenticated shell on your
  computer. Same for the API server: its `/api/setup` and `/api/verify`
  endpoints execute shell scripts on request.
- This is built for **solo local study use** — a personal convenience layer
  over commands you could type yourself. It has no authentication.

## Requirements

- `ttyd` (static binary, no root needed):
  ```bash
  curl -fsSL -o ~/.local/bin/ttyd \
    "https://github.com/tsl0922/ttyd/releases/latest/download/ttyd.x86_64"
  chmod +x ~/.local/bin/ttyd
  ```
- `node` (any reasonably recent version — no npm packages needed, the server
  only uses Node's built-in `http`/`fs`/`child_process` modules).
- A cluster already set up per [`../lab/00-setup/README.md`](../lab/00-setup/README.md),
  with `kubectl` pointed at it.

## Usage

```bash
./start.sh
# open http://127.0.0.1:7680
```

- Pick a scenario from the dropdown at the top.
- The left panel shows its context, objective, and definition-of-done
  checklist (parsed straight from that scenario's `README.md` — same source
  of truth as the lab itself).
- The right panel is a real terminal. Run the scenario's `setup.sh` there (or
  click the "Run setup.sh" button, which does the same thing server-side and
  shows you the output), then diagnose and fix it using real `kubectl`/
  `cilium`/`hubble` commands, exactly like you would without this UI.
- Click **Verify** when you think you're done — it runs the real `verify.sh`
  and shows PASS/FAIL with its output.

Press `Ctrl+C` in the terminal where you ran `start.sh` to stop both the
shell server and the API server.

## How it works

- `server.js`: a dependency-free Node HTTP server. `GET /api/scenarios`
  scans `lab/*/*/README.md` and parses out the title and the Context/
  Objective/Definition-of-done sections. `POST /api/setup` and
  `POST /api/verify` run that scenario's `setup.sh`/`verify.sh` and return
  the output as JSON.
- `public/index.html`: the two-pane UI. The terminal pane is just an
  `<iframe>` pointing at `ttyd`, which is a separate process serving a real
  PTY over WebSocket — the browser has no special shell access, `ttyd`
  provides all of it.
- `start.sh`: launches both processes and cleans them up on Ctrl+C.
