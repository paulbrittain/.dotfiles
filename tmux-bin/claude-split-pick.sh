#!/usr/bin/env bash
set -euo pipefail

# Interactive picker for claude-split db profiles.
# Meant to be run inside a tmux display-popup so fzf has a tty.

CREDS_FILE="${CLAUDE_SPLIT_CREDS_FILE:-$HOME/.tmux-db-creds.json}"
JQ="${JQ:-jq}"

if ! command -v "$JQ" &>/dev/null; then
  echo "Error: jq is required. Install with: brew install jq" >&2
  exit 1
fi

if ! command -v fzf &>/dev/null; then
  echo "Error: fzf is required. Install with: brew install fzf" >&2
  exit 1
fi

if [[ ! -f "$CREDS_FILE" ]]; then
  echo "Error: credentials file not found: $CREDS_FILE" >&2
  exit 1
fi

conn=$("$JQ" -r 'keys[]' "$CREDS_FILE" | fzf --prompt="db creds> " --height=100% --no-multi) || exit 0
[[ -z "$conn" ]] && exit 0

# Run in the pane under the popup (the popup is not a real pane).
tmux run-shell "$HOME/bin/claude-split '$conn'"
