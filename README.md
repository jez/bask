# Bask

[![Travis](https://img.shields.io/travis/jez/bask.svg?maxAge=2592000)](https://travis-ci.org/jez/bask)
[![npm](https://img.shields.io/npm/v/bask.svg?maxAge=2592000)](https://www.npmjs.com/package/bask)
[![Gitter](https://img.shields.io/gitter/room/jez/bask.svg?maxAge=2592000)][gitter]
[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-brightgreen.svg)](https://github.com/RichardLitt/standard-readme)
[![tl;drLegal LGPL 3.0](https://img.shields.io/badge/tl%3BdrLegal-LGPL_3.0-blue.svg)](https://tldrlegal.com/license/gnu-lesser-general-public-license-v3-(lgpl-3))

> :sunglasses: Bask in the convenience of a task runner for bash

Bask is a task runner for Bash. It's like Make with a bunch of shell targets,
but without the `.PHONY`'s everywhere, and nicer because there's no more Make
syntax. The main difference is that tasks are always run in Bask, but only run
if targets are out of date in Make.

If you're writing a Makefile with all `.PHONY` targets, chances are that Bask is
really what you want.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

- [Background](#background)
- [Install](#install)
  - [Simple (vendored)](#simple-vendored)
  - [Submodule (vendored)](#submodule-vendored)
  - [Homebrew](#homebrew)
  - [NPM](#npm)
  - [Git + PATH](#git--path)
- [Usage](#usage)
- [CLI](#cli)
  - [Flags](#flags)
  - [Tab Completion](#tab-completion)
- [API](#api)
  - [Baskfile](#baskfile)
    - [Default Tasks](#default-tasks)
  - [Methods](#methods)
    - [`bask_depends`](#bask_depends)
    - [`bask_fork_join`](#bask_fork_join)
    - [`bask_run`](#bask_run)
    - [`bask_log`](#bask_log)
    - [`bask_colorize`](#bask_colorize)
    - [`bask_list_tasks`](#bask_list_tasks)
    - [`bask_is_task_defined`](#bask_is_task_defined)
- [Contribute](#contribute)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Background

Bask was initially forked from [bash-task-runner]. It was forked for a couple
reasons:

- I needed to vendor it for an unrelated project.
- I wanted to drop the dependency on GNU coreutils.
- I wanted to improve the name :smirk:

I actively follow upstream changes. If I'm missing a compatible feature that was
added upstream, feel free to notify me via an issue, pull request, or message on
Gitter.

Bask's first commit is a squashed version of `bash-task-runner` at the time it
was forked. For a complete list of changes, just use the commit log.


## Install

Each of the below installation methods is differentiated along two properties:

- **Local to project**
  - Whether Bask will be installed locally to your project or globally on a
    system.
  - This is good for CI builds and spinning up multiple people on your project
- **CLI-enabled**
  - Whether you will be able to use the `bask` command from your prompt.
  - Useful for local development, tab completion, and convenience.

You may want to combine multiple installation methods in order to satisfy both
of these requirements. In particular, we recommend [**Simple
(vendored)**](#simple-vendored) with a method that gives you a CLI and is
compatible with your system.

|                      | Local to Project   | CLI-enabled        |
| ---                  | ---                | ---                |
| Simple (vendored)    | :white_check_mark: | :no_entry_sign:    |
| Submodule (vendored) | :white_check_mark: | :white_check_mark: |
| Homebrew             | :no_entry_sign:    | :white_check_mark: |
| NPM                  | :white_check_mark: | :white_check_mark: |
| Git + PATH           | :no_entry_sign:    | :white_check_mark: |

### Dependencies

Currently Bask requires Bash 4.2+.

### Simple (vendored)

Just drop `src/bask.sh` anywhere in your project folder:

```shell
wget https://raw.githubusercontent.com/jez/bask/master/src/bask.sh
```

Then skip to [Usage](#usage) for how to use a vendored Bask installation.

### Submodule (vendored)

If you'd like a slightly better story around updating Bask when vendored, you
can use a Git submodule, if you're [familiar with submodules][submodules]:

```shell
git submodule add https://github.com/jez/bask
```

> Note that if submodules are too heavy-handed, you can get the same effect
> (without the ease of updating) by just unzip'ing Bask's source into your
> project.

You should now be able to access `bask.sh` within the submodule. Additionally,
you can access the CLI with `./bask/bin/bask`. You can make this more ergonomic
by altering your PATH:

```shell
export PATH="$PATH:./bask/bin"
```

Then skip to [Usage](#usage) to learn more.

### Homebrew

On OS X, installing Bask globally is simple if you have Homebrew:

```shell
brew install jez/formulae/bask
```

Then skip to [Usage](#usage) to learn more.

### NPM

If you don't mind the additional dependency on the NPM ecosystem, you can
install Bask with NPM:

```shell
# --- Local to Project --- #
npm install --save bask

# to enable CLI:
export PATH="PATH:./node_modules/.bin"

# --- Global --- #
npm install -g bask
```

Then skip to [Usage](#usage) to learn more.

### Git + PATH

If Bask is not available in a package manager for your system, you can clone
Bask to your computer, and adjust your PATH to contain the installation
location:

```
git clone https://github.com/jez/bask

export PATH="$PATH:$(pwd)/bask/bin"
```

Then skip to [Usage](#usage) for how to use the CLI.


## Usage

You use Bask in conjunction with a `Baskfile`. A basic `Baskfile` looks like
this:

```shell
task_foo() {
  ## Do something...
}

task_bar() {
  ## Do something...
}
```

**Optional**: if you want your `Baskfile` to be a standalone script, add this
to the beginning (works best in conjunction with a vendored installation):

```shell
#!/usr/bin/env bash
cd "$(dirname "$0")" || exit
source ./path/to/bask.sh
```

You invoke Bask using `bask [task ...]`:

```console
$ bask foo bar
[21:37:43.754] Starting 'foo'
[21:37:43.755] Finished 'foo' after 1 ms
[21:37:43.756] Starting 'bar'
[21:37:43.757] Finished 'bar' after 1 ms
```

Or, if your `Baskfile` sources `bash.sh`:

```console
bash Baskfile foo bar
```

## CLI

NOTE: Please see `bask -h` for complete, up-to-date CLI usage information.

```
Usage: bask [options] [task] [task_options] ...
Options:
  -C <dir>, --directory=<dir>  Change to <dir> before doing anything.
  --completion=<shell>         Output code to activate task completions.
                               Supported shells: 'bash'.
  -f <file>, --file=<file>     Use <file> as a Baskfile.
  -l, --list-tasks             List available tasks.
  -h, --help                   Print this message and exit.
```

### Flags

All flags you pass after the task names are passed to your tasks.

```bash
task_foo() {
  echo ${@}
}

$ bask foo --production
--production
```

To pass options to the `bask` CLI specifically, you must provide them
before any task names:

```bash
$ bask -f scripts/tasks.sh foo
```

### Tab Completion

The `bask` CLI supports autocompletion for task names (bash only). Simply add
the following line your `~/.bashrc`:

```shell
eval $(bask --completion=bash)
```


## API

This section covers all the features of Bask.

### Baskfile

Your Baskfile can be named any of the following. Using a `.sh` suffix helps with
things like editor syntax highlighting.

```
Baskfile
Baskfile.sh
baskfile
baskfile.sh
```


#### Default Tasks

You can specify a default task in your Baskfile. It will run when no arguments
are provided. There are two ways to do this:

```shell
task_default() {
  # do something ...
}
```

```shell
bask_default_task="foo"
task_foo() {
  # do something ...
}
```


### Methods

Bask exposes a number of functions for manipulating dependencies among tasks,
for logging, and for a few utilities.

#### `bask_depends`

> Alias: `bask_sequence`

This function is for declaring dependencies of a task. It should be invoked
within another task.

Usage: `bask_depends [task ...]`

```shell
task_default() {
  bask_depends foo bar
  # Output:
  # [21:50:33.194] Starting 'foo'
  # [21:50:33.195] Finished 'foo' after 1 ms
  # [21:50:33.196] Starting 'bar'
  # [21:50:33.198] Finished 'bar' after 2 ms
}
```

If any task return non-zero, the entire sequence of tasks is aborted with
an error.

Note that return codes can be bubbled up using `... || return`, so you can
conveniently abort tasks prematurely like this:

```
maybe_error() {
  return $(($RANDOM % 2))
}

task_try() {
  echo "Bad"
  maybe_error || return    # <-- bubbles error up if error
  # code for when no error
}

task_finally() {
  echo "Good"
}

task_foo() {
  bask_depends try finally
}
```

#### `bask_fork_join`

> Alias: `bask_parallel`

Bask also allows for spawning independent work in parallel, and resuming the
task when all tasks have completed:

Usage: `bask_fork_join [task ...]`

```shell
task_default() {
  bask_fork_join sleep3 sleep5
  bask_log "after"
  # [21:50:33.194] Starting 'sleep3'
  # [21:50:33.194] Starting 'sleep5'
  # [21:50:36.396] Finished 'sleep3' after 3.20 s
  # [21:50:38.421] Finished 'sleep5' after 5.23 s
  # [21:50:38.422] after
}
```

Note that all tasks always run to completion, unlike with `bask_depends`.

#### `bask_run`

This will log a timestamp plus the command with its arguments, then run it.

Usage: `bask_run <command --with args>`

Note that the command must be a simple command--things like pipes, `&&`, `||`,
`{ ... }`, etc. will not work.


#### `bask_log`

You can log information inside Bask tasks using one of the five `bask_log`
helpers:

| Function           | Description                                          |
| ---                | ---                                                  |
| `bask_log`         | Adds a log line (with time), in the foreground color |
| `bask_log_success` | Same as above, but in green                          |
| `bask_log_error`   | Same as above, but in red                            |
| `bask_log_warning` | Same as above, but in yellow                         |
| `bask_log_info`    | Same as above, but in cyan                           |
| `bask_log_debug`   | Same as above, but in gray                           |

Usage: `bask_log message`

All logging functions have the same usage.

#### `bask_colorize`

While the dedicated logging functions are helpful, sometimes you want finer
control over your colors.

Usage: `bask_colorize <colorname> message`

Where `colorname` is one of

|           |             |              |            |              |            |
| ---       | ---         | ---          | ---        | ---          | ---        |
| black     | gray        | light_gray   | white      |              |            |
| red       | green       | yellow       | blue       | purple       | cyan       |
| light_red | light_green | light_yellow | light_blue | light_purple | light_cyan |

```shell
# Simple example
bask_colorize purple This will all be purple

# Use with `bask_log` to get a timestamp:
bask_log "$(bask_colorize purple This will all be purple)"
```

Note that your message will be wrapped with the appropriate color **and** reset
codes. You don't need to worry about manually turning the color back to normal.

#### `bask_list_tasks`

The default behavior if no tasks are specified at the command line and no
default tasks are registered is to list all available tasks. You can manually
invoke that with this function.

Usage: `bask_list_tasks`

```shell
task_list() {
  bask_list_tasks
}
```

#### `bask_is_task_defined`

Utility function for checking whether a list of tasks are defined. Used
internally, but exposed externally.

Usage: `bask_is_task_defined [task ...]`

Note that you can pass in more than one task for checking.

Alternatively, you can use `bask_is_task_defined_verbose`, which will do the
same checks, but log an error if any task is not defined.


## Contribute

Bask was forked from [bash-task-runner]. Chances are that if you have an issue
or pull request it can be made against that upstream repo.

If your issue pertains to functionality specifically only provided here, then
feel free to voice your concerns here. If you're confused where to make the
request, feel free to ask in [Gitter][gitter] first.

## License

GNU Lesser General Public License v3 (LGPL-3.0). See License.md

| Copyright (c)   | Commits  |
| --------------- | -------- |
| Aleksej Komarov | 8a28f72  |
| Jake Zimmerman  | 5e92344+ |

<!-- TODO(jez): Update commit after --amend -->

[bash-task-runner]: https://github.com/stylemistake/bash-task-runner
[gitter]: https://gitter.im/jez/bask
[submodules]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
