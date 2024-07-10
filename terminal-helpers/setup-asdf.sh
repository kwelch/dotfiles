#!/usr/bash

[[ ! -f ~/opt/homebrew/opt/asdf/libexec/asdf.sh ]] || source /opt/homebrew/opt/asdf/libexec/asdf.sh
source "${XDG_CONFIG_HOME:-$HOME/.config}/asdf-direnv/zshrc"
