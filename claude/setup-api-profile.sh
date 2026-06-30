#!/usr/bin/env bash
# Set up a secondary Claude Code config dir that shares config with the primary
# ~/.claude but keeps auth and runtime state separate, so multiple
# logins / orgs / billing methods can coexist (and run concurrently).
#
# Default target ~/.claude-api (API billing); pass a dir for other profiles.
#   Usage: ~/.claude/setup-api-profile.sh [target_dir]
#   Then:  claude-api / claude-personal   (functions in terminal/aliases.sh)

set -e

CLAUDE_DIR="$HOME/.claude"
PROFILE_DIR="${1:-$HOME/.claude-api}"

# Config and state to share between profiles.
# Everything else (sessions, caches, auth, telemetry) stays per-profile.
SHARED=(
  CLAUDE.md
  settings.json
  settings.local.json
  statusline.sh
  commands
  hooks
  skills
  plugins
  projects
  history.jsonl
)

echo "🔧 Setting up $PROFILE_DIR"

mkdir -p "$PROFILE_DIR"

for entry in "${SHARED[@]}"; do
  src="$CLAUDE_DIR/$entry"
  dst="$PROFILE_DIR/$entry"

  # Skip if source doesn't exist yet (e.g. settings.local.json before first override)
  if [[ ! -e "$src" && ! -L "$src" ]]; then
    continue
  fi

  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "  ✓ $entry"
  else
    ln -sf "$src" "$dst"
    echo "  🔗 $entry"
  fi
done

echo "✅ $PROFILE_DIR ready"
