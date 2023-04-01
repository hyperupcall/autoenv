# shellcheck shell=bash

load './util/init.sh'

setup() {
	export AUTOENV_AUTH_FILE="$BATS_FILE_TMPDIR/auth.txt"

	cd "$BATS_TEST_TMPDIR"
}

@test "Entering 'y' no longer prompts" {
	mkdir -p './dir'
	printf '%s\n' 'echo 123' > './dir/.env'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir' <<< 'y'
	"

	assert_success
	assert_line -p 'New or modified env file detected'
	assert_line -p 'echo 123'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir'
	"

	assert_success
	refute_line -p 'New or modified env file detected'
	refute_line -p 'echo 123'
	assert_line '123'
}

@test "Entering 'n' prompts again" {
	mkdir -p './dir'
	printf '%s\n' 'echo 123' > './dir/.env'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir' <<< 'n'
	"
	assert_success
	assert_line -p 'New or modified env file detected'
	assert_line -p 'echo 123'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir' <<< 'n'
	"
	assert_success
	assert_line -p 'New or modified env file detected'
	assert_line -p 'echo 123'
}

@test "Entering 'd' does not prompt again" {
	mkdir -p './dir'
	printf '%s\n' 'echo 123' > './dir/.env'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir' <<< 'd'
	"
	assert_success
	assert_line -p 'New or modified env file detected'
	assert_line -p 'echo 123'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir' <<< 'y'
	"
	assert_success
	assert_output ''
}

