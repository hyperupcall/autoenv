AUTOENV_AUTH_FILE="${AUTOENV_AUTH_FILE:-$HOME/.autoenv_authorized}"
AUTOENV_ENV_FILENAME="${AUTOENV_ENV_FILENAME:-.env}"

autoenv_init() {
	local _mountpoint _files _orderedfiles _sedregexp _pwd
	if [ "${OSTYPE#darwin*}" != "${OSTYPE}" ]; then
		_sedregexp='-E'
	else
		_sedregexp='-r'
	fi
	_mountpoint="$(df -P "${PWD}" | tail -1 | awk '{ for(i=6; i<NF; i++) printf "%s",$i OFS; if(NF) printf "%s",$NF; printf ORS}')"
	# Remove double slashes, see #125
	_pwd="`\echo "${PWD}" | \sed "${_sedregexp}" 's:/+:/:g'`"
	# Discover all files we need to source
	# We do this in a subshell so we can cd/chdir
	_files="`
		\command -v chdir >/dev/null 2>&1 && \chdir "${_pwd}" || builtin cd "${_pwd}"
		_hadone=''
		while :; do
			_file="$(\pwd -P)/${AUTOENV_ENV_FILENAME}"
			if [ -f "${_file}" ]; then
				if [ -z "${_hadone}" ]; then
					\echo -n "${_file}"
					_hadone='1'
				else
					\echo -n "
${_file}"
				fi
			fi
			[ "$(\pwd -P)" = "${_mountpoint}" ] && \break
			\command -v chdir >/dev/null 2>&1 && \chdir "$(\pwd -P)/.." || builtin cd "$(pwd -P)/.."
		done
	`"

	# ZSH: Use traditional for loop
	zsh_shwordsplit="$(\setopt > /dev/null 2>&1 | \grep -q shwordsplit && \echo 1)"
	if [ -z "${zsh_shwordsplit}" ]; then
		\setopt shwordsplit >/dev/null 2>&1
	fi
	# Custom IFS
	origIFS="${IFS}"
	IFS='
'

	# Turn around the env files order if needed
	_orderedfiles=''
	if [ -z "${AUTOENV_LOWER_FIRST}" ]; then
		for _file in ${_files}; do
			_orderedfiles="${_file}
${_orderedfiles}"
		done
	else
		_orderedfiles="${_files}"
	fi

	# Execute the env files
	for _file in ${_orderedfiles}; do
		autoenv_check_authz_and_run "${_file}"
	done
	IFS="${origIFS}"

	# ZSH: Unset shwordsplit
	if [ -z "${zsh_shwordsplit}" ]; then
		\unsetopt shwordsplit >/dev/null 2>&1
	fi
}

autoenv_hashline() {
	local _envfile _hash
	_envfile="${1}"
	_hash=$(autoenv_shasum "${_envfile}" | \cut -d' ' -f 1)
	\echo "${_envfile}:${_hash}"
}

autoenv_check_authz() {
	local _envfile _hash
	_envfile="${1}"
	_hash=$(autoenv_hashline "${_envfile}")
	\touch "${AUTOENV_AUTH_FILE}"
	\grep -Gq "${_hash}" "${AUTOENV_AUTH_FILE}"
}

autoenv_check_authz_and_run() {
	local _envfile
	_envfile="${1}"
	if autoenv_check_authz "${_envfile}"; then
		autoenv_source "${_envfile}"
		\return 0
	fi
	if [ -z "${MC_SID}" ]; then # Make sure mc is not running
		\echo "autoenv:"
		\echo "autoenv: WARNING:"
		\echo "autoenv: This is the first time you are about to source ${_envfile}":
		\echo "autoenv:"
		\echo "autoenv:   --- (begin contents) ---------------------------------------"
		\cat -e "${_envfile}" | \sed 's/.*/autoenv:     &/'
		\echo "autoenv:"
		\echo "autoenv:   --- (end contents) -----------------------------------------"
		\echo "autoenv:"
		\printf "%s" "autoenv: Are you sure you want to allow this? (y/N) "
		\read answer
		if [ "${answer}" = "y" ] || [ "${answer}" = "Y" ]; then
			autoenv_authorize_env "${_envfile}"
			autoenv_source "${_envfile}"
		fi
	fi
}

autoenv_deauthorize_env() {
	local _envfile _noclobber
	_envfile="${1}"
	\cp "${AUTOENV_AUTH_FILE}" "${AUTOENV_AUTH_FILE}.tmp"
	_noclobber="$(set +o | \grep noclobber)"
	set +C
	\grep -Gv "${_envfile}:" "${AUTOENV_AUTH_FILE}.tmp" > "${AUTOENV_AUTH_FILE}"
	\eval "${_noclobber}"
	\rm "${AUTOENV_AUTH_FILE}.tmp" 2>/dev/null || :
}

autoenv_authorize_env() {
	local _envfile
	_envfile="${1}"
	autoenv_deauthorize_env "${_envfile}"
	autoenv_hashline "${_envfile}" >> "${AUTOENV_AUTH_FILE}"
}

autoenv_source() {
	local _allexport
	_allexport="$(\set +o | \grep allexport)"
	set -a
	AUTOENV_CUR_FILE="${1}"
	AUTOENV_CUR_DIR="$(dirname "${1}")"
	. "${1}"
	[ "${ZSH_VERSION#*5.1}" != "${ZSH_VERSION}" ] && set +a
	\eval "${_allexport}"
	\unset AUTOENV_CUR_FILE AUTOENV_CUR_DIR
}

do_autoenv() {
	if [ "${?}" -eq 0 ]; then
		autoenv_init
		\return 0
	else
		\return "${?}"
	fi
}

autoenv_cd() {
	\command -v chdir >/dev/null 2>&1 && \chdir "${@}" || builtin cd "${@}"
    do_autoenv
}

autoenv_pushd() {
	builtin pushd "${@}"
    do_autoenv
}

autoenv_popd() {
	builtin popd "${@}"
    do_autoenv
}

# Override the cd alias
enable_autoenv() {
	cd() {
		autoenv_cd "${@}"
	}

	pushd() {
		autoenv_pushd "${@}"
	}

	popd() {
		autoenv_popd "${@}"
	}

	cd "${PWD}"
}

# Probe to see if we have access to a shasum command, otherwise disable autoenv
if \which gsha1sum 2>/dev/null >&2 ; then
	autoenv_shasum() {
		gsha1sum "${@}"
	}
	enable_autoenv
elif \which sha1sum 2>/dev/null >&2; then
	autoenv_shasum() {
		sha1sum "${@}"
	}
	enable_autoenv
elif \which shasum 2>/dev/null >&2; then
	autoenv_shasum() {
		shasum "${@}"
	}
	enable_autoenv
else
	\echo "autoenv: can not locate a compatible shasum binary; not enabling"
fi
