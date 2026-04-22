# shellcheck shell=bash

load './util/init.sh'

@test "Declares function 'enable_autoenv'" {
	source "$BATS_TEST_DIRNAME/../activate.sh"

	[ "$(type -t enable_autoenv)" = 'function' ]
}


@test "Works by default" {
	mkdir -p './dir'
	printf '%s\n' 'echo abc' > './dir/.env'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir'
	"

	assert_success
	assert_line 'abc'
}

@test "Works with .autoenv by default" {
	mkdir -p './dir'
	printf '%s\n' 'echo autoenv_file' > './dir/.autoenv'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir'
	"

	assert_success
	assert_line 'autoenv_file'
}

@test "Sources .env before .autoenv by default" {
	mkdir -p './dir'
	printf '%s\n' 'echo env_file' > './dir/.env'
	printf '%s\n' 'echo autoenv_file' > './dir/.autoenv'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir'
	"

	assert_success
	assert_line --index 0 'env_file'
	assert_line --index 1 'autoenv_file'
}

@test "Fails by default" {
	mkdir -p './dir'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir'
	"

	assert_success
	assert_output ''
}

@test "Works with 'AUTOENV_ENV_FILENAME'" {
	mkdir -p './dir'
	printf '%s\n' 'echo special_filename' > './dir/coolenv'

	run bash -c "
		AUTOENV_ENV_FILENAME='coolenv'
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir'
	"

	assert_success
	assert_line 'special_filename'
}

@test "AUTOENV_ENV_FILENAME keeps single-name override behavior" {
	mkdir -p './dir'
	printf '%s\n' 'echo ignored' > './dir/.autoenv'

	run bash -c "
		AUTOENV_ENV_FILENAME='coolenv'
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './dir'
	"

	assert_success
	assert_output ''
}
