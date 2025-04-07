# shellcheck shell=bash

load './util/init.sh'

@test "Variable AUTOENV_CUR_FILE is exported and correct" {
	source "$BATS_TEST_DIRNAME/../activate.sh"
	cat > .env <<"EOF"
printf '%s\n' "file: $AUTOENV_CUR_FILE"
if export -p | grep -q AUTOENV_CUR_FILE; then
	printf '%s\n' "AUTOENV_CUR_FILE exported"
fi
if [[ -o allexport ]]; then
	printf '%s\n' "option: allexport set"
fi
EOF
	local expected_cur_file="$PWD/.env"

	run cd .
	[ "$output" = "file: $expected_cur_file
AUTOENV_CUR_FILE exported
option: allexport set" ]
}

@test "Variable AUTOENV_CUR_DIR is exported and correct" {
	source "$BATS_TEST_DIRNAME/../activate.sh"
	cat > .env <<"EOF"
printf '%s\n' "file: $AUTOENV_CUR_DIR"
if export -p | grep -q AUTOENV_CUR_DIR; then
	printf '%s\n' "AUTOENV_CUR_DIR exported"
fi
if [[ -o allexport ]]; then
	printf '%s\n' "option: allexport set"
fi
EOF
	local expected_cur_file="$PWD"

	run cd .
	[ "$output" = "file: $expected_cur_file
AUTOENV_CUR_DIR exported
option: allexport set" ]
}
