#!/usr/bin/env bash

install_nvm() {
  local nvm_dir="$HOME/.nvm"
  local force="$1"
  if [ "$force" != "--force" ] && [ -s "$nvm_dir/nvm.sh" ]; then
    return 0
  fi

  mkdir -p "$nvm_dir"
  if ! curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash > /dev/null 2>&1; then
    return 1
  fi
  return 0
}

check_nvm() {
  [ -s "$HOME/.nvm/nvm.sh" ]
}

runtime_nvm() {
  export NVM_DIR="$HOME/.nvm"
  export NVM_STARTUP_CACHE="$NVM_DIR/.startup-version"

  nvm_apply_cached_version() {
    local cache_file="$1"
    [ -f "$cache_file" ] || return 0
    local cached_version cached_path
    cached_version=$(cat "$cache_file" 2>/dev/null)
    [ -n "$cached_version" ] || return 0
    cached_path="$NVM_DIR/versions/node/$cached_version/bin"
    [ -d "$cached_path" ] || return 0
    case ":$PATH:" in
      *":$cached_path:") ;;
      *) PATH="$cached_path:$PATH" ;;
    esac
    export PATH
    export NVM_BIN="$cached_path"
    export NVM_CD_FLAGS=""
  }

  nvm_lazy_init() {
    local fn
    for fn in nvm node npm npx; do
      unset -f "$fn" >/dev/null 2>&1 || true
    done
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    if command -v nvm >/dev/null 2>&1; then
      nvm use --silent >/dev/null 2>&1 || true
      local current
      current=$(nvm current 2>/dev/null)
      if [ -n "$current" ] && [ "$current" != "system" ]; then
        printf '%s' "$current" > "$NVM_STARTUP_CACHE"
      fi
    fi
    unset -f nvm_lazy_init
  }

  nvm_lazy_exec() {
    local cmd="$1"
    shift
    nvm_lazy_init
    "$cmd" "$@"
  }

  nvm_lazy_wrap() {
    local cmd
    for cmd in "$@"; do
      eval "$cmd() { nvm_lazy_exec $cmd \"\$@\"; }"
    done
  }

  nvm_apply_cached_version "$NVM_STARTUP_CACHE"
  nvm_lazy_wrap nvm node npm npx yarn
}
