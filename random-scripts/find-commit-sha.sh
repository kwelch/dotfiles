#!/bin/sh

#link-to: ~/.local/bin/find-commit-with-string

SEARCH_STRING="$1"
DAYS_LIMIT="${2:-10}"

echo "Commits containing '$SEARCH_STRING' in their message (last $DAYS_LIMIT days):"

for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
  git log --grep="$SEARCH_STRING" --since="$DAYS_LIMIT days ago" --pretty=format:"%h %s" "$branch" 2> /dev/null
done | sort -u
