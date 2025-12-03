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

expand_path() {
  local input="$1"
  case "$input" in
    "~"|"~/")
      printf '%s\n' "$HOME"
      ;;
    ~/*)
      printf '%s/%s\n' "$HOME" "${input#~/}"
      ;;
    *)
      printf '%s\n' "$input"
      ;;
  esac
}

normalize_gitdir_pattern() {
  local raw="$1"
  local expanded
  expanded="$(expand_path "$raw")"
  case "$expanded" in
    *\**|*?*|*[[]*)
      printf '%s\n' "$expanded"
      ;;
    */)
      printf '%s\n' "$expanded"
      ;;
    *)
      printf '%s/\n' "$expanded"
      ;;
  esac
}

ensure_git_include_if() {
  local pattern="$1"
  local include_path="$2"
  local key="includeIf.gitdir:$pattern.path"
  local existing_values existing
  existing_values=$(git config --global --get-all "$key" 2>/dev/null || true)
  while IFS= read -r existing; do
    [ -z "$existing" ] && continue
    [ "$existing" = "$include_path" ] && return 0
  done <<< "$existing_values"
  git config --global --add "$key" "$include_path"
}

configure_work_git_include() {
  local detected_repo="${DOTFILE_WORK_REPO:-}"
  local default_repo="$HOME/work/dotfiles"
  if [ -z "$detected_repo" ] && [ -d "$default_repo" ]; then
    detected_repo="$default_repo"
  fi
  if [ -n "$detected_repo" ]; then
    detected_repo="$(expand_path "$detected_repo")"
  fi
  [ -n "$detected_repo" ] || return 0

  local work_config="$detected_repo/config/git/work.gitconfig"
  [ -f "$work_config" ] || return 0

  local gitdir_root="${DOTFILE_WORK_GITDIR:-$HOME/work/}"
  local pattern
  pattern="$(normalize_gitdir_pattern "$gitdir_root")"
  ensure_git_include_if "$pattern" "$work_config"
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
}

configure_git_includes
configure_work_git_include
