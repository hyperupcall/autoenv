# shellcheck shell=bash

source './tests/util/test_util.sh'
source './node_modules/@hyperupcall/bats-all/load.bash'

setup() {
	unset -v BASH_ENV
	export AUTOENV_AUTH_FILE="$BATS_FILE_TMPDIR/auth.txt"
	export AUTOENV_ASSUME_YES='yes'

	cd "$BATS_TEST_TMPDIR"
}

teardown() {
	cd "$BATS_SUITE_TMPDIR"
}
