#!/usr/bin/env bash

install_pnpm() {
  local force="$1"
  if [ "$force" != "--force" ] && command -v pnpm >/dev/null 2>&1; then
    return 0
  fi
  if command -v corepack >/dev/null 2>&1; then
    corepack prepare pnpm@latest --activate >/dev/null 2>&1 && return 0
  fi
  if command -v npm >/dev/null 2>&1; then
    npm install -g pnpm >/dev/null 2>&1 && return 0
  fi
  return 1
}

check_pnpm() {
  command -v pnpm >/dev/null 2>&1
}

runtime_pnpm() {
  export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
  mkdir -p "$PNPM_HOME"
  case ":$PATH:" in
    *":$PNPM_HOME:") ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
}
