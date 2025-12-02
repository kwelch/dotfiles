#!/usr/bin/env bash

install_goenv() {
  local target="$HOME/.goenv"
  if [ -d "$target" ] && [ "$1" != "--force" ]; then
    return 0
  fi
  rm -rf "$target"
  if ! git clone --depth 1 https://github.com/go-nv/goenv.git "$target" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

check_goenv() {
  [ -d "$HOME/.goenv" ] || command -v goenv >/dev/null 2>&1
}

runtime_goenv() {
  export GOENV_ROOT="$HOME/.goenv"
  export PATH="$GOENV_ROOT/bin:$PATH"
  command -v goenv >/dev/null 2>&1 || return 0

  goenv_lazy_init() {
    unalias go 2>/dev/null
    unalias goenv 2>/dev/null
    unset -f go 2>/dev/null
    unset -f goenv 2>/dev/null
    eval "$(command goenv init -)"
    unset -f goenv_lazy_init
  }

  go() {
    unset -f go 2>/dev/null
    goenv_lazy_init
    command go "$@"
  }

  goenv() {
    unset -f goenv 2>/dev/null
    goenv_lazy_init
    command goenv "$@"
  }
}
