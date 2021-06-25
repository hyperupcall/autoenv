#!/usr/bin/env bats

# load "./bats-utils.sh"

setup_file() {
	export AUTOENV_TEST_WD="$PWD"
	cd ./tests
}

setup() {
	AUTOENV_ASSUME_YES=YES
	AUTOENV_ENV_FILENAME='.env'
}

teardown() {
	builtin cd "$AUTOENV_TEST_WD"
}

@test "Basic .env works" {
	builtin cd mocks

	AUTOENV_ENV_FILENAME='basic.env'

	[[ ! -v TEST_FOO ]]
	source "$AUTOENV_TEST_WD/activate.sh"
	[[ -v TEST_FOO ]]
}
