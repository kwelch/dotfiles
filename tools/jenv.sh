#!/usr/bin/env bash

install_jenv() {
  local target="$HOME/.jenv"
  if [ -d "$target" ] && [ "$1" != "--force" ]; then
    return 0
  fi
  rm -rf "$target"
  if ! git clone --depth 1 https://github.com/jenv/jenv.git "$target" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

check_jenv() {
  [ -d "$HOME/.jenv" ] || command -v jenv >/dev/null 2>&1
}

runtime_jenv() {
  export PATH="$HOME/.jenv/bin:$PATH"
  command -v jenv >/dev/null 2>&1 || return 0

  jenv_lazy_init() {
    unalias jenv java javac 2>/dev/null
    unset -f jenv java javac 2>/dev/null
    eval "$(command jenv init -)"
    unset -f jenv_lazy_init
  }

  __jenv_lazy_exec() {
    local cmd="$1"
    shift
    jenv_lazy_init
    command "$cmd" "$@"
  }

  jenv() { __jenv_lazy_exec jenv "$@"; }
  java() { __jenv_lazy_exec java "$@"; }
  javac() { __jenv_lazy_exec javac "$@"; }
}
