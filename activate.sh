AUTOENV_AUTH_FILE="${AUTOENV_AUTH_FILE:-$HOME/.autoenv_authorized}"
AUTOENV_ENV_FILENAME="${AUTOENV_ENV_FILENAME:-.env}"
AUTOENV_ENV_LEAVE_FILENAME="${AUTOENV_ENV_LEAVE_FILENAME:-.env.leave}"
AUTOENV_VIEWER=()
# AUTOENV_ENABLE_LEAVE

# choose a viewer if not already set
autoenv_setup() {
  [[ ${#AUTOENV_VIEWER[@]} -gt 0 ]] && return
  while read -r prog args; do
    if command -v $prog > /dev/null; then
      AUTOENV_VIEWER=( "$prog" ${args[@]} )
      return
    fi
  done <<EOF
  bat --style=numbers
  less -N
  cat
EOF
}
autoenv_setup

autoenv_init() {

	if [ -n "$AUTOENV_ENABLE_LEAVE" ]; then
		autoenv_leave "$@"
	fi

	local _mountpoint _files _orderedfiles _sedregexp _pwd
	_sedregexp='-E'

	_mountpoint="$(\df -P "${PWD}" | \tail -n 1 | \awk '$0=$NF')"
	# Remove double slashes, see #125
	_pwd=$(\echo "${PWD}" | \sed "${_sedregexp}" 's:/+:/:g')
	# Discover all files we need to source
	# We do this in a subshell so we can cd/chdir
	_files=$(
		\command -v chdir >/dev/null 2>&1 && \chdir "${_pwd}" || builtin cd "${_pwd}"
		_hadone=''
		while :; do
			_file="$(\pwd -P)/${AUTOENV_ENV_FILENAME}"
			if [ -f "${_file}" ]; then
				if [ -z "${_hadone}" ]; then
					\printf %s "${_file}"
					_hadone='1'
				else
					\printf %s "
${_file}"
				fi
			fi
			[ "$(\pwd -P)" = "${_mountpoint}" ] && \break
			[ "$(\pwd -P)" = "/" ] && \break
			\command -v chdir >/dev/null 2>&1 && \chdir "$(\pwd -P)/.." || builtin cd "$(pwd -P)/.."
		done
	)

	# ZSH: Use traditional for loop
	zsh_shwordsplit="$(\setopt > /dev/null 2>&1 | \command grep -q shwordsplit && \echo 1)"
	if [ -z "${zsh_shwordsplit}" ]; then
		\setopt shwordsplit >/dev/null 2>&1
	fi
	# Custom IFS
	origIFS="${IFS}"
	IFS='
'

	# Disable file globbing
	set -f
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
	# Enable file globbing
	set +f

	# ZSH: Unset shwordsplit
	if [ -z "${zsh_shwordsplit}" ]; then
		\unsetopt shwordsplit >/dev/null 2>&1
	fi
}

autoenv_hashline() {
	local _envfile _hash
	_envfile="${1}"
	_hash=$(autoenv_shasum "${_envfile}" | \cut -d' ' -f 1)
	\printf '%s\n' "${_envfile}:${_hash}"
}

autoenv_check_authz() {
	local _envfile _hash
	_envfile="${1}"
	_hash=$(autoenv_hashline "${_envfile}")
	\command mkdir -p -- "$(\dirname "${AUTOENV_AUTH_FILE}")"
	\command touch -- "${AUTOENV_AUTH_FILE}"
	\command grep -q "${_hash}" -- "${AUTOENV_AUTH_FILE}"
}

# autoenv_message -- print a user message to stdout
#
# args:
# -n          do not print trailing newline
# MESSAGE     space seperated text of message
#
# usage: autoenv_message [-n] MESSAGE...
#
#
autoenv_message() {
  local no_newline

  if [[ "$1" == "-n" ]]; then
    no_newline=true
    shift
  fi

  if [[ -n "$NOCOLOR" ]]; then
    \printf "[autoenv] %s" "${*}"
  else
    \printf "\033[33m[autoenv]\033[0m %s" "${*}"
  fi

  if [[ -z "${no_newline}" ]]; then
    \printf "\n"
  fi
}

autoenv_error() {
  if [[ -n "$NOCOLOR" ]]; then
    \printf "[autoenv] Error %s" "${*}" >&2
  else
    \printf "\033[33m[autoenv]\033[0m \033[31mError\033[0m %s\n" "${*}" >&2
  fi

  return 1
}

# display the contents of a .env or .env.leave file
#   using the $AUTOENV_VIEWER command
autoenv_show_file() {
  local file="$1"

  \echo
  autoenv_message "New or modified env file detected:"
  _autoenv_line "${file##*/} contents"
  "${AUTOENV_VIEWER[@]}" "${file}"
  _autoenv_line
}

# _autoenv_line -- print a horizontal line
#
# args:
# * TEXT: title to print near the beginning of the line
#
# usage: _autoenv_line [TEXT]
#
_autoenv_line() {
  local text="${1}" char="-" width=${COLUMNS:-80}

  if [[ -n "${text}" ]]; then
    text="--- ${text} "
    width=$((width-${#text}))
  fi

  read -r line < <(eval "printf -- '${char}%.0s' {1..${width}}")

  if [[ -n "$NOCOLOR" ]]; then
    \printf "%s%s\n\n" "${text}" "$line"
  else
    \printf "\033[1m%s%s\033[0m\n\n" "${text}" "$line"
  fi
}

autoenv_check_authz_and_run() {
	local _envfile
	_envfile="${1}"
	if autoenv_check_authz "${_envfile}"; then
		autoenv_source "${_envfile}"
		\return 0
	fi
	if [ -n "${AUTOENV_ASSUME_YES}" ]; then # Don't ask for permission if "assume yes" is switched on
		autoenv_authorize_env "${_envfile}"
		autoenv_source "${_envfile}"
                \return 0
        fi
	if [ -z "${MC_SID}" ]; then # Make sure mc is not running
    autoenv_show_file "${_envfile}"
    autoenv_message -n "Authorize this file? (y/N) "
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
	\command cp -- "${AUTOENV_AUTH_FILE}" "${AUTOENV_AUTH_FILE}.tmp"
	_noclobber="$(set +o | \command grep noclobber)"
	set +C
	\command grep -Gv "${_envfile}:" -- "${AUTOENV_AUTH_FILE}.tmp" > "${AUTOENV_AUTH_FILE}"
	\eval "${_noclobber}"
	\command rm -- "${AUTOENV_AUTH_FILE}.tmp" 2>/dev/null || :
}

autoenv_authorize_env() {
	local _envfile
	_envfile="${1}"
	autoenv_deauthorize_env "${_envfile}"
	autoenv_hashline "${_envfile}" >> "${AUTOENV_AUTH_FILE}"
}

autoenv_source() {
	local _allexport
	_allexport="$(\set +o | \command grep allexport)"
	set -a
	AUTOENV_CUR_FILE="${1}"
	AUTOENV_CUR_DIR="$(dirname "${1}")"
	. "${1}"
	[ "${ZSH_VERSION#*5.1}" != "${ZSH_VERSION}" ] && set +a
	\eval "${_allexport}"
	\unset AUTOENV_CUR_FILE AUTOENV_CUR_DIR
}

autoenv_cd() {
	local _pwd
	_pwd=${PWD}
	\command -v chdir >/dev/null 2>&1 && \chdir "${@}" || builtin cd "${@}"
	if [ "${?}" -eq 0 ]; then
		autoenv_init "${_pwd}"
		\return 0
	else
		\return "${?}"
	fi
}

autoenv_leave() {
	# execute file when leaving a directory
	local target_file dir
	dir="${@}"
	target_file="${dir}/${AUTOENV_ENV_LEAVE_FILENAME}"
	[ -f "${target_file}" ] && autoenv_check_authz_and_run "${target_file}"
}

# Override the cd alias
if setopt 2> /dev/null | \command grep -q aliasfuncdef; then
	has_alias_func_def_enabled=true;
else
	setopt ALIAS_FUNC_DEF 2> /dev/null
fi

enable_autoenv() {
	cd() {
		autoenv_cd "${@}"
	}

	cd "${PWD}"
}

if ! $has_alias_func_def_enabled; then
	unsetopt ALIAS_FUNC_DEF 2> /dev/null
fi

# Probe to see if we have access to a shasum command, otherwise disable autoenv
if command -v gsha1sum 2>/dev/null >&2 ; then
	autoenv_shasum() {
		gsha1sum "${@}"
	}
	enable_autoenv
elif command -v sha1sum 2>/dev/null >&2; then
	autoenv_shasum() {
		sha1sum "${@}"
	}
	enable_autoenv
elif command -v shasum 2>/dev/null >&2; then
	autoenv_shasum() {
		shasum "${@}"
	}
	enable_autoenv
else
	autoenv_error "can not locate a compatible shasum binary; not enabling"
fi
