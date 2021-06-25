
# Autoenv: Directory-based Environments [![Build Status](https://travis-ci.com/inishchith/autoenv.svg?branch=master)](https://travis-ci.com/inishchith/autoenv)

Magic per-project shell environments. Very pretentious.

**Note**: you should probably use [direnv](https://direnv.net/) instead.
Simply put, it is higher quality software. But, autoenv is still great,
too. Maybe try both? :)

This image sums up the relationship between the two projects, very well:

![image](https://d3vv6lp55qjaqc.cloudfront.net/items/2f103O1A1R2T1k2w2M3c/776204239940493426%3Faccount_id=8.jpg)

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

You can also nest envs within each other. How awesome is that\!?

When executing, autoenv, will walk up the directories until the mount
point and execute all `.env` files beginning at the top.

## Usage


Follow the white rabbit:

    $ echo "echo 'whoa'" > project/.env
    $ cd project
    whoa

![image](http://media.tumblr.com/tumblr_ltuzjvbQ6L1qzgpx9.gif)



## Install

Install it easily:

### Mac OS X Using Homebrew

    $ brew install autoenv
    $ echo "source $(brew --prefix autoenv)/activate.sh" >> ~/.bash_profile

### Using pip

    $ pip install autoenv
    $ echo "source `which activate.sh`" >> ~/.bashrc

### Using git

    $ git clone git://github.com/inishchith/autoenv.git ~/.autoenv
    $ echo 'source ~/.autoenv/activate.sh' >> ~/.bashrc

### Using AUR

Arch Linux users can install
[autoenv](https://aur.archlinux.org/packages/autoenv/) or
[autoenv-git](https://aur.archlinux.org/packages/autoenv-git/) with
their favorite AUR helper.

You need to source activate.sh in your bashrc afterwards:

    $ echo 'source /usr/share/autoenv/activate.sh' >> ~/.bashrc

## Configuration

Before sourcing activate.sh, you can set the following variables:

  - `AUTOENV_AUTH_FILE`: Authorized env files, defaults to
    `~/.autoenv_authorized`
  - `AUTOENV_ENV_FILENAME`: Name of the `.env` file, defaults to `.env`
  - `AUTOENV_LOWER_FIRST`: Set this variable to flip the order of `.env`
    files executed
  - `AUTOENV_ENV_LEAVE_FILENAME`: Name of the `.env.leave` file,
    defaults to `.env.leave`
  - `AUTOENV_ENABLE_LEAVE`: Set this to a non-null string in order to
    enable source env when leaving
  - `AUTOENV_ASSUME_YES`: Set this variable to silently authorize the
    initialization of new environments

## Shells

autoenv is tested on:

  - bash
  - zsh
  - dash
  - fish is supported by
    [autoenv\_fish](https://github.com/loopbit/autoenv_fish)
  - more to come

## Alternatives

Direnv is an excellent alternative to autoenv, and includes the ability
to unset environment variables as well. It also supports the fish
terminal.

<https://direnv.net>

## Disclaimer

Autoenv overrides `cd`. If you already do this, invoke `autoenv_init`
within your custom `cd` after sourcing `activate.sh`.

Autoenv can be disabled via `unset cd` if you experience I/O issues with
certain file systems, particularly those that are FUSE-based (such as
`smbnetfs`).

## Attributions

> autoenv is one of [@kennethreitz](https://github.com/kennethreitz):org project and is now owned and maintained by [@inishchith](https://github.com/inishchith).
