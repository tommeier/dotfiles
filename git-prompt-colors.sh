# This is a theme for gitprompt.sh,

override_git_prompt_colors() {
  # originally based on Single_line_Dark
  GIT_PROMPT_THEME_NAME="Single_line_DarkTom_Custom"
  GIT_PROMPT_BRANCH="${Cyan}"
  GIT_PROMPT_MASTER_BRANCH="${GIT_PROMPT_BRANCH}"
  GIT_PROMPT_UNTRACKED=" ${Cyan}…${ResetColor}"
  GIT_PROMPT_CHANGED="${Yellow}✚ "
  GIT_PROMPT_STAGED="${Magenta}●"

  GIT_PROMPT_START_USER="_LAST_COMMAND_INDICATOR_ ${BoldBlue}\w${ResetColor}"
  GIT_PROMPT_START_ROOT="_LAST_COMMAND_INDICATOR_ ${BoldRed}\h:${BoldBlue}\w${ResetColor}"

  GIT_PROMPT_END_USER="${ResetColor}> "
  GIT_PROMPT_END_ROOT=" # ${ResetColor}"
}

reload_git_prompt_colors "Single_line_DarkTom_Custom"
