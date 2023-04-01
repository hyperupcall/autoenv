# shellcheck shell=bash

test_util.init_env() {
	mkdir -p './dir'
	printf '%s\n' "$1" > './dir/.env'
}

test_util.activate_env() {
	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir'
		$1
	"
}
