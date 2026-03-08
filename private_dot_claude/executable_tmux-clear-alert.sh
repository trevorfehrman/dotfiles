#!/bin/bash
# Remove marker from window name when returning
current_name=$(tmux display-message -p '#W')
clean_name="${current_name#● }"
if [ "$current_name" != "$clean_name" ]; then
  tmux rename-window "$clean_name"
fi

# Dismiss macOS notification
terminal-notifier -remove "claude-notify" 2>/dev/null &
