#!/bin/bash -e

#Git Helpers (#TODO : Parameterize this)
alias git_commits_in_dates_with_author='git log --pretty=format:"%h%x09%an%x09%ad%x09%s" --date=local --before="Nov 01 2009" --after="Jul 1 2009" > git_output.txt'
alias git_commits_in_dates_without_author='git log --pretty=format:"%h%x09%ad%x09%s" --date=local --before="Nov 01 2009" --after="Jul 1 2009" > git_output.txt'
alias git_commits_in_dates_with_name_and_date='git log --pretty=format:"%ad%x09%s" --date=local --before="Nov 01 2009" --after="Jul 1 2009" > git_output.txt'
export clean_all_git_command='cd "${0}/../" && git gc --aggressive | pwd'
alias clean_all_git_directories="find . -type d -iname '.git' -maxdepth 10 -exec sh -c '${clean_all_git_command}' \"{}\" \;"
alias sup="startup"
alias remote_sup="startup 'remove_remote_branches'"

git_default_branch() {
  # git remote set-head origin main
  git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

#Delete any passed branch name except protected
delete_local_branch() {
if [[ $1 =~ ^([* ]+)?(master|main|production)$ ]]; then
  echo "- [skipped] ${1}"
else
  git branch $1 -D -q
  echo "x [deleted] ${1}"
fi
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

    if [[ $branch_name = "default_branch" || $branch_name = 'production' ||  $branch_name = 'HEAD' ]]; then
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

startup() {
#Quick function to start the day and grab the latest info, fetch all open pull requests, and remove merged branches
# Dependencies :
#    - gem install git-pulls
#    - For private repos :
#     - Environment variables : GITHUB_USER + GITHUB_TOKEN
#     - https://help.github.com/articles/creating-an-oauth-token-for-command-line-use
# TODO: Remove git-pulls dependency and make a bash only system
# TODO: Crash out of script if the current branch, or default branch is in a dirty state
local remove_remote_branches=false
local default_branch="$(git_default_branch)";
if [[ "${1}" == "remove_remote_branches" ]]; then
  remove_remote_branches=true
fi;
for remote in $(git remote); do
  echo "==> ($remote) Fetching & Sweeping merged remote tags"
  git fetch $remote --prune --tags --force
  echo "==> ($remote) Fetching & Sweeping merged remote branches"
  git fetch $remote --prune
done
if [[ "$remove_remote_branches" == true ]]; then
  echo "==> Removing any merged remote branches"
  delete_merged_remote_branches
fi
echo "==> Updating ${default_branch}"
git checkout $default_branch
git pull
# Disabled as git-pulls is failing with octokit for un-debugged reason
# echo "==> Fetching any open pull requests"
# git-pulls update
# git-pulls checkout --force
echo "==> Removing any local branches merged into $default_branch"
git branch --merged $default_branch | while read i; do delete_local_branch "$i"; done
# echo "==> Clearing any logs"
# for f in $(find . -name "*.log" -type f -exec ls {} \;)
# do
#   if [ -f $f ]; then
#     echo "Nulling ${f}"
#     cat /dev/null > $f
#   fi
# done
if [[ -e ".gitmodules" ]]; then
  echo "==> Updating git submodules"
  git submodule update --init
fi;
echo "==> Checking GIT, pruning to 2 weeks"
git gc --auto
}

git_commits_by_user() {
git log --pretty=format:%an | awk '{ ++c[$0]; } END { for(cc in c) printf "%5d %s\n",c[cc],cc; }'| sort -r
}

##########################
#Display                 #
##########################
# function parse_git_branch {
#   git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/\1$(parse_git_dirty)/"
# }

# function parse_git_dirty {
#   [[ $(git status --porcelain 2> /dev/null | tail -n1) != "" ]] && echo "(☠ )"
# }

# # Display custom dirty git branch items
# export PS1='\[\033[01;32m\]\w $(git branch &>/dev/null; if [ $? -eq 0 ]; then echo "\[\033[01;34m\]$(parse_git_branch)"; fi) \$ \[\033[00m\]'

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
  cat .gitignore | egrep -v "^#|^$" | while read line; do
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
  git-for-each-ref --shell --format="%(refname)" refs/tags | \
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
