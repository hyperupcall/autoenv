# shellcheck shell=sh

setup_file() {
	export AUTOENV_ASSUME_YES='yes'
	. ./activate.sh
}
# TODO: remov when shelltest uses tempdirs
teardown_file() {
	rm -rf './dir' './d ir' './d:ir'
}

setup() {
	rm -rf './dir' './d ir' './d:ir'
}

# The following functions must exist for API stability
test_AUTOENV_ENV_FILENAME_works() {
	AUTOENV_ENV_FILENAME='o ther'

	mkdir -p './dir'

	printf '%s\n' "printf '%s\n' 'WOOF'" > './dir/o ther'

	output=$(cd './dir')
	t_assert [ "$output" = 'WOOF' ]
}

test_AUTOENV_ENV_AUTHFILE_works() {
	AUTOENV_AUTH_FILE='a uthfile'

	mkdir -p './dir'

	printf '%s\n' "printf '%s\n' 'WOOF'" > './dir/.env'

	output=$(cd './dir')
	t_assert [ "$output" = 'WOOF' ]
}
