#!/usr/bin/env bash

shopt -s globstar

get_shell_files() {
  echo "Finding shell files..." 1>&2

  for file in ./bin/**/* ./src/**/*; do
    # check for .sh ending
    if [[ "$file" =~ .sh$ ]]; then
      # Also report to stderr so we can get a log
      echo "$file" | tee /dev/fd/2
    # check if has bash in shebang on first line, and print if so
    elif [ -f "$file" ]; then
      # Also report to stderr so we can get a log
      awk '/#!\/.*bash/ && NR < 2 { print FILENAME; }' "$file" | tee /dev/fd/2
    fi
  done

  echo "Done finding shell files." 1>&2
}

get_files_and_check() {
  get_shell_files | xargs shellcheck
}

task_default() {
  get_files_and_check
}
