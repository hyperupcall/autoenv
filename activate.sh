# shellcheck shell=sh
# shellcheck disable=SC2216,SC3043

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
	# If `.autoenv_authorized` is in home, don't suprise the user by using XDG Base Dir.
	AUTOENV_NOTAUTH_FILE="$HOME/.autoenv_not_authorized"
elif [ -f "$HOME/.autoenv_not_authorized" ]; then
	# Ensure file in ~/ is used, even if the authorized file has been moved or deleted.
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

# @internal
__autoenv_cd() {
	if [ "${__autoenv_has_builtin}" = 'yes' ]; then
		\builtin cd "${1}" || return
	else
		# Some shells like "dash" do not have "builtin".
		\chdir "${1}" || return
	fi
}

# @internal
__autoenv_use_color() {
	if [ ${NO_COLOR+x} ]; then
		return 1
	fi
	case $FORCE_COLOR in
	1|2|3) return 0 ;;
	0) return 1 ;;
	esac
	if [ "$TERM" = 'dumb' ]; then
		return 1
	fi
	if [ -t 1 ]; then
		return 0
	fi

	return 1
}

# @description Prints a user message to standard output
# @internal
_autoenv_print() {
	local title="${1}" color="${2}" text="${3}"
	# shellcheck disable=SC2059
	if __autoenv_use_color; then
		\printf "\033[${color}m[${title}]\033[0m ${text}"
	else
		\printf "[${title}] ${text}"
	fi
}

# @description Prints a horizontal line
# @args $1: title text to print near the beginning of the line
# @internal
_autoenv_draw_line() {
	local text="${1}" char="-" width=${COLUMNS:-80} margin=3 line

	if [ -n "${text}" ]; then
		text="--- ${text} "
	fi

	width=$((width - ${#text} - margin))
	line=$(\printf '%*s\n' ${width} | \command tr " " "${char}")

	if __autoenv_use_color; then
		\printf "\033[1m%s%s\033[0m\n" "${text}" "${line}"
	else
		\printf "%s%s\n" "${text}" "${line}"
	fi
}

# @description Main initialization function
# @internal
autoenv_init() {
	if [ -n "$AUTOENV_ENABLE_LEAVE" ]; then
		autoenv_leave "$@"
	fi

	local _mountpoint _pwd
	_mountpoint="$(\command df -P "${PWD}" | \command tail -n 1 | \command awk '$0=$NF')"
	_pwd=$(\echo "${PWD}" | \command sed -E 's:/+:/:g') # Removes double slashes. (see #125)

	# Discover all files that we need to source.
	local _files
	_files=$(
		__autoenv_cd "${_pwd}"
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
			__autoenv_cd "$(\pwd -P)/.."
		done
	)

	# ZSH: Use traditional for loop
	if [ -n "$ZSH_VERSION" ]; then
		\setopt shwordsplit >/dev/null 2>&1
	fi

	# Custom IFS
	origIFS="${IFS}"
	IFS='
'

	\set -f
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
	\unset -v _orderedfiles
	IFS="${origIFS}"
	\set +f

	# ZSH: Unset shwordsplit
	if [ -n "$ZSH_VERSION" ]; then
		\unsetopt shwordsplit >/dev/null 2>&1
	fi
}

# @description Checks the expected hash entry of the file
# @internal
autoenv_hashline() {
	local _envfile="${1}"
	local hash
	_hash=$(autoenv_shasum "${_envfile}" | \command cut -d' ' -f 1)
	\printf '%s\n' "${_envfile}:${_hash}"
}

# @description Source an env file if is able to do so
# @internal
_autoenv_check_authz_and_run() {
	local _envfile="${1}" _hash
	_hash=$(autoenv_hashline "${_envfile}")

	\command mkdir -p -- "$(\command dirname "${AUTOENV_AUTH_FILE}")" "$(\command dirname "${AUTOENV_NOTAUTH_FILE}")"
	\command touch -- "${AUTOENV_AUTH_FILE}" "${AUTOENV_NOTAUTH_FILE}"
	if \command grep -q "${_hash}" -- "${AUTOENV_AUTH_FILE}"; then
		autoenv_source "${_envfile}"
		\return 0
	elif \command grep -q "${_hash}" -- "${AUTOENV_NOTAUTH_FILE}"; then
		\return 0
	fi

	# Don't ask for permission if "assume yes" is switched on
	if [ -n "${AUTOENV_ASSUME_YES}" ]; then
		autoenv_authorize_env "${_envfile}"
		autoenv_source "${_envfile}"
		\return 0
	fi

	if [ -n "${MC_SID}" ]; then # Make sure mc is not running
		\return 0
	fi

	if [ -z "$AUTOENV_VIEWER" ]; then
		\echo "autoenv:"
		\echo "autoenv: WARNING:"
		\printf '%s\n' "autoenv: This is the first time you are about to source ${_envfile}":
		\echo "autoenv:"
		\echo "autoenv:   --- (begin contents) ---------------------------------------"
		\cat -e "${_envfile}" | LC_ALL=C \command sed 's/.*/autoenv:     &/'
		\echo "autoenv:"
		\echo "autoenv:   --- (end contents) -----------------------------------------"
		\echo "autoenv:"
		\printf "%s" "autoenv: Are you sure you want to allow this? (y/N/D) " # Keep (y/N/D) for compatibility.
	else
		_autoenv_print 'autoenv' 36 'New or modified env file detected\n'
		_autoenv_draw_line "Contents of \"${_envfile##*/}\""
		local ofs="${IFS}"
		IFS=" "
		$AUTOENV_VIEWER "${_envfile}"
		IFS="${ofs}"
		_autoenv_draw_line
		_autoenv_print 'autoenv' 36 "Authorize this file? (y/n/d) "
	fi
	\read -r answer
	if [ "${answer}" = "y" ] || [ "${answer}" = "Y" ]; then
		autoenv_authorize_env "${_envfile}"
		autoenv_source "${_envfile}"
	elif [ "${answer}" = "d" ] || [ "${answer}" = "D" ]; then
		autoenv_unauthorize_env "${_envfile}"
	fi
}

# @description Mark an env file as able to be sourced
# @internal
autoenv_deauthorize_env() {
	local _envfile="${1}"
	\command cp -- "${AUTOENV_AUTH_FILE}" "${AUTOENV_AUTH_FILE}.tmp"
	\command grep -Gv "${_envfile}:" -- "${AUTOENV_AUTH_FILE}.tmp" >| "${AUTOENV_AUTH_FILE}"
	\command rm -- "${AUTOENV_AUTH_FILE}.tmp" 2>/dev/null || :
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
	local _envfile="${1}"
	autoenv_deauthorize_env "${_envfile}"
	autoenv_hashline "${_envfile}" >> "${AUTOENV_AUTH_FILE}"
}

# @description Actually source a file
# @internal
autoenv_source() {
	case $-) in
	*a*) ;;
	*) \set -a; __autoenv_set_allexport=yes ;;
	esac

	AUTOENV_CUR_FILE="${1}"
	AUTOENV_CUR_DIR="$(\command dirname "${1}")"
	. "${1}"

	if [ "${__autoenv_set_allexport:-}" = 'yes' ]; then
		\set +a
	fi
	\unset AUTOENV_CUR_FILE AUTOENV_CUR_DIR
}

# @description Function to override the 'cd' builtin
autoenv_cd() {
	local _pwd=${PWD}
	if __autoenv_cd "${@}"; then
		autoenv_init "${_pwd}"
		\return 0
	else
		\return "${?}"
	fi
}

# @description Cleanup autoenv
autoenv_leave() {
	local from_dir="${*}" to_dir
	to_dir=$(\echo "${PWD}" | \command sed -E 's:/+:/:g')

	# Discover all files that we need to source.
	local _files
	_files=$(
		__autoenv_cd "${from_dir}"
		_hadone=''
		while [ "$PWD" != "" ] && [ "$PWD" != "/" ]; do
			case $to_dir/ in
				$PWD/*)
				\break
				;;
			*)
				_file="$PWD/${AUTOENV_ENV_LEAVE_FILENAME}"
				if [ -f "${_file}" ]; then
					if [ -z "${_hadone}" ]; then
						\printf %s "${_file}"
						_hadone='1'
					else
						\printf %s "
${_file}"
					fi
				fi
				__autoenv_cd "$PWD/.."
				;;
			esac
		done
	)

	# ZSH: Use traditional for loop
	if [ -n "$ZSH_VERSION" ]; then
		\setopt shwordsplit >/dev/null 2>&1
	fi

	# Custom IFS
	origIFS="${IFS}"
	IFS='
'

	# Execute the env files
	\set -f
	for _file in ${_files}; do
		_autoenv_check_authz_and_run "${_file}"
	done
	IFS="${origIFS}"
	\set +f

	# ZSH: Unset shwordsplit
	if [ -n "$ZSH_VERSION" ]; then
		\unsetopt shwordsplit >/dev/null 2>&1
	fi
}

# Override the cd alias
if \command -v setopt >/dev/null 2>&1; then
	if \setopt 2> /dev/null | \command grep -q aliasfuncdef; then
		has_alias_func_def_enabled=true
	else
		\setopt ALIAS_FUNC_DEF 2>/dev/null
	fi
fi

# @description Run to automatically replace the cd builtin with our improved one
enable_autoenv() {
	if [ -z "${AUTOENV_PRESERVE_CD}" ]; then
		cd() {
			autoenv_cd "${@}"
		}
	fi

	# shellcheck disable=SC2164
	cd "${PWD}"
}

if ! $has_alias_func_def_enabled; then
	\unsetopt ALIAS_FUNC_DEF 2> /dev/null
fi

__autoenv_has_builtin=no
if __autoenv_output=$(\type builtin); then
	if [ "${__autoenv_output}" = 'builtin is a shell builtin' ]; then
		__autoenv_has_builtin=yes
	fi
fi
unset -v __autoenv_output

# If some shasum exists, specifically use it. Otherwise, do not enable autoenv.
if \command -v gsha1sum >/dev/null 2>&1; then
	autoenv_shasum() {
		gsha1sum "${@}"
	}
	enable_autoenv "$@"
elif \command -v sha1sum >/dev/null 2>&1; then
	autoenv_shasum() {
		sha1sum "${@}"
	}
	enable_autoenv "$@"
elif \command -v shasum >/dev/null 2>&1; then
	autoenv_shasum() {
		shasum "${@}"
	}
	enable_autoenv "$@"
else
	_autoenv_print 'autoenv error' 31 "can not locate a compatible shasum binary; not enabling\n" >&2
fi
