#!/usr/bin/env bash

install_asdf() {
  local target="$HOME/.asdf"
  if [ -d "$target" ] && [ "$1" != "--force" ]; then
    return 0
  fi
  rm -rf "$target"
  if ! git clone --depth 1 https://github.com/asdf-vm/asdf.git "$target" >/dev/null 2>&1; then
    return 1
  fi
  return 0
}

check_asdf() {
  [ -d "$HOME/.asdf" ] || command -v asdf >/dev/null 2>&1 || [ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]
}

runtime_asdf() {
  if [ -f "/opt/homebrew/opt/asdf/libexec/asdf.sh" ]; then
    # prefer Homebrew-managed install when available
    # shellcheck source=/dev/null
    source /opt/homebrew/opt/asdf/libexec/asdf.sh
  elif [ -f "$HOME/.asdf/asdf.sh" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.asdf/asdf.sh"
  fi

  if [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc" ]; then
    # shellcheck source=/dev/null
    source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"
  fi

  if [ -f "$HOME/.asdf/plugins/java/set-java-home.zsh" ]; then
    # shellcheck source=/dev/null
    source "$HOME/.asdf/plugins/java/set-java-home.zsh"
  fi
}
