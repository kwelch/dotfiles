#!/usr/sh

random_string() {
    LC_CTYPE=C tr -dc A-Za-z0-9 < /dev/urandom | fold -w "${1:-32}" | head -n 1
}

temp_branch() {
  string=$(random_string 32)
  branch_name="temp-${string}"
  git co -b "$branch_name"
}

delete_temp_branches() {
  git branch | grep "temp-" | xargs git branch -D
}
