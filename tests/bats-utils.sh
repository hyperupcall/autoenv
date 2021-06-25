# shellcheck shell=bash

unset TEST_FOO

declare -r AUTOENV_TEST_WD="$PWD"

setup() {
	export AUTOENV_ENV_FILENAME='.env'
	echo "$AUTOENV_TEST_WD" >&3
}

teardown() {
	builtin cd "$AUTOENV_TEST_WD"
}
