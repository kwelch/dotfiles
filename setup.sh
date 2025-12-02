#!/usr/bin/env bash

set -euo pipefail

DOTFILE_REPO="${DOTFILE_REPO:-$(cd "$(dirname "$0")" && pwd)}"
FORCE_FLAG=""
if [ "${1:-}" = "--force" ]; then
  FORCE_FLAG="--force"
fi

TOOLS=(omzsh nvm node_modules asdf jenv goenv cargo kubectl pnpm)
FAILURES=0

for tool in "${TOOLS[@]}"; do
  script="$DOTFILE_REPO/tools/$tool.sh"
  fn="install_${tool}"
  if [ ! -f "$script" ]; then
    printf 'Skipping %s (missing script)\n' "$tool"
    continue
  fi
  # shellcheck source=/dev/null
  source "$script"
  if ! declare -F "$fn" >/dev/null 2>&1; then
    printf 'Skipping %s (missing install function)\n' "$tool"
    continue
  fi
  if "$fn" "$FORCE_FLAG"; then
    printf '✓ %s\n' "$tool"
  else
    printf '✗ %s\n' "$tool" >&2
    FAILURES=$((FAILURES + 1))
  fi
done

if [ "$FAILURES" -gt 0 ]; then
  exit 1
fi

ensure_git_config_value() {
  local key="$1"
  local value="$2"
  if git config --global --get-all "$key" | grep -Fx "$value" >/dev/null 2>&1; then
    return 0
  fi
  git config --global --add "$key" "$value"
}

configure_git_includes() {
  if ! command -v git >/dev/null 2>&1; then
    printf 'Skipping git includes (git missing)\n'
    return
  fi

  local gitconfig="$HOME/.gitconfig"
  if [ -L "$gitconfig" ]; then
    printf 'Removing symlinked %s to rewrite config\n' "$gitconfig"
    rm -f "$gitconfig"
  fi
  if [ ! -f "$gitconfig" ]; then
    touch "$gitconfig"
  fi

  local personal_config="$DOTFILE_REPO/config/git/personal.gitconfig"
  if [ -f "$personal_config" ]; then
    ensure_git_config_value 'include.path' "$personal_config"
  else
    printf 'Missing personal git config: %s\n' "$personal_config"
  fi

  ensure_git_config_value 'includeIf."gitdir/i:~/atlassian/".path' '~/atlassian/.gitconfig'
}

configure_git_includes
