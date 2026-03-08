#!/usr/bin/env bash

# Gruvbox Dark Hard color palette
fg_orange='\033[38;2;254;128;25m'   # fe8019 - orange (model)
fg_blue='\033[38;2;131;165;152m'    # 83a598 - blue (directory)
fg_green='\033[38;2;184;187;38m'    # b8bb26 - green (context good)
fg_yellow='\033[38;2;250;189;47m'   # fabd2f - yellow (context warning)
fg_red='\033[38;2;251;73;52m'       # fb4934 - red (context low)
fg_purple='\033[38;2;211;134;155m'  # d3869b - purple (PR info)
fg_aqua='\033[38;2;142;192;124m'    # 8ec07c - aqua (separator)
reset='\033[0m'

# Read stdin
input=$(cat)

# Extract data
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
dir=$(basename "$(echo "$input" | jq -r '.workspace.current_dir // .cwd')")
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Shorten model name (e.g., "Claude 4.5 Opus" -> "opus 4.5")
model_short=$(echo "$model" | sed -E 's/Claude ([0-9.]+) (Opus|Sonnet|Haiku).*/\L\2 \1/')

# Build first line
line1="${fg_orange}${model_short}${reset}"
line1+=" ${fg_aqua}│${reset} "
line1+="${fg_blue}${dir}${reset}"

# Add context with color coding: green >50%, yellow 20-50%, red <20%
if [ -n "$remaining" ]; then
  ctx_num=$(echo "$remaining" | sed 's/\..*//')
  if [ "$ctx_num" -gt 50 ]; then
    ctx_color="$fg_green"
  elif [ "$ctx_num" -gt 20 ]; then
    ctx_color="$fg_yellow"
  else
    ctx_color="$fg_red"
  fi
  line1+=" ${fg_aqua}│${reset} ${ctx_color}${remaining}%${reset}"
fi

# Check Context7 MCP process
if pgrep -f 'context7-mcp' > /dev/null 2>&1; then
  line1+=" ${fg_aqua}│${reset} ${fg_green}ctx7${reset}"
else
  line1+=" ${fg_aqua}│${reset} ${fg_red}ctx7${reset}"
fi

# Check for git PR info
pr_info=""
if command -v git &> /dev/null && git rev-parse --git-dir &> /dev/null 2>&1; then
  branch=$(git -c core.fileMode=false -c advice.detachedHead=false rev-parse --abbrev-ref HEAD 2>/dev/null)
  pr_num=$(echo "$branch" | grep -oiE '(pr|pull|feat)[/-]?[0-9]+' | grep -oE '[0-9]+')

  if [ -n "$pr_num" ]; then
    pr_info="${fg_purple}PR #${pr_num}${reset}"
  fi
fi

# Output (escape % to %% so printf doesn't treat them as format specifiers)
safe_line1="${line1//%/%%}"
printf "${safe_line1}"
if [ -n "$pr_info" ]; then
  safe_pr="${pr_info//%/%%}"
  printf "\n${safe_pr}"
fi
printf "${reset}"
