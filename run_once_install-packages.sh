#!/bin/bash
set -euo pipefail

if command -v brew &>/dev/null; then
  brew bundle --file="{{ .chezmoi.sourceDir }}/Brewfile" --no-lock
fi
