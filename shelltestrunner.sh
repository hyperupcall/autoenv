# shellcheck shell=bash

# Until https://github.com/hyperupcall/shelltest gets a release,
# I've opted to manually create a test runner (using the same
# interface)

t_is_function() {
	if ! __tmp=$(type "$1" 2>/dev/null); then
		return 1
	fi

	# Most shells have a single line 'my_fn is a function'. In Bash,
	# the rest of the function is printed. In Zsh, it says 'my_fn is
	# a shell function'
	case $__tmp in
		"$1 is a function"*) return 0 ;;
		"$1 is a shell function"*) return 0 ;;
	esac
	
	return 1
}

t_assert() {
	if "$@"; then :; else
		printf '\033[41m%s\033[0m\n: %s' "Error" "Execution of command '$*' failed with exitcode $?" >&2
		return 1
	fi
}

main() {
	set -e

	printf '%s\n' "Sourcing api.sh"
	setup_file() { :; }
	teardown_file() { :; }
	setup() { :; }
	teardown() { :; }
	source ./shelltests/api.sh
	setup_file
	for fn in test_has_defined_functions; do
		printf '%s\n' "Running: $fn"
		setup
		"$fn"
		teardown
	done
	teardown_file
	printf '%s\n\n'
	

	printf '%s\n' "Sourcing cd.sh"
	setup_file() { :; }
	teardown_file() { :; }
	setup() { :; }
	teardown() { :; }
	source ./shelltests/cd.sh
	setup_file
	for fn in test_cd_noenv test_cd_dir test_cd_subdir test_cd_dir_and_subdir test_cd_dir_and_subdir_spaces test_cd_dir_and_subdir_colons; do
		printf '%s\n' "Running: $fn"
		setup
		"$fn"
		teardown
	done
	teardown_file
	printf '%s\n\n'

	printf '%s\n' "Sourcing env.sh"
	setup_file() { :; }
	teardown_file() { :; }
	setup() { :; }
	teardown() { :; }
	source ./shelltests/env.sh
	setup_file
	for fn in test_AUTOENV_ENV_FILENAME_works test_AUTOENV_ENV_FILENAME_works2; do
		printf '%s\n' "Running: $fn"
		setup
		"$fn"
		teardown
	done
	teardown_file
}
main "$@"