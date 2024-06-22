# shellcheck shell=sh
if [ -n "$AUTOENV_AUTH_FILE" ]; then
	:
elif [ -f "$HOME/.autoenv_authorized" ]; then
	AUTOENV_AUTH_FILE="$HOME/.autoenv_authorized"
else
	_autoenv_state_dir="$XDG_STATE_HOME"
	case $_autoenv_state_dir in
		/*) AUTOENV_AUTH_FILE="$_autoenv_state_dir/autoenv/authorized_list" ;;
		*) AUTOENV_AUTH_FILE="$HOME/.local/state/autoenv/authorized_list" ;;
	esac
	unset -v _autoenv_state_dir
fi
if [ -n "$AUTOENV_NOTAUTH_FILE" ]; then
	:
elif [ -f "$HOME/.autoenv_authorized" ]; then
	# If `.autoenv_authorized` is in home, don't suprise the user by using XDG Base Dir
	AUTOENV_NOTAUTH_FILE="$HOME/.autoenv_not_authorized"
elif [ -f "$HOME/.autoenv_not_authorized" ]; then
	# Ensure file in ~/ is used, even if the authorized file has been moved or deleted
	AUTOENV_NOTAUTH_FILE="$HOME/.autoenv_not_authorized"
else
	_autoenv_state_dir="$XDG_STATE_HOME"
	case $_autoenv_state_dir in
		/*) AUTOENV_NOTAUTH_FILE="$_autoenv_state_dir/autoenv/not_authorized_list" ;;
		*) AUTOENV_NOTAUTH_FILE="$HOME/.local/state/autoenv/not_authorized_list" ;;
	esac
	unset -v _autoenv_state_dir
fi
AUTOENV_ENV_FILENAME="${AUTOENV_ENV_FILENAME:-.env}"
AUTOENV_ENV_LEAVE_FILENAME="${AUTOENV_ENV_LEAVE_FILENAME:-.env.leave}"
AUTOENV_VIEWER="${AUTOENV_VIEWER:-cat}"
# AUTOENV_ENABLE_LEAVE

# @description print a user message to stdout
# @args
#   -b[NUM]: number of lines to print before message
#   -a[NUM]: number of lines to print after message (default=1)
#   -n: do not print trailing newline (same as -a0)
#   message: space seperated text of message
# @example _autoenv_info -n -b1 'my message'
# @internal
_autoenv_info() {
	local after=1 before=0

	while : ; do
		case "$1" in
		-n)  after=0                           ;;
		-b*) before=${1#-b} ; : "${before:=1}" ;;
		-a*) after=${1#-a}  ; : "${after:=1}"  ;;
		*)   break                             ;;
		esac
		shift
	done

	[ $before -gt 0 ] && printf '%*s' ${before} | tr " " "\n"

	if [ -n "$NO_COLOR" ]; then
		printf "[autoenv] %s" "${*}"
	else
		printf "\033[33m[autoenv]\033[0m %s" "${*}"
	fi

	[ $after -gt 0 ] && printf '%*s' ${after} | tr " " "\n"
}

# @description print a message to stderr
# @args
#   message: space seperated text of message
# @example _autoenv_err 'there was an error'
# @internal
_autoenv_err() {
	if [ -n "$NO_COLOR" ]; then
		printf "[autoenv] Error %s" "${*}" >&2
	else
		printf "\033[33m[autoenv]\033[0m \033[31mError\033[0m %s\n" "${*}" >&2
	fi

	return 1
}

# @description print a horizontal line
# @args
#   text: title to print near the beginning of the line
# @example _autoenv_draw_line 'text'
# @internal
_autoenv_draw_line() {
	local text="${1}" char="-" width=${COLUMNS:-80} margin=3 line

	if [ -n "${text}" ]; then
		text="--- ${text} "
	fi

	width=$((width - ${#text} - margin))
	line=$(printf '%*s\n' ${width} | tr " " "${char}")

	if [ -n "$NO_COLOR" ]; then
		printf "%s%s\n\n" "${text}" "$line"
	else
		printf "\033[1m%s%s\033[0m\n\n" "${text}" "$line"
fi
}

# @description display the contents of a `.env` or `.env.leave` file using the `$AUTOENV_VIEWER`` command
# @example _autoenv_show_file './.env_file'
# @internal
_autoenv_show_file() {
	local file="$1" ofs="$IFS"

	_autoenv_info -b "New or modified env file detected:"
	_autoenv_draw_line "${file##*/} contents"
	IFS=" "
	$AUTOENV_VIEWER "${file}"
	IFS="$ofs"
	_autoenv_draw_line
}

# @description Main initialization function
# @internal
autoenv_init() {
	if [ -n "$AUTOENV_ENABLE_LEAVE" ]; then
		autoenv_leave "$@"
	fi

	local _mountpoint _pwd
	_mountpoint="$(command df -P "${PWD}" | command tail -n 1 | command awk '$0=$NF')"
	_pwd=$(echo "${PWD}" | command sed -E 's:/+:/:g') # Removes double slashes. (see #125)

	# Discover all files that we need to source.
	local _files
	_files=$(
		command -v chdir >/dev/null 2>&1 && chdir "${_pwd}" || builtin cd "${_pwd}"
		_hadone=''
		while :; do
			_file="$(pwd -P)/${AUTOENV_ENV_FILENAME}"
			if [ -f "${_file}" ]; then
				if [ -z "${_hadone}" ]; then
					printf %s "${_file}"
					_hadone='1'
				else
					printf %s "
${_file}"
				fi
			fi
			[ "$(pwd -P)" = "${_mountpoint}" ] && break
			[ "$(pwd -P)" = "/" ] && break
			command -v chdir >/dev/null 2>&1 && chdir "$(pwd -P)/.." || builtin cd "$(pwd -P)/.."
		done
	)

	# ZSH: Use traditional for loop
	if [ -n "$ZSH_VERSION" ]; then
		setopt shwordsplit >/dev/null 2>&1
	fi

	# Custom IFS
	origIFS="${IFS}"
	IFS='
'

	set -f
	# Turn around the env files order if needed
	local _orderedfiles=''
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
		_autoenv_check_authz_and_run "${_file}"
	done
	unset -v _orderedfiles
	IFS="${origIFS}"
	set +f

	# ZSH: Unset shwordsplit
	if [ -n "$ZSH_VERSION" ]; then
		unsetopt shwordsplit >/dev/null 2>&1
	fi
}

# @description Checks the hash
# @internal
autoenv_hashline() {
	local _envfile _hash
	_envfile="${1}"
	_hash=$(autoenv_shasum "${_envfile}" | command cut -d' ' -f 1)
	printf '%s\n' "${_envfile}:${_hash}"
}

# @description Source an env file if is able to do so
# @internal
_autoenv_check_authz_and_run() {
	local _envfile="${1}"
	local _hash
	_hash=$(autoenv_hashline "${_envfile}")

	command mkdir -p -- "$(dirname "${AUTOENV_AUTH_FILE}")" "$(dirname "${AUTOENV_NOTAUTH_FILE}")"
	command touch -- "${AUTOENV_AUTH_FILE}" "${AUTOENV_NOTAUTH_FILE}"
	if command grep -q "${_hash}" -- "${AUTOENV_AUTH_FILE}"; then
		autoenv_source "${_envfile}"
		return 0
	elif command grep -q "${_hash}" -- "${AUTOENV_NOTAUTH_FILE}"; then
		return 0
	fi

	if [ -n "${AUTOENV_ASSUME_YES}" ]; then # Don't ask for permission if "assume yes" is switched on
		autoenv_authorize_env "${_envfile}"
		autoenv_source "${_envfile}"
		return 0
	fi

	if [ -z "${MC_SID}" ]; then # Make sure mc is not running
		_autoenv_show_file "${_envfile}"
		_autoenv_info -n "Authorize this file? (y/N/D) "
		read -r answer
		if [ "${answer}" = "y" ] || [ "${answer}" = "Y" ]; then
			autoenv_authorize_env "${_envfile}"
			autoenv_source "${_envfile}"
		elif [ "${answer}" = "d" ] || [ "${answer}" = "D" ]; then
			autoenv_unauthorize_env "${_envfile}"
		fi
	fi
}

# @description Mark an env file as able to be sourced
# @internal
autoenv_deauthorize_env() {
	local _envfile _noclobber
	_envfile="${1}"
	command cp -- "${AUTOENV_AUTH_FILE}" "${AUTOENV_AUTH_FILE}.tmp"
	_noclobber="$(set +o | command grep noclobber)"
	set +C
	command grep -Gv "${_envfile}:" -- "${AUTOENV_AUTH_FILE}.tmp" > "${AUTOENV_AUTH_FILE}"
	eval "${_noclobber}"
	command rm -- "${AUTOENV_AUTH_FILE}.tmp" 2>/dev/null || :
}

# @description Mark an env file as not able to be sourced
# @internal
autoenv_unauthorize_env() {
	local _envfile="$1"
	autoenv_deauthorize_env "$_envfile"
	autoenv_hashline "$_envfile" >> "$AUTOENV_NOTAUTH_FILE"
}

# @description Mark an env file as able to be sourced
# @internal
autoenv_authorize_env() {
	local _envfile
	_envfile="${1}"
	autoenv_deauthorize_env "${_envfile}"
	autoenv_hashline "${_envfile}" >> "${AUTOENV_AUTH_FILE}"
}

# @description Actually source a file
# @internal
autoenv_source() {
	local _allexport
	_allexport="$(set +o | command grep allexport)"
	set -a
	AUTOENV_CUR_FILE="${1}"
	AUTOENV_CUR_DIR="$(dirname "${1}")"
	. "${1}"
	[ "${ZSH_VERSION#*5.1}" != "${ZSH_VERSION}" ] && set +a
	eval "${_allexport}"
	unset AUTOENV_CUR_FILE AUTOENV_CUR_DIR
}

# @description Function to override the 'cd' builtin
autoenv_cd() {
	local _pwd
	_pwd=${PWD}
	if command -v chdir >/dev/null 2>&1 && chdir "${@}" || builtin cd "${@}"; then
		autoenv_init "${_pwd}"
		return 0
	else
		return "${?}"
	fi
}

# @description Cleanup autoenv
autoenv_leave() {
	# execute file when leaving a directory
	local from_dir to_dir
	from_dir="${*}"
	to_dir=$(echo "${PWD}" | command sed -E 's:/+:/:g')

	# Discover all files that we need to source.
	local _files
	_files=$(
		command -v chdir >/dev/null 2>&1 && chdir "${from_dir}" || builtin cd "${from_dir}"
		_hadone=''
		while [ "$PWD" != "" ] && [ "$PWD" != "/" ] && [[ $to_dir/ != $PWD/* ]]; do
			_file="$PWD/${AUTOENV_ENV_LEAVE_FILENAME}"
			if [ -f "${_file}" ]; then
				if [ -z "${_hadone}" ]; then
					printf %s "${_file}"
					_hadone='1'
				else
					printf %s "
${_file}"
				fi
			fi
			command -v chdir >/dev/null 2>&1 && chdir "$(pwd)/.." || builtin cd "$PWD/.."
		done
	)

	# ZSH: Use traditional for loop
	if [ -n "$ZSH_VERSION" ]; then
		setopt shwordsplit >/dev/null 2>&1
	fi

	# Custom IFS
	origIFS="${IFS}"
	IFS='
'

	# Execute the env files
	set -f
	for _file in ${_files}; do
		_autoenv_check_authz_and_run "${_file}"
	done
	IFS="${origIFS}"
	set +f

	# ZSH: Unset shwordsplit
	if [ -n "$ZSH_VERSION" ]; then
		unsetopt shwordsplit >/dev/null 2>&1
	fi
}

# Override the cd alias
if command -v setopt >/dev/null 2>&1; then
	if setopt 2> /dev/null | command grep -q aliasfuncdef; then
		has_alias_func_def_enabled=true
	else
		setopt ALIAS_FUNC_DEF 2>/dev/null
	fi
fi

# @description Run to automatically replace the cd builtin with our improved one
enable_autoenv() {
	if [ -z "${AUTOENV_PRESERVE_CD}" ]; then
		cd() {
			autoenv_cd "${@}"
		}
	fi

	cd "${PWD}"
}

if ! $has_alias_func_def_enabled; then
	unsetopt ALIAS_FUNC_DEF 2> /dev/null
fi

# Probe to see if we have access to a shasum command, otherwise disable autoenv
if command -v gsha1sum >/dev/null 2>&1; then
	autoenv_shasum() {
		gsha1sum "${@}"
	}
	enable_autoenv "$@"
elif command -v sha1sum >/dev/null 2>&1; then
	autoenv_shasum() {
		sha1sum "${@}"
	}
	enable_autoenv "$@"
elif command -v shasum >/dev/null 2>&1; then
	autoenv_shasum() {
		shasum "${@}"
	}
	enable_autoenv "$@"
else
	_autoenv_err "can not locate a compatible shasum binary; not enabling"
fi
