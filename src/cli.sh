#!/usr/bin/env bash

## NOTE: This script depends on bask.sh to be loaded first.

## Globals that come from the entry points
declare -g SRCDIR

## Baskfile names that CLI will be looking for in current directory.
declare -ga baskfile_default_names=(
    'baskfile.sh'
    'Baskfile.sh'
    'baskfile'
    'Baskfile'
)

## Global variables that hold CLI settings
declare -g bask_file
declare -g bask_directory
declare -g bask_list_tasks

## Outputs an error message and exits the script
bask_cli_error() {
    trap - EXIT
    bask_log_error "${@}"
    exit 2
}

## Outputs a nice help message
bask_cli_help() {
    trap - EXIT
    echo "Usage: ${0} [options] [task] [task_options] ..."
    echo "Options:"
    echo "  -C <dir>, --directory=<dir>  Change to <dir> before doing anything."
    echo "  --completion=<shell>         Output code to activate task completions."
    echo "                               Supported shells: 'bash'."
    echo "  -f <file>, --file=<file>     Use <file> as a Baskfile."
    echo "  -l, --list-tasks             List available tasks."
    echo "  -h, --help                   Print this message and exit."
    exit 0
}

## Outputs a list of tasks
bask_cli_list_tasks() {
    trap - EXIT
    _bask_get_defined_tasks
    exit 0
}

## Outputs code to activate task completions
bask_cli_get_completions_code() {
    trap - EXIT
    local shell="${1:-bash}"
    echo "source $SRCDIR/../completion/bask.${shell}"
    exit 0
}

## Parses CLI-specific flags.
## Must take "${bask_args[@]}" as the argument.
bask_cli_parse_args() {
    ## Clean up currently defined arguments
    bask_args=()
    ## Iterate over the provided arguments
    while [[ ${#} -gt 0 ]]; do
        ## Stop parsing after the first non-flag argument
        if [[ ${1} != -* ]]; then
            break
        fi
        ## Help message
        if [[ ${1} == '-h' || ${1} == '--help' ]]; then
            bask_cli_help
        fi
        ## List tasks
        if [[ ${1} == '-l' || ${1} == '--list-tasks' ]]; then
            bask_list_tasks="true"
        fi
        ## Return the completions code
        if [[ ${1} == '--completion='* ]]; then
            bask_cli_get_completions_code "${1#*=}"
        fi
        ## Baskfile override
        if [[ ${1} == '-f' ]]; then
            [[ -z ${2} ]] && bask_cli_error "Missing an argument after ${1}"
            bask_file="${2}"
            shift 2
            continue
        fi
        if [[ ${1} == '--file='* ]]; then
            bask_file="${1#*=}"
            shift 1
            continue
        fi
        ## Current directory override
        if [[ ${1} == '-C' ]]; then
            [[ -z ${2} ]] && bask_cli_error "Missing an argument after ${1}"
            bask_directory="${2}"
            shift 2
            continue
        fi
        if [[ ${1} == '--directory='* ]]; then
            bask_directory="${1#*=}"
            shift 1
            continue
        fi
        ## Append unclassified flags back to bask_args
        bask_args+=("${1}")
        shift 1
    done
    ## Append remaining arguments that will be passed to the
    ## bootstrap function
    bask_args+=("${@}")
}

## Parse the actual arguments
bask_cli_parse_args "${bask_args[@]}"

## Try to change the current directory
if [[ -n ${bask_directory} ]]; then
    if [[ ! -d ${bask_directory} ]]; then
        bask_cli_error "'${bask_directory}' is not a directory!"
    fi
    cd "${bask_directory}" || bask_cli_error "Could not change directory!"
fi

## Try to find a Baskfile
if [[ -n ${bask_file} ]]; then
    if [[ ! -f ${bask_file} ]]; then
        bask_cli_error "'${bask_file}' is not a file!"
    fi
else
    for file in "${baskfile_default_names[@]}"; do
        if [[ -f ${file} ]]; then
            bask_file="${file}"
            break
        fi
    done
fi

## Baskfile not found
if [[ -z ${bask_file} ]]; then
    bask_cli_error 'No Baskfile found.'
fi

## Source the Baskfile
# shellcheck disable=SC1090
source "${bask_file}"

if [ -n "${bask_list_tasks}" ]; then
    bask_cli_list_tasks
fi
