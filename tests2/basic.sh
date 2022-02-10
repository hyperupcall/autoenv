# shellcheck shell=sh
# shellcheck disable=SC1091

setup_file() {
	. ./activate.sh
}

# function 'autoenv_init' must exist, for manual calls
# in custom 'cd' functions
test_function_contract() {
	t_is_function 'enable_autoenv'
	t_is_function 'autoenv_init'
}

test_simple() {
	[ 3 = 3 ]
}
