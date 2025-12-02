#!/usr/bin/env bash

export EDITOR="code --wait"
: "${ZSH_STARTUP_LOG:=$HOME/.zsh_startup_times}"

random_string() {
  LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | fold -w "${1:-32}" | head -n 1
}

temp_branch() {
  local branch_name
  branch_name="temp-$(random_string 32)"
  git checkout -b "$branch_name"
}

delete_temp_branches() {
  local branches
  branches=$(git branch | grep "temp-" || true)
  [ -z "$branches" ] && return 0
  printf '%s
' "$branches" | while read -r branch; do
    [ -n "$branch" ] && git branch -D "$branch"
  done
}

_timer_function() {
  if [ $# -lt 2 ]; then
    echo "Usage: timer <seconds> <command>"
    echo "Example: timer 5 \"echo 'Hello World'\""
    return 1
  fi

  local interval=$1
  shift
  local command="$*"

  if ! [[ "$interval" =~ ^[0-9]+$ ]] || [ "$interval" -le 0 ]; then
    echo "Error: Interval must be a positive integer (seconds)"
    return 1
  fi

  echo "Running '$command' every $interval seconds. Press Ctrl+C to stop."
  echo "----------------------------------------"

  while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Executing: $command"
    eval "$command"
    echo "----------------------------------------"
    sleep "$interval"
  done
}

alias timer='_timer_function'

clear-shell-startup-times() {
  if [ -n "$ZSH_STARTUP_LOG" ]; then
    : > "$ZSH_STARTUP_LOG"
    echo "Cleared $ZSH_STARTUP_LOG"
  fi
}
