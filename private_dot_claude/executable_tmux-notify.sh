#!/bin/bash
# Add a colored marker to window name when Claude needs attention
# Only if user is NOT already on this tab

if [ -n "$TMUX_PANE" ]; then
  # Get the window where Claude is running
  claude_window=$(tmux display-message -t "$TMUX_PANE" -p '#{window_id}')
  # Get the currently active window
  active_window=$(tmux display-message -p '#{window_id}')

  # Only notify if user is on a different window
  if [ "$claude_window" != "$active_window" ]; then
    current_name=$(tmux display-message -t "$claude_window" -p '#W')
    # Don't add if already marked
    if [[ ! "$current_name" =~ ^● ]]; then
      tmux rename-window -t "$claude_window" "● $current_name"
    fi
  fi
fi

# macOS notification only when Ghostty is not the active app
frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
if [ "$frontmost" != "ghostty" ]; then
  terminal-notifier -title "Terminal" -message "Ready" -group "claude-notify" 2>/dev/null &
fi
