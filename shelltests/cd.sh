# shellcheck shell=sh

setup_file() {
	export AUTOENV_ASSUME_YES='yes'
	. ./activate.sh
}

# TODO: remove when shelltest uses tempdirs
teardown_file() {
	rm -rf './dir' './d ir' './d:ir'
}

setup() {
	rm -rf './dir' './d ir' './d:ir'
}


test_cd_noenv() {
	mkdir -p './dir'

	output=$(cd './dir')
	t_assert [ -z "$output" ]
}

test_cd_dir() {
	mkdir -p './dir'
	printf '%s\n' "printf '%s\n' 'something'" > './dir/.env'

	output=$(cd './dir')
	t_assert [ "$output" = 'something' ]
}

test_cd_subdir() {
	mkdir -p './dir/subdir'
	printf '%s\n' "printf '%s\n' 'something2'" > './dir/.env'

	output=$(cd './dir/subdir')
	t_assert [ "$output" = 'something2' ]
}

test_cd_dir_and_subdir() {
	mkdir -p './dir/subdir'

	printf '%s\n' "printf '%s\n' 'sierra'" > './dir/.env'
	printf '%s\n' "printf '%s\n' 'tango'" > './dir/subdir/.env'

	output=$(cd './dir/subdir')
	t_assert [ "$output" = 'sierra
tango' ]
}

test_cd_dir_and_subdir_spaces() {
	mkdir -p './d ir/s ubdir'

	printf '%s\n' "printf '%s\n' 'sierra'" > './d ir/.env'
	printf '%s\n' "printf '%s\n' 'tango'" > './d ir/s ubdir/.env'

	output=$(cd './d ir/s ubdir')
	t_assert [ "$output" = 'sierra
tango' ]
}

test_cd_dir_and_subdir_colons() {
	mkdir -p './d:ir/s:ubdir'

	printf '%s\n' "printf '%s\n' 'sierra'" > './d:ir/.env'
	printf '%s\n' "printf '%s\n' 'tango'" > './d:ir/s:ubdir/.env'

	output=$(cd './d:ir/s:ubdir')
	t_assert [ "$output" = 'sierra
tango' ]
}
