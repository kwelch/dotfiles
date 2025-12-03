#!/usr/bin/env bash

random_scripts_dir() {
  printf '%s/random-scripts' "$DOTFILE_REPO"
}

random_scripts_backup_dir=""

ensure_random_scripts_backup_dir() {
  if [ -n "$random_scripts_backup_dir" ]; then
    printf '%s' "$random_scripts_backup_dir"
    return
  fi
  random_scripts_backup_dir="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "$random_scripts_backup_dir"
  printf '%s' "$random_scripts_backup_dir"
}

random_scripts_link_target() {
  local file="$1"
  head -5 "$file" | grep -i "link-to:" | sed 's/.*link-to: *//i' | sed 's/ *$//' | head -1
}

expand_random_path() {
  local input="$1"
  case "$input" in
    ~)
      printf '%s' "$HOME"
      ;;
    ~/*)
      printf '%s/%s' "$HOME" "${input#~/}"
      ;;
    *)
      printf '%s' "$input"
      ;;
  esac
}

link_random_script() {
  local src="$1"
  local dest="$2"
  local backup_dir
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    backup_dir="$(ensure_random_scripts_backup_dir)"
    if [ -L "$dest" ]; then
      cp "$(readlink "$dest")" "$backup_dir/$(basename "$dest")" 2> /dev/null || true
      rm -f "$dest"
    else
      mv "$dest" "$backup_dir/" 2> /dev/null || return 1
    fi
  fi
  local dest_dir
  dest_dir="$(dirname "$dest")"
  mkdir -p "$dest_dir"
  ln -sf "$src" "$dest"
}

install_random_scripts() {
  local dir
  dir="$(random_scripts_dir)"
  [ -d "$dir" ] || return 0

  local file dest expanded
  for file in "$dir"/*; do
    [ -f "$file" ] || continue
    dest="$(random_scripts_link_target "$file")"
    [ -n "$dest" ] || continue
    expanded="$(expand_random_path "$dest")"
    link_random_script "$file" "$expanded"
  done
  return 0
}

check_random_scripts() {
  local dir
  dir="$(random_scripts_dir)"
  [ -d "$dir" ] || return 0

  local file dest expanded missing=0
  for file in "$dir"/*; do
    [ -f "$file" ] || continue
    dest="$(random_scripts_link_target "$file")"
    [ -n "$dest" ] || continue
    expanded="$(expand_random_path "$dest")"
    if [ ! -e "$expanded" ] && [ ! -L "$expanded" ]; then
      missing=1
      break
    fi
  done
  return $missing
}

runtime_random_scripts() {
  return 0
}
