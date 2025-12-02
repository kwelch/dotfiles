#!/usr/bin/env bash

install_omzsh() {
  local install_dir="$HOME/.oh-my-zsh"
  if [ "$1" != "--force" ] && [ -d "$install_dir" ]; then
    return 0
  fi

  rm -rf "$install_dir"
  command -v zsh >/dev/null 2>&1 || return 1

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1
}

check_omzsh() {
  [ -d "$HOME/.oh-my-zsh" ]
}

runtime_omzsh() {
  return 0
}
