# shellcheck shell=bash

load './util/init.sh'

@test "Declares function 'enable_autoenv'" {
	source "$BATS_TEST_DIRNAME/../activate.sh"

	[ "$(type -t enable_autoenv)" = 'function' ]
}


@test "Works by default" {
	mkdir -p './d ir'
	printf '%s\n' 'echo abc' > './d ir/.env'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './d ir'
	"

	[[ "$output" == *'abc'* ]]
}

@test "Fails by default" {
	mkdir -p './d ir'

	run bash -c "
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './d ir'
	"

	[ -z "$output" ]
}

@test "Works with 'AUTOENV_ENV_FILENAME'" {
	mkdir -p './d ir'
	printf '%s\n' 'echo special_filename' > './d ir/coolenv'

	run bash -c "
		AUTOENV_ENV_FILENAME='coolenv'
		source '$BATS_TEST_DIRNAME/../activate.sh'
		cd './d ir'
	"

	[[ "$output" == *'special_filename'* ]]
}


