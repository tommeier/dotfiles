#!/bin/sh
# Claude Code status line — optimized for speed and readability
#
# Layout: repo/path   branch|state ↑↓+~?   worktree   session   Model:agent   Subscription|API   ctx:N%   5h: N%  7d: N%   VIM
#
# Performance: 1 jq call + 3 git calls (rev-parse check, status, rev-parse dirs)
# vs ~14 external calls in naive approach. Segments omitted when empty.
# Colors signal urgency: dim (ok) → yellow (attention) → red (critical)

input=$(cat)

# ── Colors ──────────────────────────────────────────────────────────────────
R='\033[31m' G='\033[32m' Y='\033[33m' C='\033[36m' M='\033[35m'
D='\033[2m' Z='\033[0m'
S='   '

# ── Parse all JSON fields in a single jq invocation ────────────────────────
eval "$(echo "$input" | jq -r '
  "cwd="       + (.cwd // "" | @sh),
  "model="     + ((.model.display_name // .model.id // "") | @sh),
  "agent="     + ((.agent.name // "") | @sh),
  "ctx_pct="   + ((.context_window.used_percentage // "" | tostring) | @sh),
  "five_pct="  + ((.rate_limits.five_hour.used_percentage // "" | tostring) | @sh),
  "seven_pct=" + ((.rate_limits.seven_day.used_percentage // "" | tostring) | @sh),
  "cost_usd="  + ((.cost.total_cost_usd // "" | tostring) | @sh),
  "vim_mode="  + ((.vim.mode // "") | @sh),
  "session="   + ((.session_name // "") | @sh)
' 2>/dev/null)" 2>/dev/null
: "${cwd:=$(pwd)}"

# ── Directory + Git ────────────────────────────────────────────────────────
seg_dir="" seg_git="" seg_wt=""

if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # Branch + file status in one call
  _gs=$(git -C "$cwd" -c gc.auto=0 status --porcelain=v2 --branch 2>/dev/null)

  # git-dir and toplevel in one call
  _gd="" _top=""
  { read -r _gd; read -r _top; } <<EOF
$(git -C "$cwd" -c gc.auto=0 rev-parse --git-dir --show-toplevel 2>/dev/null)
EOF

  # Repo-relative directory: "xmo/apps/backend" instead of "~/src/.../xmo/apps/backend"
  if [ -n "$_top" ]; then
    _repo=$(basename "$_top")
    _rel="${cwd#"$_top"}"
    if [ -n "$_rel" ]; then
      seg_dir="📁 ${_repo}${D}${_rel}${Z}"
    else
      seg_dir="📁 ${_repo}"
    fi
  else
    short="${cwd#"$HOME"}"; [ "$short" != "$cwd" ] && short="~${short}"
    seg_dir="📁 ${D}${short}${Z}"
  fi

  # Branch
  branch=$(printf '%s\n' "$_gs" | sed -n 's/^# branch\.head //p')
  [ "$branch" = "(detached)" ] && \
    branch=$(git -C "$cwd" -c gc.auto=0 describe --tags --exact-match HEAD 2>/dev/null \
          || git -C "$cwd" -c gc.auto=0 rev-parse --short HEAD 2>/dev/null)

  # Ahead/behind from "# branch.ab +N -M"
  _ab=$(printf '%s\n' "$_gs" | sed -n 's/^# branch\.ab //p')
  ahead=0 behind=0
  if [ -n "$_ab" ]; then
    ahead=${_ab##+}; ahead=${ahead%% *}
    behind=${_ab##* -}
  fi

  # File counts from porcelain v2 entries
  staged=$(printf '%s\n' "$_gs" | grep -c '^[12] [MADRC]')
  unstaged=$(printf '%s\n' "$_gs" | grep -c '^[12] .[MADRC]')
  untracked=$(printf '%s\n' "$_gs" | grep -c '^?')

  # Merge / rebase state
  state=""
  [ -f "${_gd}/MERGE_HEAD" ] && state="|merge"
  { [ -d "${_gd}/rebase-merge" ] || [ -d "${_gd}/rebase-apply" ]; } && state="|rebase"

  # Indicators: ↑2 ↓1 +3 !2 ?1  (spaced for readability)
  ind=""
  [ "$ahead"     -gt 0 ] 2>/dev/null && ind="${ind}↑${ahead} "
  [ "$behind"    -gt 0 ] 2>/dev/null && ind="${ind}↓${behind} "
  [ "$staged"    -gt 0 ] 2>/dev/null && ind="${ind}+${staged} "
  [ "$unstaged"  -gt 0 ] 2>/dev/null && ind="${ind}!${unstaged} "
  [ "$untracked" -gt 0 ] 2>/dev/null && ind="${ind}?${untracked} "
  ind="${ind% }"  # trim trailing space

  # Green when clean, yellow when dirty
  { [ -n "$ind" ] || [ -n "$state" ]; } && _bc="$Y" || _bc="$G"
  seg_git="${_bc}${branch}${state}${Z}"
  [ -n "$ind" ] && seg_git="${seg_git} ${D}${ind}${Z}"

  # Worktree name (linked worktrees have git-dir at .git/worktrees/<name>)
  case "$_gd" in
    */worktrees/*)
      seg_wt="${Y}$(basename "$_gd")${Z}"
      ;;
  esac
else
  # Not in a git repo — home-abbreviated path
  short="${cwd#"$HOME"}"
  [ "$short" != "$cwd" ] && short="~${short}"
  seg_dir="📁 ${D}${short}${Z}"
fi

# ── Session name (shown when /rename'd) ────────────────────────────────────
seg_session=""
[ -n "$session" ] && seg_session="${D}${session}${Z}"

# ── Model (abbreviated) + agent ────────────────────────────────────────────
seg_model=""
_m="${model#Claude }"
_m="${_m% (*}"               # Strip context window suffix: "Opus 4.6 (1M context)" → "Opus 4.6"
if [ -n "$_m" ]; then
  seg_model="🤖 ${C}${_m}${Z}"
  [ -n "$agent" ] && seg_model="${seg_model}${D}:${agent}${Z}"
fi

# ── Context window fill ────────────────────────────────────────────────────
seg_ctx=""
if [ -n "$ctx_pct" ]; then
  _pi=$(printf '%.0f' "$ctx_pct" 2>/dev/null)
  if   [ "$_pi" -gt 90 ] 2>/dev/null; then _cc="$R"
  elif [ "$_pi" -gt 70 ] 2>/dev/null; then _cc="$Y"
  else _cc="$D"; fi
  seg_ctx="${_cc}ctx: ${_pi}%${Z}"
fi

# ── Billing mode (detect from config dir, available immediately) ───────────
seg_billing=""
case "$CLAUDE_CONFIG_DIR" in
  *-api*) seg_billing="${M}API${Z}" ;;
  *)      seg_billing="${M}Subscription${Z}" ;;
esac

# ── Rate limits (subscription) or session cost (API) ───────────────────────
seg_rl=""
if [ -n "$five_pct" ] || [ -n "$seven_pct" ]; then
  if [ -n "$five_pct" ]; then
    _v=$(printf '%.0f' "$five_pct" 2>/dev/null)
    if   [ "$_v" -gt 90 ] 2>/dev/null; then _c="$R"
    elif [ "$_v" -gt 70 ] 2>/dev/null; then _c="$Y"
    else _c="$D"; fi
    seg_rl="${_c}5h: ${_v}%${Z}"
  fi
  if [ -n "$seven_pct" ]; then
    _v=$(printf '%.0f' "$seven_pct" 2>/dev/null)
    if   [ "$_v" -gt 90 ] 2>/dev/null; then _c="$R"
    elif [ "$_v" -gt 70 ] 2>/dev/null; then _c="$Y"
    else _c="$D"; fi
    [ -n "$seg_rl" ] && seg_rl="${seg_rl}  "
    seg_rl="${seg_rl}${_c}7d: ${_v}%${Z}"
  fi
elif [ -n "$cost_usd" ]; then
  seg_rl="${D}\$$(printf '%.2f' "$cost_usd" 2>/dev/null)${Z}"
fi

# ── Vim mode ───────────────────────────────────────────────────────────────
seg_vim=""
[ -n "$vim_mode" ] && seg_vim="${M}${vim_mode}${Z}"

# ── Assemble ───────────────────────────────────────────────────────────────
out=""
for s in "$seg_dir" "$seg_git" "$seg_wt" "$seg_session" "$seg_model" "$seg_billing" "$seg_ctx" "$seg_rl" "$seg_vim"; do
  [ -n "$s" ] && out="${out:+${out}${S}}${s}"
done
printf '%b' "$out"
