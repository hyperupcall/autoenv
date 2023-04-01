# shellcheck shell=bash

load './util/init.sh'

@test "Works with regular path" {
	mkdir -p './dir'
	printf '%s\n' 'echo a' > './dir/.env'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir'
		$1
	"

	assert_success
	assert_line 'a'
}
