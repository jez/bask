#!/usr/bin/env bash

# shellcheck disable=SC2034
VERSION="0.9.0"

## Only use milliseconds if available, by detecting GNU coreutils
## See: http://stackoverflow.com/a/8748344/319952
if date --version > /dev/null 2>&1 ; then
    MILLIS="%3N"
else
    # Approximate the milliseconds with zeros
    MILLIS="000"
fi

# Suffix for logging purposes
MILLI_SUFFIX=".$MILLIS"

## Default task
declare -g bask_default_task="default"

## Trap EXIT signal to bootstrap bask.
## Works like a charm - your script ends, tasks start to run.
## Trap resets after bootstrapping.
trap '[[ ${?} -eq 0 ]] && _bask_bootstrap' EXIT

## Expand aliases
shopt -s expand_aliases

## Determine the initial passed arguments to the root script
declare -ga bask_args=("${@}")

## Split arguments into tasks and flags.
## All flags are then passed on to tasks.
## E.g. --production
## NOTE: The actual splitting is done in _bask_bootstrap.
declare -ga bask_flags
declare -ga bask_tasks

declare -gA _bask_colors=(
    [black]="$(echo -e '\e[30m')"
    [red]="$(echo -e '\e[31m')"
    [green]="$(echo -e '\e[32m')"
    [yellow]="$(echo -e '\e[33m')"
    [blue]="$(echo -e '\e[34m')"
    [purple]="$(echo -e '\e[35m')"
    [cyan]="$(echo -e '\e[36m')"
    [light_gray]="$(echo -e '\e[37m')"
    [gray]="$(echo -e '\e[90m')"
    [light_red]="$(echo -e '\e[91m')"
    [light_green]="$(echo -e '\e[92m')"
    [light_yellow]="$(echo -e '\e[93m')"
    [light_blue]="$(echo -e '\e[94m')"
    [light_purple]="$(echo -e '\e[95m')"
    [light_cyan]="$(echo -e '\e[96m')"
    [white]="$(echo -e '\e[97m')"
    [reset]="$(echo -e '\e[0m')"
)

## Logs a message with a timestamp
bask_log() {
    local timestamp
    timestamp="$(date "+%T$MILLI_SUFFIX")"
    echo "[${_bask_colors[gray]}${timestamp}${_bask_colors[reset]}] ${*}"
}

## Variations of log with colors
bask_log_error() {
    bask_log "${_bask_colors[red]}${*}${_bask_colors[reset]}"
}

bask_log_warning() {
    bask_log "${_bask_colors[yellow]}${*}${_bask_colors[reset]}"
}

bask_log_success() {
    bask_log "${_bask_colors[green]}${*}${_bask_colors[reset]}"
}

bask_log_info() {
    bask_log "${_bask_colors[cyan]}${*}${_bask_colors[reset]}"
}

bask_log_debug() {
    bask_log "${_bask_colors[gray]}${*}${_bask_colors[reset]}"
}
alias bask_log_notice=bask_log_debug

# Helper colorization function. Usage:
#
#    bask_colorize purple This will all be purple
#
# You may want to use in conjunction with bask_log to get a timestamp:
#
#    bask_log "$(bask_colorize purple This will all be purple)"
#
bask_colorize() {
    echo "${_bask_colors[$1]}${*:2}${_bask_colors[reset]}"
}

## List all defined functions beginning with `task_`
_bask_get_defined_tasks() {
    local IFS=$'\n'
    for task in $(typeset -F); do
        [[ ${task} == 'declare -f task_'* ]] && echo "${task:16}"
    done
}

## Fancy wrapper for `_bask_get_defined_tasks`
bask_list_tasks() {
    bask_log "Available tasks:"
    local -a tasks=($(_bask_get_defined_tasks))
    if [[ ${#tasks[@]} -eq 0 ]]; then
        bask_log "  ${_bask_colors[light_gray]}<none>${_bask_colors[reset]}"
        return
    fi
    for task in "${tasks[@]}"; do
        bask_log "  ${_bask_colors[cyan]}${task}${_bask_colors[reset]}"
    done
}

## Returns a human readable duration in ms
_bask_pretty_ms() {
    local -i ms="${1}"
    local result
    ## If zero or nothing
    if [[ -z ${ms} || ${ms} -lt 1 ]]; then
        echo "0 ms"
        return
    ## Only ms
    elif [[ ${ms} -lt 1000 ]]; then
        echo "${ms} ms"
        return
    ## Only seconds with trimmed ms point
    elif [[ ${ms} -lt 60000 ]]; then
        result=$((ms / 1000 % 60)).$((ms % 1000))
        echo "${result:0:4} s"
        return
    fi
    local -i parsed
    ## Days
    parsed=$((ms / 86400000))
    [[ ${parsed} -gt 0 ]] && result="${result} ${parsed} d"
    ## Hours
    parsed=$((ms / 3600000 % 24))
    [[ ${parsed} -gt 0 ]] && result="${result} ${parsed} h"
    ## Minutes
    parsed=$((ms / 60000 % 60))
    [[ ${parsed} -gt 0 ]] && result="${result} ${parsed} m"
    ## Seconds
    parsed=$((ms / 1000 % 60))
    [[ ${parsed} -gt 0 ]] && result="${result} ${parsed} s"
    ## Output result
    echo "${result}"
}

## Checks if program is accessible from current $PATH
_bask_is_defined() {
    hash "${@}" 2>/dev/null
}

bask_is_task_defined() {
    for task in "${@}"; do
        _bask_is_defined "task_${task}" || return
    done
}

bask_is_task_defined_verbose() {
    for task in "${@}"; do
        if ! _bask_is_defined "task_${task}"; then
            bask_log_error "Task '${task}' is not defined!"
            return 1
        fi
    done
}

_bask_run_task() {
    local -i time_start time_end
    local time_diff
    local task_color="${_bask_colors[cyan]}${1}${_bask_colors[reset]}"
    bask_log "Starting '${task_color}'..."
    time_start="$(date +%s$MILLIS)"
    "task_${1}" "${bask_flags[@]}"
    local exit_code=${?}
    time_end="$(date +%s$MILLIS)"
    time_diff="$(_bask_pretty_ms $((time_end - time_start)))"
    if [[ ${exit_code} -ne 0 ]]; then
        bask_log_error "Task '${1}'" \
            "failed after ${time_diff} (${exit_code})"
        return ${exit_code}
    fi
    bask_log "Finished '${task_color}'" \
        "after ${_bask_colors[purple]}${time_diff}${_bask_colors[reset]}"
}

## Run tasks sequentially.
bask_sequence() {
    bask_is_task_defined_verbose "${@}" || return
    for task in "${@}"; do
        _bask_run_task "${task}" || return 1
    done
}
alias bask_depends=bask_sequence

## Run tasks in parallel.
bask_parallel() {
    bask_is_task_defined_verbose "${@}" || return 1
    local -a pid
    local -i exits=0
    for task in "${@}"; do
        _bask_run_task "${task}" & pid+=(${!})
    done
    for pid in "${pid[@]}"; do
        wait "${pid}" || exits+=1
    done
    [[ ${exits} -eq 0 ]] && return 0
    [[ ${exits} -lt ${#} ]] && return 41 || return 42
}
alias bask_fork_join=bask_parallel

## Output command before execution
bask_run() {
    bask_log_notice "${@}"
    "${@}"
}

## Starts the initial task.
_bask_bootstrap() {
    ## Clear a trap we set up earlier
    trap - EXIT
    ## Parse arguments
    for arg in "${bask_args[@]}"; do
        if [[ ${arg} == -* ]]; then
            bask_flags+=("${arg}")
        else
            bask_tasks+=("${arg//-/_}")
        fi
    done
    ## Run tasks
    if [[ ${#bask_tasks[@]} -gt 0 ]]; then
        bask_sequence "${bask_tasks[@]}" || exit ${?}
        return 0
    fi
    if bask_is_task_defined "${bask_default_task}"; then
        _bask_run_task "${bask_default_task}" || exit ${?}
        return 0
    fi
    ## Nothing to run
    bask_list_tasks
}
