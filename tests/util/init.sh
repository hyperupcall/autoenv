# shellcheck shell=bash

setup() {
	export AUTOENV_AUTH_FILE="$BATS_FILE_TMPDIR/auth.txt"
	export AUTOENV_ASSUME_YES='yes'

	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
