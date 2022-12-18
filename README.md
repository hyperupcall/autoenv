# Autoenv: Directory-based Environments ![Build Status](https://github.com/hyperupcall/autoenv/actions/workflows/ci.yml/badge.svg)

Magic per-project shell environments

## What is it?

If a directory contains a `.env` file, it will automatically be executed
when you `cd` into it. When enabled (set `AUTOENV_ENABLE_LEAVE` to a non-empty string), if a directory contains a `.env.leave` file, it will
automatically be executed when you leave it.

This is great for...

- auto-activating virtualenvs
- auto-deactivating virtualenvs
- project-specific environment variables
- making millions

You can also nest envs within each other. How awesome is that!?

When executing, autoenv, will walk up the directories until the mount
point and execute all `.env` files beginning at the top.

## Usage

Follow the white rabbit:

```sh
$ echo "echo 'whoa'" > ./project/.env
$ cd ./project
whoa
```

![Mind blown GIF](http://media.tumblr.com/tumblr_ltuzjvbQ6L1qzgpx9.gif)

## Installation (automated)

Note that these are NEW instructions. If you are experiencing problems, please [file an issue](https://github.com/hyperupcall/autoenv/issues).

```sh
# with cURL
curl -#fLo- 'https://raw.githubusercontent.com/hyperupcall/autoenv/master/scripts/install.sh' | sh

# with wget
wget --show-progress -o /dev/null -O- 'https://raw.githubusercontent.com/hyperupcall/autoenv/master/scripts/install.sh' | sh
```

If you encounter some variant of a `curl: command not found` or `wget: command not found` error, please install either cURL or wget (with your package manager) and try again.

## Installation (manual)

Note that these are NEW instructions. If you are experiencing problems, please [file an issue](https://github.com/hyperupcall/autoenv/issues).

When installing manually, you first install autoenv with either Homebrew, npm, or Git. Then, you run a command to ensure autoenv is loaded when you open a terminal (this command depends on your [default shell](https://askubuntu.com/a/590901)).

### Installation Method

#### Using Homebrew

Prefer this if you're running macOS. Homebrew [must be installed](https://brew.sh).

<details>
<summary>Click to expand content</summary>

First, download the [autoenv](https://formulae.brew.sh/formula/autoenv) homebrew formulae:

```sh
$ brew install 'autoenv'
```

Then, execute run of the following to ensure autoenv is loaded when you open a terminal:

```sh
# For Zsh shell (default on macOS since Catalina)
$ printf '%s\n' "source $(brew --prefix autoenv)/activate.sh" >> "${ZDOTDIR:-$HOME}/.zprofile"

# For Bash shell (default on most Linux distributions)
$ printf '%s\n' "source $(brew --prefix autoenv)/activate.sh" >> ~/.bash_profile
```

</details>

#### Using npm

Prefer this if you're running Linux or an unsupported version of macOS. npm [must be installed](https://nodejs.org/en/download) (usually through NodeJS).

<details>
<summary>Click to expand content</summary>

First, download the [@hyperupcall/autoenv](https://www.npmjs.com/package/@hyperupcall/autoenv) npm package:

```sh
$ npm install -g '@hyperupcall/autoenv'
```

Then, execute run of the following to ensure autoenv is loaded when you open a terminal:

```sh
# For Zsh shell (default on macOS since Catalina)
$ printf '%s\n' "source $(npm root -g)/activate.sh" >> "${ZDOTDIR:-$HOME}/.zprofile"

# For Bash shell (default on most Linux distributions)
$ printf '%s\n' "source $(npm root -g)/activate.sh" >> ~/.bash_profile
```

</details>

#### Using Git

Use this if you cannot install with Homebrew or npm.

<details>
<summary>Click to expand content</summary>

First, clone this repository:

```sh
$ git clone 'https://github.com/hyperupcall/autoenv' ~/.autoenv
```

Then, execute run of the following to ensure autoenv is loaded when you open a terminal:

```sh
# For Zsh shell (default on macOS since Catalina)
$ printf '%s\n' "source ~/.autoenv/activate.sh" >> "${ZDOTDIR:-$HOME}/.zprofile"

# For Bash shell (default on most Linux distributions)
$ printf '%s\n' "source ~/.autoenv/activate.sh" >> ~/.bash_profile
```

</details>

## Configuration

_Before_ `source`ing `activate.sh`, you can set the following variables:

- `AUTOENV_AUTH_FILE`: Authorized env files; defaults to `~/.autoenv_authorized` if it exists, otherwise, `~/.local/state/autoenv/authorized_list`
- `AUTOENV_ENV_FILENAME`: Name of the `.env` file; defaults to `.env`
- `AUTOENV_LOWER_FIRST`: Set this variable to a non-empty string to flip the order of `.env` files executed
- `AUTOENV_ENV_LEAVE_FILENAME`: Name of the `.env.leave` file; defaults to `.env.leave`
- `AUTOENV_ENABLE_LEAVE`: Set this to a non-empty string in order to enable source env when leaving
- `AUTOENV_ASSUME_YES`: Set this variable to a non-empty string to silently authorize the initialization of new environments
- `AUTOENV_VIEWER`: Program used to display env files prior to authorization; defaults to `less -N`
- `AUTOENV_PRESERVE_CD`: Set this variable to a non-empty string to prevent the `cd` builtin from being overridden (to active autoenv, you must invoke `autoenv_init` within a `cd` function of your own)

## Shells

autoenv is tested on:

- Bash
- Zsh
- Dash
- Fish is supported by [autoenv_fish](https://github.com/loopbit/autoenv_fish)
- More to come

## Disclaimer

Autoenv overrides `cd` (unless `AUTOENV_PRESERVE_CD` is set to a non-empty string). If you already do this, invoke `autoenv_init` within your custom `cd` after sourcing `activate.sh`.

Autoenv can be disabled via `unset -f cd` if you experience I/O issues with certain file systems, particularly those that are FUSE-based (such as `smbnetfs`).

## Other info

To uninstall autoenv, see [`./docs/uninstall.md`](./docs/uninstall.md)

To update autoenv, see [`./docs/updating.md`](./docs/updating.md)

## Attributions

Autoenv was originally created by [@kennethreitz](https://github.com/kennethreitz). Later, ownership was transfered to [@inishchith](https://github.com/inishchith). As of August 22nd, 2021, Edwin Kofler ([@hyperupcall](https://github.com/hyperupcall)) owns and maintains the project
