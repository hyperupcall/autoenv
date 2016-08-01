#!/usr/bin/env dash

# Check if all commands exist
for cmd in bash zsh; do
	if ! which "${cmd}" 2>/dev/null >&2; then
		echo ":: This test requires the ${cmd} executable."
		exit 1
	fi
done

# Settings
shells='bash:bash --noprofile --norc|zsh:zsh' # Shells to test. Shells separated by |, name/executable by :
tests='test_simple|test_cd_spaces|test_auth_spaces|test_not_file' # Tests to run

# Global variables
TMPDIR='' # Global so we can react when the script fails
basedir="$(readlink -f $(dirname $0))" # So we can find our tests
oldpwd="`pwd`" # So we can come back after testing
ZDOTDIR='/dev/null' # Don't use default ZSH files
export ZDOTDIR

# Handle test errors
fail() {
	echo "Fail."
	echo ":: Output of last test:"
	echo
	cd "${oldpwd}"
	cat "${basedir}/lasttest.log"
	test -z "${TMPDIR}" || rm -rf "${TMPDIR}"
}
trap fail EXIT INT TERM
set -e

# Try to find autoenv
ACTIVATE_SH=''
if [ -f "${oldpwd}/activate.sh" ]; then
	ACTIVATE_SH="${oldpwd}/activate.sh"
elif [ -f "${basedir}/activate.sh" ]; then
	ACTIVATE_SH="${basedir}/activate.sh"
elif [ -f "${basedir}/../activate.sh" ]; then
	ACTIVATE_SH="${basedir}/../activate.sh"
else
	echo ":: Can not find autoenv"
	exit 1
fi
export ACTIVATE_SH
# Useful functions
FUNCTIONS="${basedir}/functions"
export FUNCTIONS

# Execute each test for each shell
IFS='|'
for shell in ${shells}; do
	for current_test in ${tests}; do
		# Prepare this test
		echo -n ":: Running ${current_test} for `echo "${shell}" | cut -d':' -f1`..."
		TMPDIR="`mktemp -dp ${basedir} ${current_test}.XXXXXX`"
		AUTOENV_AUTH_FILE="${TMPDIR}/autoenv_authorized" # Don't use default auth file
		export TMPDIR
		export AUTOENV_AUTH_FILE
		cd "${TMPDIR}"
		# Run this test
		eval `echo "$shell" | cut -d':' -f2` "${basedir}/$current_test.sh" > "${basedir}/lasttest.log" 2>&1
		# Tear this test down
		echo "Success."
		cd "${oldpwd}"
		rm -rf "${TMPDIR}"
	done
done
unset IFS

trap '' EXIT INT TERM
