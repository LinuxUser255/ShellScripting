#!/usr/bin/env bash

# Search and kill process
# A clean, function-based, fzf-integrated version
# Minimalist functions** using `f()(...)` or `f()if...` style
# Clean `if` statements (no chained `&&`/`||`)
# Uses `fzf` for intuitive PID selection from search results
# Includes a confirmation step before killing


# Function: prompt for a process name and search using ps + rg
search_processes()(
  echo ''
  read -p 'Enter process name to search for: ' name
  echo ''
  ps -ef | rg -i "$name"
)

# Function: use fzf to select a PID from matching processes
select_pid()(
  pid=$(ps -ef | rg -i "$1" | fzf --height=40% --reverse | awk '{print $2}')
  echo "$pid"
)

# Function: kill the selected PID
kill_pid()(
  if kill "$1" 2>/dev/null; then
    echo "✅ Killed process $1"
  else
    echo "❌ Failed to kill process $1 (may not exist or insufficient permissions)"
  fi
)

# Main logic
main()(
  search_processes
  echo ''
  read -p 'Re-enter process name for PID selection: ' name
  pid=$(select_pid "$name")

  if [ -z "$pid" ]; then
    echo "No PID selected. Exiting."
    return
  fi

  echo ''
  read -p "Kill process with PID $pid? [y/N]: " confirm
  if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    kill_pid "$pid"
  else
    echo "Aborted."
  fi
)

main



