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
	[[ "$output" == *'New or modified env file detected'* ]]
	[[ "$output" == *'echo 123'* ]]

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir'
	"
	[[ "$output" != *'New or modified env file detected'* ]]
	[[ "$output" != *'echo 123'* ]]
	[[ "$output" == *'123'* ]]
}

@test "Entering 'n' prompts again" {
	mkdir -p './dir'
	printf '%s\n' 'echo 123' > './dir/.env'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir' <<< 'n'
	"
	[[ "$output" == *'New or modified env file detected'* ]]
	[[ "$output" == *'echo 123'* ]]

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir' <<< 'n'
	"
	[[ "$output" == *'New or modified env file detected'* ]]
	[[ "$output" == *'echo 123'* ]]
}
