# shellcheck shell=sh
# shellcheck disable=SC1091

setup_file() {
	export AUTOENV_ASSUME_YES='yes'
	. ./activate.sh
}

teardown_file() {
	rm -rf './dir' # TODO: remov when shelltest uses tempdirs
}

setup() {
	rm -rf './dir' # TODO: remove when shelltest uses tempdirs
}

# The following functions must exist for API stability
test_defined_functions() {
	t_is_function 'enable_autoenv'
	t_is_function 'autoenv_init'
}

test_works_only_dir() {
	mkdir -p './dir'
	printf '%s\n' "printf '%s\n' 'something'" > './dir/.env'

	output=$(cd './dir')
	t_assert [ "$output" = 'something' ]
}

test_works_only_subdir() {
	mkdir -p './dir/subdir'
	printf '%s\n' "printf '%s\n' 'something2'" > './dir/.env'
	
	output=$(cd './dir/subdir')
	t_assert [ "$output" = 'something2' ]
}

test_works_subdir_and_parentdir() {
	mkdir -p './dir/subdir'

	printf '%s\n' "printf '%s\n' 'sierra'" > './dir/.env'
	printf '%s\n' "printf '%s\n' 'tango'" > './dir/subdir/.env'

	output=$(cd './dir/subdir')
	t_assert [ "$output" = 'sierra
tango' ]
}