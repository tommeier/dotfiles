#!/usr/bin/env bash
# Set up ~/.claude-api as a secondary Claude Code config for API billing.
#
# Shares config, plugins, projects, and history with the primary ~/.claude
# directory but keeps auth and runtime state separate so both billing
# methods can coexist.
#
# Usage: ~/.claude/setup-api-profile.sh
# Then:  claude-api  (function defined in terminal/aliases.sh)

set -e

CLAUDE_DIR="$HOME/.claude"
API_DIR="$HOME/.claude-api"

# Config and state to share between both profiles.
# Everything else (sessions, caches, auth, telemetry) stays per-profile.
SHARED=(
  CLAUDE.md
  settings.json
  settings.local.json
  statusline.sh
  hooks
  skills
  plugins
  projects
  history.jsonl
)

echo "🔧 Setting up ~/.claude-api"

mkdir -p "$API_DIR"

for entry in "${SHARED[@]}"; do
  src="$CLAUDE_DIR/$entry"
  dst="$API_DIR/$entry"

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

echo "✅ ~/.claude-api ready"
