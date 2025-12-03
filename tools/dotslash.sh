#!/usr/bin/env bash

install_dotslash() {
  local bin_dir="$HOME/.local/bin"
  mkdir -p "$bin_dir"

  if [ -x "$bin_dir/dotslash" ] && [ "$1" != "--force" ]; then
    return 0
  fi

  case "$(uname -s)" in
    Linux)
      curl -LSfs "https://github.com/facebook/dotslash/releases/latest/download/dotslash-ubuntu-22.04.$(uname -m).tar.gz" | tar fxz - -C "$bin_dir" || return 1
      ;;
    Darwin)
      curl -LSfs "https://github.com/facebook/dotslash/releases/latest/download/dotslash-macos.tar.gz" | tar fxz - -C "$bin_dir" || return 1
      ;;
    *)
      return 1
      ;;
  esac
  return 0
}

check_dotslash() {
  [ -x "$HOME/.local/bin/dotslash" ]
}

runtime_dotslash() {
  local bin_dir="$HOME/.local/bin"
  case ":$PATH:" in
    *":$bin_dir:") ;;
    *) PATH="$bin_dir:$PATH" ;;
  esac
  export PATH
}
