# Autoenv: Directory-based Environments ![Build Status](https://github.com/hyperupcall/autoenv/actions/workflows/ci.yml/badge.svg)

Magic per-project shell environments

## What is it?

If a directory contains a `.env` file, it will automatically be executed
when you `cd` into it. When enabled (set `AUTOENV_ENABLE_LEAVE` to a
non-null string), if a directory contains a `.env.leave` file, it will
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
$ echo "echo 'whoa'" > project/.env
$ cd project
whoa
```

![Mind blown GIF](http://media.tumblr.com/tumblr_ltuzjvbQ6L1qzgpx9.gif)

## Install

Install it easily:

### MacOS using Homebrew

```sh
$ brew install autoenv
$ echo "source $(brew --prefix autoenv)/activate.sh" >> ~/.bash_profile
```

### Using Git

```sh
$ git clone https://github.com/hyperupcall/autoenv ~/.autoenv
$ echo "source ~/.autoenv/activate.sh" >> ~/.bashrc
```

### Using npm

Download the [@hyperupcall/autoenv](https://www.npmjs.com/package/@hyperupcall/autoenv) package

```sh
$ npm install -g '@hyperupcall/autoenv'
$ echo "source \"\$(npm root -g)/@hyperupcall/autoenv/activate.sh\"" >> ~/.bashrc
```

## Configuration

Before sourcing activate.sh, you can set the following variables:

- `AUTOENV_AUTH_FILE`: Authorized env files, defaults to
  `~/.autoenv_authorized` if it exists; otherwise, `~/.local/state/autoenv/authorized_list`
- `AUTOENV_ENV_FILENAME`: Name of the `.env` file, defaults to `.env`
- `AUTOENV_LOWER_FIRST`: Set this variable to a non-empty string to flip the order of `.env`
  files executed
- `AUTOENV_ENV_LEAVE_FILENAME`: Name of the `.env.leave` file,
  defaults to `.env.leave`
- `AUTOENV_ENABLE_LEAVE`: Set this to a non-empty string in order to
  enable source env when leaving
- `AUTOENV_ASSUME_YES`: Set this variable to a non-empty string to silently authorize the
  initialization of new environments
- `AUTOENV_VIEWER`: Program used to display env files prior to authorization.
  Default: `"less -N"`.

## Shells

autoenv is tested on:

- Bash
- Zsh
- Dash
- Fish is supported by
  [autoenv_fish](https://github.com/loopbit/autoenv_fish)
- More to come

## Alternatives

[direnv](https://direnv.net) is an excellent alternative to autoenv, and includes the ability to unset environment variables as well. It also supports the Fish terminal.

## Disclaimer

Autoenv overrides `cd`. If you already do this, invoke `autoenv_init` within your custom `cd` after sourcing `activate.sh`.

Autoenv can be disabled via `unset cd` if you experience I/O issues with certain file systems, particularly those that are FUSE-based (such as `smbnetfs`).

## Attributions

Autoenv was originally created by [@kennethreitz](https://github.com/kennethreitz). Later, ownership was transfered to [@inishchith](https://github.com/inishchith). As of August 22nd, 2021, Edwin Kofler ([@hyperupcall](https://github.com/hyperupcall)) owns and maintains the project
