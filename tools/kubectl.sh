#!/usr/bin/env bash

KUBECTL_COMPLETION_FILE="${ZSH_COMPLETIONS_DIR:-$HOME/.zsh/completions}/_kubectl"

install_kubectl() {
  command -v kubectl >/dev/null 2>&1 || return 1
  mkdir -p "$(dirname "$KUBECTL_COMPLETION_FILE")"
  if [ "$1" = "--force" ] || [ ! -f "$KUBECTL_COMPLETION_FILE" ]; then
    kubectl completion zsh > "$KUBECTL_COMPLETION_FILE" 2>/dev/null || return 1
  fi
  return 0
}

check_kubectl() {
  command -v kubectl >/dev/null 2>&1
}

runtime_kubectl() {
  command -v kubectl >/dev/null 2>&1 || return 0
  alias k=kubectl
  alias kgrp="kubectl get pods --field-selector=status.phase=Running"

  :
}
