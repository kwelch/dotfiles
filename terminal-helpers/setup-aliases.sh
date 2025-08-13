#!/bin/bash

# Timer alias to run a command repeatedly at specified intervals
# Usage: timer <seconds> <command>
# Example: timer 5 "echo 'Hello World'"
# Example: timer 30 "git status"
alias timer='_timer_function'

_timer_function() {
    if [ $# -lt 2 ]; then
        echo "Usage: timer <seconds> <command>"
        echo "Example: timer 5 \"echo 'Hello World'\""
        echo "Example: timer 30 \"git status\""
        return 1
    fi
    
    local interval=$1
    shift
    local command="$*"
    
    # Validate that interval is a positive number
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