#!/usr/bin/env bash

install_cargo() {
  if command -v rustup >/dev/null 2>&1; then
    return 0
  fi
  # Prevent rustup from attempting to edit shell profiles (e.g. root-owned .bashrc).
  if ! curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path > /dev/null 2>&1; then
    return 1
  fi
  return 0
}

check_cargo() {
  [ -f "$HOME/.cargo/env" ] || command -v rustup >/dev/null 2>&1
}

runtime_cargo() {
  [ -f "$HOME/.cargo/env" ] && \. "$HOME/.cargo/env"
}
