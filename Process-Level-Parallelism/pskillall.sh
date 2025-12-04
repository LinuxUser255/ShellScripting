#!/usr/bin/env bash

set -euo pipefail
# Search and kill process
# Efficient, no-subshell, function-based, fzf-integrated version
# Clean `if` statements (no chained `&&`/`||`)
# Uses `fzf` for intuitive PID selection from search results
# Includes a confirmation step before killing
IFS=$'\n\t'
MAX_JOBS=$(nproc)

# Function: prompt for a process name and search using ps + rg
search_processes(){
      # set process name var
        local name
        printf '\n'
        read -r -p 'Enter process name to search for: '  name
        printf '\n'
        ps -ef | rg -i "$name" || true
}

# Function: use fzf to select a PID from matching processes
select_pid(){
        local result
        result=$(ps -ef | rg -i "$1" | fzf --height=40% --reverse | awk '{print $2}') || result=""
        REPLY="$result"
}

get_all_pids(){
        local line
        PIDS=()
        while IFS= read -r line; do
            PIDS+=("$line")
        done < <(ps -ef | rg -i "$1" | awk '{print $2}')
        echo "${PIDS[@]}"
}


# Function: kill the selected PID
kill_pid(){
        if kill "$1" 2>/dev/null; then
            printf 'Process with PID %s killed.\n' "$1"
        else
            printf 'Failed to kill process with PID %s.\n' "$1"
        fi
}

# kill all PIDs matching a process name
kill_all_pids(){
        get_all_pids "$1"

        if [[  ${#PIDS[@]} -eq 0 ]]; then
            printf 'No matching processes found.\n'
            return
        fi

        printf 'Found %d matching process(es). Killing in parallel...\n' "${#PIDS[@]}"
        printf '%s\n' "${PIDS[@]}" | xargs -P "$MAX_JOBS" -n 1 kill 2>/dev/null || true
        printf '✅ Sent kill signal to all matching processes\n'
}

confirm_kill() {
        local response
        read -r -p "$1 [y/N]: " response
        [[ $response =~ ^[Yy]$ ]]
}

# Main logic
main(){
        # declare local keyword
        local name pid choice

        search_processes
        printf '\nSelect a process to kill:\n'
        read -r -p 'RE-enter process name to kill all matching processes: ' name

        printf '\nOptions:\n'
        printf '  1) Select single process with fzf\n'
        printf '  2) Kill ALL matching processes (parallel)\n'
        printf '  3) Exit\n\n'
        read -r -p 'Choose an option [1/2/3]: ' choice

        case $choice in
            1)
                select_pid "$name"
                pid="$REPLY"
                if [[ -z $pid ]]; then
                        printf 'No PID selected. Exiting.\n'
                        return
                fi

                printf '\n'

                if confirm_kill "Kill process with PID $pid?"; then
                        kill_pid "$pid"
                else
                        printf 'Aborted.\n'
                fi
                ;;

            2)
                printf '\n'
                if confirm_kill "Kill all processes matching '$name'?" ; then
                        kill_all_pids "$name"
                else
                        printf 'Aborted.\n'
                fi
                ;;

            *)
                printf 'Invalid option. Exiting.\n'
                ;;
        esac
}

main "$@"
