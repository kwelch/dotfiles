#!/usr/sh

# Add node modules to allow calling local node modules without prefix of yarn|npm
PATH=$PATH:./node_modules/.bin

# Created by `pipx` on 2022-11-04 19:04:05
export PATH="$PATH:/Users/kwelch/.local/bin"

# pnpm
export PNPM_HOME="/Users/kwelch/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
