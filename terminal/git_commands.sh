##########################
# GPG Signing Setup      #
##########################

# Auto-detect GPG signing key if not set
# Call this during shell init or manually to fix GPG signing issues
setup_gpg_signing_key() {
  # Skip if gpg is not installed
  command -v gpg >/dev/null 2>&1 || {
    echo "⚠️  gpg is not installed. Install GnuPG to configure signing."
    return 1
  }

  # Skip if already set and valid
  if [[ -n "$GPG_SIGNING_KEY" ]]; then
    if gpg --list-secret-keys "$GPG_SIGNING_KEY" &>/dev/null; then
      return 0
    fi
  fi

  # Find available secret keys
  local keys=($(gpg --list-secret-keys --keyid-format LONG 2>/dev/null | grep -E "^sec" | sed -E 's/.*\/([A-Fa-f0-9]+).*/\1/'))

  if [[ ${#keys[@]} -eq 0 ]]; then
    echo "⚠️  No GPG keys found. Run 'gpg --gen-key' to create one."
    return 1
  elif [[ ${#keys[@]} -eq 1 ]]; then
    export GPG_SIGNING_KEY="${keys[0]}"
    _save_gpg_key_to_localrc "${keys[0]}"
  else
    echo "Multiple GPG keys found. Select one:"
    local i=1
    for key in "${keys[@]}"; do
      local uid=$(gpg --list-secret-keys "$key" 2>/dev/null | grep -E "^uid" | head -1 | sed 's/uid\s*\[.*\]\s*//')
      echo "  $i) $key - $uid"
      ((i++))
    done
    printf "Choice [1]: "
    read -r choice
    choice=${choice:-1}
    if [[ $choice -ge 1 && $choice -le ${#keys[@]} ]]; then
      export GPG_SIGNING_KEY="${keys[$((choice-1))]}"
      _save_gpg_key_to_localrc "${keys[$((choice-1))]}"
    else
      echo "Invalid choice"
      return 1
    fi
  fi
}

_save_gpg_key_to_localrc() {
  local key="$1"
  # Use .localrc for machine-specific settings (not tracked in git)
  local localrc="$HOME/.localrc"

  # Create file if it doesn't exist with secure permissions
  if [[ ! -f "$localrc" ]]; then
    touch "$localrc"
    chmod 600 "$localrc"
  fi

  # Remove any existing GPG_SIGNING_KEY line and add new one
  if grep -q "^export GPG_SIGNING_KEY=" "$localrc" 2>/dev/null; then
    sed -i '' "s/^export GPG_SIGNING_KEY=.*/export GPG_SIGNING_KEY=\"$key\"/" "$localrc"
    echo "✅ Updated GPG_SIGNING_KEY in ~/.localrc"
  else
    echo "export GPG_SIGNING_KEY=\"$key\"" >> "$localrc"
    echo "✅ Added GPG_SIGNING_KEY to ~/.localrc"
  fi

  echo "ℹ️  Run 'REPLACE_ALL=true rake install' in your dotfiles to regenerate gitconfig"
}

# Check if GPG signing is properly configured (for shell startup)
check_gpg_signing() {
  # Skip silently if gpg is not installed
  command -v gpg >/dev/null 2>&1 || return 0

  local signing_key
  signing_key=$(git config --global user.signingkey 2>/dev/null)

  if [[ -z "$signing_key" ]]; then
    echo "⚠️  Git GPG signing key not configured. Run 'setup_gpg_signing_key' to fix."
    return 1
  fi

  if ! gpg --list-secret-keys "$signing_key" &>/dev/null; then
    echo "⚠️  Git signing key '$signing_key' not found in GPG. Run 'setup_gpg_signing_key' to fix."
    return 1
  fi

  return 0
}

##########################
#Git Helpers
alias sup="startup"
alias remote_sup="startup 'remove_remote_branches'"

git_default_branch() {
  # git remote set-head origin main
  git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

# Populate global associative array _PATCH_ID_CACHE with patch-ids from the
# last N (default 500) non-merge commits on $1 (target). One batched
# `git log -p | git patch-id` call — fast. Used by classify_merge() for O(1)
# squash-merge detection. Tune via SUP_PATCH_ID_WINDOW.
_sup_build_patch_id_cache() {
  local target="$1"
  local window="${SUP_PATCH_ID_WINDOW:-500}"
  typeset -gA _PATCH_ID_CACHE=() 2>/dev/null || return 1
  _PATCH_ID_CACHE_BUILT=1

  local pid sha
  while read -r pid sha; do
    [[ -n "$pid" ]] && _PATCH_ID_CACHE[$pid]="$sha"
  done < <(git log -p --format=medium --no-merges -n "$window" "$target" 2>/dev/null \
          | git patch-id --stable 2>/dev/null)
}

_sup_clear_patch_id_cache() {
  unset _PATCH_ID_CACHE _PATCH_ID_CACHE_BUILT
}

# Classify how $1 (branch) is merged into $2 (target):
#   prints "ancestor" → regular merge / fast-forward / rebase
#   prints "squash"   → patch-id match on a commit in target
# Returns 0 when merged, 1 otherwise (silent).
#
# Uses _PATCH_ID_CACHE for fast lookups when populated by
# _sup_build_patch_id_cache; otherwise walks target commits on demand.
classify_merge() {
  local branch="$1"
  local target="$2"

  if git merge-base --is-ancestor "$branch" "$target" 2>/dev/null; then
    echo ancestor
    return 0
  fi

  local merge_base branch_sha
  merge_base=$(git merge-base "$branch" "$target" 2>/dev/null) || return 1
  branch_sha=$(git rev-parse --verify --quiet "$branch") || return 1
  [[ -z "$merge_base" ]] && return 1
  if [[ "$merge_base" == "$branch_sha" ]]; then
    echo ancestor
    return 0
  fi

  local branch_pid
  branch_pid=$(git diff "$merge_base" "$branch_sha" 2>/dev/null \
              | git patch-id --stable 2>/dev/null | awk '{print $1}')
  [[ -z "$branch_pid" ]] && return 1

  if [[ -n "${_PATCH_ID_CACHE_BUILT:-}" ]]; then
    if [[ -n "${_PATCH_ID_CACHE[$branch_pid]:-}" ]]; then
      echo squash
      return 0
    fi
    return 1
  fi

  local c c_pid
  while IFS= read -r c; do
    c_pid=$(git show --format= "$c" 2>/dev/null \
           | git patch-id --stable 2>/dev/null | awk '{print $1}')
    if [[ "$c_pid" == "$branch_pid" ]]; then
      echo squash
      return 0
    fi
  done < <(git rev-list "$merge_base".."$target" 2>/dev/null)

  return 1
}

# Delete any passed branch name except protected or occupied.
# Handles `git branch --merged` output prefixes:
#   '  foo' (plain), '* foo' (current), '+ foo' (in another worktree)
delete_local_branch() {
  local raw="$1"
  local name
  name=$(printf '%s' "$raw" | sed -E 's/^[*+[:space:]]+//')

  case "$name" in
    ""|master|main|production)
      [[ -n "$name" ]] && echo "- [skipped] $name"
      return
      ;;
  esac

  case "$raw" in
    \+*) echo "- [skipped worktree-occupied] $name"; return ;;
    \**) echo "- [skipped current] $name"; return ;;
  esac

  git branch -D -q "$name"
  echo "x [deleted] $name"
}

reset_submodules() {
  git submodule foreach --recursive git clean -fdqx
  git submodule foreach --recursive git reset --hard
}

case_sensitive_git_rename() {
  original="$1"
  temp="$original.2"
  new="$2"
  git mv -f "$original" "$temp"
  git mv -f "$temp" "$new"
}

# TODO : Broken scenario:
# - Open PR exists in branch 'candidate-extras', branches off 'candidate/4.0.3'
# - 'candidate/4.0.3' has been merged into default branch (main/master)
# - 'candidate/4.0.3' is auto deleted, github then auto closes the open PR for that branch.
# --> Fix? Check if any open PRs exist that branch off non-default branch (main/master) branch that has been merged. If so -> ignore or ask for info.
delete_merged_remote_branches() {
#TODO : Collect all refs to delete and do one push to specific remote. (git push origin x1 x2 x3 --delete)
#     : This would require a multidimensional array
local remotes="";
for remote in $(git remote); do
  remotes="$remote|$remotes"
done
remotes="${remotes%?}"

git branch -r --merged | while read merged_branch; do
  local regex="($remotes)\/(.*)$"

  if [[ $merged_branch =~ $regex ]]; then
    local full_match=$BASH_REMATCH;
    local remote_name="${BASH_REMATCH[1]}";
    local branch_name="${BASH_REMATCH[2]}";
    local default_branch="$(git_default_branch)";

    if [[ $branch_name = "$default_branch" || $branch_name = 'production' ||  $branch_name = 'HEAD' ]]; then
      echo "- [skipped] ${remote_name}/${branch_name}";
    else
      local git_head_descriptor="^HEAD -> (.*)$"
      # Ignore the HEAD descriptor for git
      #eg: HEAD -> origin/master|main
      if [[ ! $branch_name =~ $git_head_descriptor ]]; then

        if [ -z "$DEBUG" ]; then
          # git push $remote_name "${remote_name}/${branch_name}" --delete
          git push $remote_name "${branch_name}" --delete
        else
          echo "[DISABLED] Would have deleted ${remote_name}/${branch_name} (DELETE_MERGED_REMOTE_BRANCHES=set to remove)"
        fi;
      fi;
    fi;
  else
    echo "Error: I don't know how to handle this branch: '${merged_branch}'"
  fi;
done
}

# Remove any worktrees whose branch has been merged (ancestor or squash) into
# $1 (default branch). Skips the current worktree, the default branch itself,
# 'production', and any dirty worktrees. Deletes the branch after successful
# removal. Honors SUP_DRY_RUN.
delete_merged_worktrees() {
  local default_branch="$1"
  local current_toplevel
  current_toplevel=$(git rev-parse --show-toplevel 2>/dev/null)

  # Branches whose worktrees this function removes (or would remove in dry-run).
  # delete_merged_branches() skips these to avoid redundant "skipped" output.
  typeset -gA _SUP_HANDLED_BRANCHES=() 2>/dev/null || :

  local wt="" branch="" bare=0
  local worktrees=()
  while IFS= read -r line; do
    case "$line" in
      "worktree "*) wt="${line#worktree }"; branch=""; bare=0 ;;
      "bare") bare=1 ;;
      "branch refs/heads/"*) branch="${line#branch refs/heads/}" ;;
      "")
        if [[ -n "$wt" && $bare -eq 0 && -n "$branch" ]]; then
          worktrees+=("${wt}|${branch}")
        fi
        wt=""; branch=""; bare=0
        ;;
    esac
  done < <(git worktree list --porcelain)
  if [[ -n "$wt" && $bare -eq 0 && -n "$branch" ]]; then
    worktrees+=("${wt}|${branch}")
  fi

  local verb
  if [[ -n "$SUP_DRY_RUN" ]]; then verb="would remove"; else verb="removed"; fi

  local entry wt_path wt_branch wt_status kind
  for entry in "${worktrees[@]}"; do
    wt_path="${entry%%|*}"
    wt_branch="${entry##*|}"

    if [[ "$wt_branch" == "$default_branch" || "$wt_branch" == "production" ]]; then
      continue
    fi
    if [[ "$wt_path" == "$current_toplevel" ]]; then
      echo "  - [skipped current worktree] ${wt_path} (${wt_branch})"
      continue
    fi
    if ! kind=$(classify_merge "$wt_branch" "$default_branch"); then
      continue
    fi
    if ! wt_status=$(git -C "$wt_path" status --porcelain 2>/dev/null); then
      echo "  ! [inaccessible] ${wt_path} (${wt_branch})"
      continue
    fi
    if [[ -n "$wt_status" ]]; then
      echo "  - [skipped dirty] ${wt_path} (${wt_branch} [${kind}])"
      continue
    fi

    _SUP_HANDLED_BRANCHES[$wt_branch]=1
    if [[ -n "$SUP_DRY_RUN" ]]; then
      echo "  x [${verb}] ${wt_path} (${wt_branch} [${kind}])"
      _SUP_WT_REMOVED=$((${_SUP_WT_REMOVED:-0} + 1))
    elif git worktree remove "$wt_path" 2>/dev/null; then
      git branch -D -q "$wt_branch" 2>/dev/null
      echo "  x [${verb}] ${wt_path} (${wt_branch} [${kind}])"
      _SUP_WT_REMOVED=$((${_SUP_WT_REMOVED:-0} + 1))
    else
      echo "  ! [failed to remove] ${wt_path} (${wt_branch})"
    fi
  done
}

# Delete local branches merged (ancestor or squash) into $1. Skips: protected
# names (main/master/production), the current branch, and any branch checked
# out in any worktree. Honors SUP_DRY_RUN.
delete_merged_branches() {
  local default_branch="$1"
  local current_branch
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)

  local occupied
  occupied=$(git worktree list --porcelain | awk '/^branch refs\/heads\// { print substr($0, 19) }')

  local verb
  if [[ -n "$SUP_DRY_RUN" ]]; then verb="would delete"; else verb="deleted"; fi

  local br kind
  while IFS= read -r br; do
    case "$br" in
      ""|master|main|production)
        [[ -n "$br" ]] && echo "  - [skipped protected] $br"
        continue
        ;;
    esac
    if [[ "$br" == "$current_branch" ]]; then
      echo "  - [skipped current] $br"
      continue
    fi
    # Already removed via delete_merged_worktrees in this run — silent.
    if [[ -n "${_SUP_HANDLED_BRANCHES[$br]:-}" ]]; then
      continue
    fi
    # Unmerged branches — silent.
    if ! kind=$(classify_merge "$br" "$default_branch"); then
      continue
    fi
    # Merged but stuck in a kept worktree (dirty/inaccessible) — surface this.
    if printf '%s\n' "$occupied" | grep -qxF "$br"; then
      echo "  - [skipped worktree-occupied] $br (${kind})"
      continue
    fi

    [[ -z "$SUP_DRY_RUN" ]] && git branch -D -q "$br"
    echo "  x [${verb}] $br (${kind})"
    _SUP_BR_DELETED=$((${_SUP_BR_DELETED:-0} + 1))
  done < <(git for-each-ref refs/heads/ --format='%(refname:short)')
}

startup() {
  local remove_remote_branches=false
  local default_branch="$(git_default_branch)"
  if [[ "${1}" == "remove_remote_branches" ]]; then
    remove_remote_branches=true
  fi

  if [[ -z "$default_branch" ]]; then
    echo "! Cannot determine default branch (no origin/HEAD). Aborting."
    return 1
  fi

  [[ -n "$SUP_DRY_RUN" ]] && echo "==> DRY RUN — no destructive actions will be taken"

  for remote in $(git remote); do
    echo "==> ($remote) Fetching & pruning remote refs"
    git fetch "$remote" --prune --tags --force
  done

  if [[ "$remove_remote_branches" == true ]]; then
    echo "==> Removing any merged remote branches"
    delete_merged_remote_branches
  fi

  echo "==> Pruning stale worktree admin data"
  [[ -z "$SUP_DRY_RUN" ]] && git worktree prune

  echo "==> Updating ${default_branch}"
  local current_branch main_wt tracking remote_ref
  current_branch=$(git symbolic-ref --short HEAD 2>/dev/null)
  tracking=$(git rev-parse --abbrev-ref "${default_branch}@{upstream}" 2>/dev/null)
  remote_ref="refs/remotes/${tracking:-origin/$default_branch}"

  if [[ "$current_branch" == "$default_branch" ]]; then
    git pull --ff-only
  elif ! git rev-parse --verify --quiet "$remote_ref" >/dev/null 2>&1; then
    echo "  (${remote_ref#refs/remotes/} not found — skipping update)"
  else
    main_wt=$(git worktree list --porcelain | awk -v b="refs/heads/$default_branch" '
      /^worktree / { wt = substr($0, 10) }
      $0 == "branch " b { print wt; exit }
    ')
    if [[ -n "$main_wt" ]]; then
      git -C "$main_wt" merge --ff-only "$remote_ref"
    else
      local local_sha remote_sha
      local_sha=$(git rev-parse --verify --quiet "refs/heads/$default_branch" 2>/dev/null)
      remote_sha=$(git rev-parse "$remote_ref")
      if [[ -z "$local_sha" ]] || git merge-base --is-ancestor "$local_sha" "$remote_sha" 2>/dev/null; then
        git update-ref -m "sup: fast-forward to ${remote_ref#refs/remotes/}" \
          "refs/heads/$default_branch" "$remote_sha"
        echo "  ${default_branch} → ${remote_sha:0:7}"
      else
        echo "  ⚠ local $default_branch has diverged from ${remote_ref#refs/remotes/} — not updating"
      fi
    fi
  fi

  _sup_build_patch_id_cache "$default_branch"
  _SUP_WT_REMOVED=0
  _SUP_BR_DELETED=0

  echo "==> Removing worktrees merged into ${default_branch}"
  delete_merged_worktrees "$default_branch"

  echo "==> Removing local branches merged into ${default_branch}"
  delete_merged_branches "$default_branch"

  _sup_clear_patch_id_cache
  unset _SUP_HANDLED_BRANCHES

  if [[ -e ".gitmodules" ]]; then
    echo "==> Updating git submodules"
    [[ -z "$SUP_DRY_RUN" ]] && git submodule update --init
  fi

  echo "==> Running git gc"
  [[ -z "$SUP_DRY_RUN" ]] && git gc --auto

  if [[ -n "$SUP_DRY_RUN" ]]; then
    echo "==> Summary (dry-run): would remove ${_SUP_WT_REMOVED} worktree(s), delete ${_SUP_BR_DELETED} branch(es)"
    echo "==> Re-run without SUP_DRY_RUN to apply"
  else
    echo "==> Summary: removed ${_SUP_WT_REMOVED} worktree(s), deleted ${_SUP_BR_DELETED} branch(es)"
  fi
}

git_commits_by_user() {
git log --pretty=format:%an | awk '{ ++c[$0]; } END { for(cc in c) printf "%5d %s\n",c[cc],cc; }'| sort -r
}

##########################
# Analysis               #
##########################
analyse_remote_branches() {
  local default_branch="$(git_default_branch)";
  printf "\n\n== Loading remote branches..\n"
  git gc --prune=now
  git remote prune origin
  git for-each-ref --shell --format="%(refname)" refs/remotes/origin | \

  while read branch
  do
    branch_name=${branch/refs\/remotes\/origin\//}
    printf "\nRemote Branch : ${branch_name}\n"
    result=`git log $default_branch..origin/${branch_name//\'/} --pretty=format:" -------> %h | %ar | %an | %s" --abbrev-commit --date-order --decorate -n 8`
    if [ "$result" == "" ]; then
      echo " <--> Commits all  merged in $default_branch"
    else
      echo " --> Commits not in $default_branch : "
      #echo "${result}"
      printf "$result\n"
    fi
    echo "---"
  done
}

#Thanks to Nathan DeVries
#https://gist.github.com/190002
clear_gitignored_files() {
  grep -Ev "^#|^$" .gitignore | while read line; do
  if [ -s "$line" ]; then
  OLD_IFS=$IFS; IFS=""
      for ignored_file in $( git ls-files "$line" ); do
  git rm --cached "$ignored_file"
      done
  IFS=$OLD_IFS
    fi
  done
}

##########################
# Destructive            #
##########################

delete_file_from_all_git_history() {
  local file=$1

  git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch $file" \
  --prune-empty --tag-name-filter cat -- --all
}

delete_all_local_tags() {
  git for-each-ref --shell --format="%(refname)" refs/tags | \
  while read tag
  do
          tag_name=${tag/refs\/tags\//}
  				git tag ${tag_name//\'/} -d
  done
}

delete_all_local_branches() {
  local default_branch="$(git_default_branch)";

  printf "\n\n\n\n== Would you like to delete ALL local branches? \nTHIS ACTION CANNOT BE UNDONE WITHOUT A WIZARDS HAT\nPlease select option (or any key to skip):\n"
  echo "1) Delete all - (git branch branch_name -D)"
  echo "-) Skip"
  read -n1 -s -r -t30 INPUT
  case "$INPUT" in
  "1")
  echo "== Deleting ALL local branches (please wait)..."
  #'refs/remotes/origin' --> Cannot do remotes yet... run git gc --prune=now before updating list
  local_branches=('refs/heads' )
  for branch_repo in ${local_branches[@]}
  do
    git for-each-ref --shell --format="%(refname)" $branch_repo | \
    while read branch
    do

            branch_name=${branch/$branch_repo\//}

            if [ $branch_name != "'$default_branch'" -a $branch_name != "'dev'" ]; then
              git branch ${branch_name//\'/} -D
              echo "${branch_name} deleted."

            else
            	echo "--> ${branch_name//\'/} skipped..."
            fi
    done
  done;;
  *)
  echo "== Delete skipped." ;;
  esac
}
