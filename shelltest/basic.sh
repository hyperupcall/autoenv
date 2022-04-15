# shellcheck shell=sh

setup_file() {
	export AUTOENV_ASSUME_YES='yes'
	. ./activate.sh
}

# The following functions must exist for API stability
test_defined_functions() {
	t_is_function 'enable_autoenv'
	t_is_function 'autoenv_init'
}
