# shellcheck shell=sh

. "${FUNCTIONS}"
. "${ACTIVATE_SH}"

# Prepare test directories and files.
mkdir -pv 'dir1' 'dir2' 'dir3'
echo 'echo enter1' > "dir1/.env"
echo 'echo leave1' > "dir1/.env.leave"
echo 'echo enter2' > "dir2/.env"
echo 'echo leave2' > "dir2/.env.leave"
echo 'echo enter3' > "dir3/.env"

abs_dir1=$(
	if \command -v chdir >/dev/null 2>&1; then
		( \chdir dir1 && \pwd -P )
	else
		( \builtin cd dir1 && \pwd -P )
	fi
)
abs_dir2=$(
	if \command -v chdir >/dev/null 2>&1; then
		( \chdir dir2 && \pwd -P )
	else
		( \builtin cd dir2 && \pwd -P )
	fi
)
abs_dir3=$(
	if \command -v chdir >/dev/null 2>&1; then
		( \chdir dir3 && \pwd -P )
	else
		( \builtin cd dir3 && \pwd -P )
	fi
)

# Test autoenv_authorize with both enter and leave files.
out=$(autoenv_authorize dir1)
ret="$?"
if [ ${ret} -ne 0 ]; then
	echo "autoenv_authorize failed with exit code ${ret}."
	exit 1
fi
if ! printf '%s\n' "${out}" | grep -q "Authorized: ${abs_dir1}/.env" ; then
	echo "autoenv_authorize did not authorize .env file."
	exit 1
fi
if ! printf '%s\n' "${out}" | grep -q "Authorized: ${abs_dir1}/.env.leave" ; then
	echo "autoenv_authorize did not authorize .env.leave file."
	exit 1
fi

# Verify the files are authorized by checking if they're in the auth file.
# Use absolute paths for hash calculation.
hash1=$(autoenv_hashline "${abs_dir1}/.env")
hash2=$(autoenv_hashline "${abs_dir1}/.env.leave")
if ! grep -q "${hash1}" "${AUTOENV_AUTH_FILE}"; then
	echo ".env file was not added to auth file."
	exit 1
fi
if ! grep -q "${hash2}" "${AUTOENV_AUTH_FILE}"; then
	echo ".env.leave file was not added to auth file."
	exit 1
fi

# Test autoenv_authorize with only "enter" option.
out=$(autoenv_authorize dir2 enter)
if ! printf '%s\n' "${out}" | grep -q "Authorized: ${abs_dir2}/.env" ; then
	echo "autoenv_authorize with 'enter' did not authorize .env file."
	exit 1
fi
if printf '%s\n' "${out}" | grep -q "Authorized: ${abs_dir2}/.env.leave" ; then
	echo "autoenv_authorize with 'enter' incorrectly authorized .env.leave file."
	exit 1
fi

# Test autoenv_authorize with only "leave" option.
out=$(autoenv_authorize dir2 leave)
if ! printf '%s\n' "${out}" | grep -q "Authorized: ${abs_dir2}/.env.leave" ; then
	echo "autoenv_authorize with 'leave' did not authorize .env.leave file."
	exit 1
fi

# Test autoenv_deauthorize.
out=$(autoenv_deauthorize dir1)
if ! printf '%s\n' "${out}" | grep -q "Deauthorized: ${abs_dir1}/.env" ; then
	echo "autoenv_deauthorize did not deauthorize .env file."
	exit 1
fi
if ! printf '%s\n' "${out}" | grep -q "Deauthorized: ${abs_dir1}/.env.leave" ; then
	echo "autoenv_deauthorize did not deauthorize .env.leave file."
	exit 1
fi

# Verify the files are deauthorized by checking they're not in the auth file.
if grep -q "${hash1}" "${AUTOENV_AUTH_FILE}"; then
	echo ".env file was not removed from auth file."
	exit 1
fi
if grep -q "${hash2}" "${AUTOENV_AUTH_FILE}"; then
	echo ".env.leave file was not removed from auth file."
	exit 1
fi

# Test autoenv_unauthorize (deny).
out=$(autoenv_unauthorize dir3)
if ! printf '%s\n' "${out}" | grep -q "Denied: ${abs_dir3}/.env" ; then
	echo "autoenv_unauthorize did not deny .env file."
	exit 1
fi
hash3=$(autoenv_hashline "${abs_dir3}/.env")
if ! grep -q "${hash3}" "${AUTOENV_NOTAUTH_FILE}"; then
	echo ".env file was not added to not-authorized file."
	exit 1
fi

# Test error handling with non-existent directory.
out=$(autoenv_authorize nonexistent 2>&1)
ret="$?"
if [ ${ret} -eq 0 ]; then
	echo "autoenv_authorize should have failed with non-existent directory."
	exit 1
fi
if ! printf '%s\n' "${out}" | grep -q "is not a directory" ; then
	echo "autoenv_authorize did not report proper error for non-existent directory."
	exit 1
fi

# Test error handling with invalid option.
out=$(autoenv_authorize dir1 invalid 2>&1)
ret="$?"
if [ ${ret} -eq 0 ]; then
	echo "autoenv_authorize should have failed with invalid option."
	exit 1
fi
if ! printf '%s\n' "${out}" | grep -q "invalid argument" ; then
	echo "autoenv_authorize did not report proper error for invalid option."
	exit 1
fi
