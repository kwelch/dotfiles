#!/usr/bin/env bash

SCRIPT_THRESHOLD_MS=100
TOTAL_THRESHOLD_MS=300
ZSH_STARTUP_LOG=${ZSH_STARTUP_LOG:-"$HOME/.zsh_startup_times"}
TOOLS_ORDER=(omzsh nvm node_modules asdf jenv goenv pyenv pip cargo kubectl pnpm)

load_tool_order_file() {
  local tool_file="$1"
  [ -f "$tool_file" ] || return
  # shellcheck source=/dev/null
  source "$tool_file"
}

load_tool_order_file "$DOTFILE_REPO/config/shell/tools-order.sh"
if [ -n "${DOTFILE_OVERLAY_REPO:-}" ] && [ "$DOTFILE_OVERLAY_REPO" != "$DOTFILE_REPO" ]; then
  load_tool_order_file "$DOTFILE_OVERLAY_REPO/config/shell/tools-order.sh"
fi

ensure_startup_log() {
  mkdir -p "$(dirname "$ZSH_STARTUP_LOG")"
  if [ ! -f "$ZSH_STARTUP_LOG" ]; then
    : > "$ZSH_STARTUP_LOG"
    return
  fi

  local last_line last_date last_epoch now_epoch
  last_line=$(tail -n 1 "$ZSH_STARTUP_LOG")
  last_date=$(printf "%s" "$last_line" | awk '{print $1}')
  if [ -z "$last_date" ]; then
    return
  fi

  last_epoch=$(date_to_epoch "$last_date")
  now_epoch=$(date +%s)
  if [ -n "$last_epoch" ] && [ $((now_epoch - last_epoch)) -gt 604800 ]; then
    : > "$ZSH_STARTUP_LOG"
  fi
}

date_to_epoch() {
  local input="$1"
  if date -j -f "%Y-%m-%d" "$input" +%s >/dev/null 2>&1; then
    date -j -f "%Y-%m-%d" "$input" +%s
  else
    date -d "$input" +%s 2>/dev/null
  fi
}

now_ms() {
  perl -MTime::HiRes -e 'printf("%.0f", Time::HiRes::time()*1000)' 2>/dev/null || date +%s000
}

log_entry() {
  printf "%s | %s: %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$1" "$2" >> "$ZSH_STARTUP_LOG"
}

run_tool_runtime() {
  local tool="$1"
  local -a scripts=()
  local -a roots=()
  local base_script="$DOTFILE_REPO/tools/$tool.sh"
  local overlay_script

  if [ -f "$base_script" ]; then
	scripts+=("$base_script")
	roots+=("$DOTFILE_REPO")
  fi
  if [ -n "${DOTFILE_OVERLAY_REPO:-}" ]; then
	overlay_script="$DOTFILE_OVERLAY_REPO/tools/$tool.sh"
	if [ -f "$overlay_script" ] && [ "$overlay_script" != "$base_script" ]; then
		scripts+=("$overlay_script")
		roots+=("$DOTFILE_OVERLAY_REPO")
	fi
  fi

  if [ "${#scripts[@]}" -eq 0 ]; then
	return
  fi
  local check_fn="check_${tool}"
  local runtime_fn="runtime_${tool}"
  local idx script script_root prev_repo
  for idx in "${!scripts[@]}"; do
	script="${scripts[$idx]}"
	script_root="${roots[$idx]}"
	if [ -n "$script_root" ] && [ "$script_root" != "$DOTFILE_REPO" ]; then
		prev_repo="$DOTFILE_REPO"
		DOTFILE_REPO="$script_root"
		# shellcheck source=/dev/null
		source "$script"
		DOTFILE_REPO="$prev_repo"
	else
		# shellcheck source=/dev/null
		source "$script"
	fi
  done
  if ! typeset -f "$check_fn" >/dev/null 2>&1 || ! typeset -f "$runtime_fn" >/dev/null 2>&1; then
    return
  fi

  if ! "$check_fn" >/dev/null 2>&1; then
    log_entry "$tool" "FAILED check"
    TOOL_FAIL_COUNT=$((TOOL_FAIL_COUNT + 1))
    return
  fi

  local start_ms end_ms duration
  start_ms=$(now_ms)
  "$runtime_fn"
  end_ms=$(now_ms)
  duration=$((end_ms - start_ms))
  TOTAL_RUNTIME_MS=$((TOTAL_RUNTIME_MS + duration))
  log_entry "$tool" "${duration}ms"

  if [ -n "$DEBUG_SHELL_STARTUP" ]; then
    printf '[init] %s %dms\n' "$tool" "$duration"
  fi

  if [ "$duration" -gt "$SCRIPT_THRESHOLD_MS" ]; then
    SLOW_TOOLS+=("$tool(${duration}ms)")
  fi
}

TOOL_FAIL_COUNT=0
TOTAL_RUNTIME_MS=0
SLOW_TOOLS=()

source "$DOTFILE_REPO/config/shell/functions.sh"
ensure_startup_log

for tool in "${TOOLS_ORDER[@]}"; do
  run_tool_runtime "$tool"
done

WARNINGS=()
if [ "$TOTAL_RUNTIME_MS" -gt "$TOTAL_THRESHOLD_MS" ]; then
  WARNINGS+=("startup ${TOTAL_RUNTIME_MS}ms (> ${TOTAL_THRESHOLD_MS}ms)")
fi

if [ "${#SLOW_TOOLS[@]}" -gt 0 ]; then
  WARNINGS+=("${#SLOW_TOOLS[@]} slow tool(s): ${SLOW_TOOLS[*]}")
fi

if [ "${#WARNINGS[@]}" -gt 0 ]; then
  printf '⚠ [init] %s\n' "${WARNINGS[*]}" >&2
fi

if [ "$TOOL_FAIL_COUNT" -gt 0 ]; then
  printf '✗ [init] %d tool(s) failed, see %s for details\n' "$TOOL_FAIL_COUNT" "$ZSH_STARTUP_LOG" >&2
fi
