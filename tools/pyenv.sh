#!/usr/bin/env bash

install_pyenv() {
  local target="$HOME/.pyenv"
  if [ -d "$target" ] && [ "$1" != "--force" ]; then
    return 0
  fi

  rm -rf "$target"
  if ! git clone --depth 1 https://github.com/pyenv/pyenv.git "$target" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

check_pyenv() {
  [ -d "$HOME/.pyenv" ] || command -v pyenv >/dev/null 2>&1
}

runtime_pyenv() {
  export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
  PYENV_BIN="$PYENV_ROOT/bin"
  [ -d "$PYENV_BIN" ] || return 0

  # expose bare pyenv executable via PATH but skip shims until init
  case ":$PATH:" in
    *":$PYENV_BIN:") ;;
    *) PATH="$PYENV_BIN:$PATH" ;;
  esac
  export PATH

  if ! command -v pyenv >/dev/null 2>&1; then
    return 0
  fi

  pyenv_lazy_init() {
    unalias pyenv >/dev/null 2>&1 || true
    unset -f pyenv >/dev/null 2>&1 || true
    eval "$(command pyenv init -)"
    if command -v pyenv >/dev/null 2>&1 && command -v pyenv-virtualenv-init >/dev/null 2>&1; then
      eval "$(pyenv virtualenv-init -)"
    fi
    unset -f pyenv_lazy_init
  }

  pyenv() {
    pyenv_lazy_init
    command pyenv "$@"
  }
}
