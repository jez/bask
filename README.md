# Bask

[![Gitter](https://img.shields.io/gitter/room/jez/bask.svg?maxAge=2592000)][gitter]
[![standard-readme compliant](https://img.shields.io/badge/standard--readme-OK-brightgreen.svg)](https://github.com/RichardLitt/standard-readme)
[![tl;drLegal LGPL 3.0](https://img.shields.io/badge/tl%3BdrLegal-LGPL_3.0-blue.svg)](https://tldrlegal.com/license/gnu-lesser-general-public-license-v3-(lgpl-3))

> :sunglasses: Bask in the convenience of a task runner for bash

Bask was initially forked from [bash-task-runner]. It was forked for a couple
reasons:

- I needed a to vendor it for an unrelated project.
- I wanted to drop the dependency on GNU coreutils.
- I wanted to improve the name :smirk:

I actively follow upstream changes. If I'm missing a compatible feature that was
added upstream, feel free to notify me via an issue, pull request, or message on
Gitter.

Bask's first commit is a squashed version of `bash-task-runner` at the time it
was forked. For a complete list of changes, just use the commit log.

It's still under construction. This is the current list of TODOs:

- [x] Rename `runner` to `bask`
- [x] Use `/usr/bin/env bash` everywhere
- [ ] Add Travis CI for `shellcheck`
- [ ] Add Travis CI for Standard Readme
- [x] Remove dependence on GNU coreutils
  - [x] Refactor to no longer need `gdate`
  - [x] Refactor to no longer need `greadlink`
- [x] Remove index.sh
- [ ] Flesh out README with better usage information
- [ ] Add to popular package managers
  - [ ] Add Homebrew formula
  - [ ] Investigate adding a Debian package
  - [ ] Investigate adding an NPM package
- [ ] Add zsh completions
  - [ ] Submit zsh completions upstream

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
## Table of Contents

- [Installation](#installation)
  - [Manual](#manual)
  - [Path](#path)
- [Contribute](#contribute)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Installation

Right now there are no installation methods through package managers. Shortly
there will be installation through Homebrew (and potentially a Debian package).

### Manual

All you really need is `src/bask.sh` in your project folder:

```shell
wget https://raw.githubusercontent.com/jez/bask/master/src/bask.sh
```

### Path

Depending on your preferences, you may also want to put Bask on your PATH:

```
git clone https://github.com/jez/bask

export PATH="$PATH:$(pwd)/bask/bin"
```

## Contribute

Bask was forked from [bash-task-runner]. Chances are that if you have an issue
or pull request it can be made against that upstream repo.

If your issue pertains to functionality specifically only provided here, then
feel free to voice your concerns here. If you're confused where to make the
request, feel free to ask in [Gitter][gitter] first.

## License

GNU Lesser General Public License v3 (LGPL-3.0). See License.md

| Copyright (c)   | Commits |
| --------------- | ------- |
| Aleksej Komarov | 8a28f72 |
| Jake Zimmerman  | 5e92344 |

<!-- TODO(jez): Update commit after --amend -->

[bash-task-runner]: https://github.com/stylemistake/bash-task-runner
[gitter]: https://gitter.im/jez/bask
