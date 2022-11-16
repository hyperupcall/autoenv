#!/usr/bin/env sh
set -e

note() {
	printf '%s\n' "install.sh: $1"
}

# shellcheck disable=SC2088
if command -v brew >/dev/null 2>&1; then
	brew install 'autoenv'
	dot_sh_file="'$(brew --prefix autoenv)/activate.sh'"
elif command -v npm >/dev/null 2>&1; then
	npm install -g '@hyperupcall/autoenv'
	dot_sh_file="'$(npm root -g)/@hyperupcall/autoenv/activate.sh'"
elif command -v git >/dev/null 2>&1; then
	git clone 'https://github.com/hyperupcall/autoenv' ~/.autoenv
	dot_sh_file="~/.autoenv/activate.sh"
else
	printf '%s\n' "Failed to install autoenv. Please install 'brew', 'npm', or 'git' first." >&2
	exit 1
fi

# Install for zsh
if command -v zsh >/dev/null 2>&1; then
	zprofile="${ZDOTDIR:-$HOME}/.zprofile"
	zlogin="${ZDOTDIR:-$HOME}/.zlogin"
	zshrc="${ZDOTDIR:-$HOME}/.zshrc"

	if [ -f "$zprofile" ]; then
		note "appending to file: $zprofile"
		printf '%s\n' "source $dot_sh_file" >> "$zprofile"
	elif [ -f "$zlogin" ]; then
		note "appending to file: $zlogin"
		printf '%s\n' "source $dot_sh_file" >> "$zlogin"
	fi

	if [ -f "$zshrc" ]; then
		note "appending to file: $zshrc"
		printf '%s\n' "source $dot_sh_file" >> "$zshrc"
	else
		note "creating file: $zshrc"
		printf '%s\n' "source $dot_sh_file" >> "$zshrc"
	fi
fi

# Install for bash
if command -v bash >/dev/null 2>&1; then
	if [ -f ~/.bash_profile ]; then
		note "appending to file: ~/.bash_profile"
		printf '%s\n' "source $dot_sh_file" >> ~/.bash_profile
	elif [ -f ~/.bash_login ]; then
		note "appending to file: ~/.bash_login"
		printf '%s\n' "source $dot_sh_file" >> ~/.bash_login
	fi

	if [ -f ~/.bashrc ]; then
		note "appending to file: ~/.bashrc"
		printf '%s\n' "source $dot_sh_file" >> ~/.bashrc
	else
		note "creating file: ~/.bashrc"
		printf '%s\n' "source $dot_sh_file" >> ~/.bashrc
	fi
fi

note 'DONE! Installation successfull!'
