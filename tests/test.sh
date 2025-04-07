#!/usr/bin/env sh

has_cmd() {
	command -v -- "$1" >/dev/null 2>&1
}

# Check if all commands exist
for cmd in bash zsh dash; do
	if ! has_cmd "$cmd"; then
		echo ":: This test requires the ${cmd} executable."
		exit 1
	fi
done

MKTEMP=$(command -v mktemp)
READLINK=$(command -v readlink)
if [ "$(uname)" = "Darwin" ]; then
	for cmd in gmktemp greadlink; do
		if ! has_cmd "$cmd"; then
			echo ":: This test requires the ${cmd} executable."
			exit 1
		fi
	done
	MKTEMP=gmktemp
	READLINK=greadlink
fi

# Settings
shells='bash:bash --noprofile --norc|zsh:zsh|sh:dash' # Shells to test. Shells separated by |, name/executable by :

# Global variables
TMPDIR='' # Global so we can react when the script fails
basedir=$("$READLINK" -f "$(dirname "$0")") # So we can find our tests
oldpwd=$PWD # So we can come back after testing
export ZDOTDIR='/dev/null' # Don't use default ZSH files

# Discover tests
tests=''
for file in $(find "${basedir}" -maxdepth 1 -type f -name 'test_*.sh'); do
	tests="${tests}|$(basename "$file" .sh)"
done
tests="${tests#|}"

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

export ACTIVATE_SH="${oldpwd}/activate.sh"
export FUNCTIONS="${basedir}/functions"

# Execute each test for each shell
IFS='|'
for shell in ${shells}; do
	for current_test in ${tests}; do
		# Prepare this test
		printf %s ":: Running ${current_test} for $(echo "${shell}" | cut -d':' -f1)..."
		TMPDIR=$("$MKTEMP" -dp "${basedir}" "${current_test}.XXXXXX")
		export AUTOENV_AUTH_FILE="${TMPDIR}/autoenv_authorized" # Don't use default auth file
		export TMPDIR
		cd "${TMPDIR}"
		# Run this test
		eval "$(echo "$shell" | cut -d':' -f2) -u ${basedir}/$current_test.sh" > "${basedir}/lasttest.log" 2>&1
		# Tear this test down
		echo "Success."
		cd "${oldpwd}"
		rm -rf "${TMPDIR}"
	done
done
unset -v IFS

trap '' EXIT INT TERM
