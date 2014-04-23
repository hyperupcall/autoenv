#!/bin/sh
AUTOENV_AUTH_FILE="${HOME}/.autoenv_authorized"
if [ -z "${AUTOENV_ENV_FILENAME}" ]; then
    AUTOENV_ENV_FILENAME=".env"
fi

if ! chdir >/dev/null 2>&1; then
  alias chdir="builtin cd"  # for bash
fi

autoenv_init() {
  autoenv__home="$(dirname ${HOME})"
  autoenv__files=""

  original_PWD="${PWD}"
  while [ "${PWD}" != "/" ] && [ "${PWD}" != "${autoenv__home}" ]; do
    autoenv__file="${PWD}/${AUTOENV_ENV_FILENAME}"
    if [ -e "${autoenv__file}" ]; then
      if [ -z "${autoenv__files}" ]; then 
        autoenv__files="${autoenv__file}"
      else
        autoenv__files="${autoenv__file}:${autoenv__files}"
      fi
    fi
    chdir .. >/dev/null 2>&1
  done

  chdir "${original_PWD}" >/dev/null 2>&1

  original_IFS=${IFS}
  IFS=:
  for autoenv__envfile in ${autoenv__files}; do
    autoenv_check_authz_and_run "${autoenv__envfile}"
  done
  IFS=${original_IFS}
}

autoenv_env() {
  echo "autoenv:$@"
}

autoenv_printf() {
  printf "autoenv: %s" "$@"
}

autoenv_indent() {
  echo "$@" | sed 's/.*/autoenv:     &/'
}

autoenv_hashline() {
  autoenv__envfile=$1
  if which shasum >/dev/null 2>&1 ; then
    autoenv__hash="$(shasum "${autoenv__envfile}" | cut -d' ' -f 1)"
  else
    autoenv__hash="$(sha1sum "${autoenv__envfile}" | cut -d' ' -f 1)"
  fi
  echo "${autoenv__envfile}:${autoenv__hash}"
}

autoenv_check_authz() {
  autoenv__envfile=$1
  autoenv__hash="$(autoenv_hashline "${autoenv__envfile}")"
  touch "${AUTOENV_AUTH_FILE}"
  grep -Gq "${autoenv__hash}" "${AUTOENV_AUTH_FILE}"
}

autoenv_check_authz_and_run() {
  autoenv__envfile=$1
  if autoenv_check_authz "${autoenv__envfile}" ; then
    autoenv_source "${autoenv__envfile}"
    return 0
  fi
  if [ -z "${MC_SID}" ]; then #make sure mc is not running
    autoenv_env
    autoenv_env "WARNING:"
    autoenv_env "This is the first time you are about to source ${envfile}":
    autoenv_env
    autoenv_env "    --- (begin contents) ---------------------------------------"
    autoenv_indent "${envfile}"
    autoenv_env
    autoenv_env "    --- (end contents) -----------------------------------------"
    autoenv_env
    autoenv_printf "Are you sure you want to allow this? (y/N) "

    read autoenv__answer
    if [ "${autoenv__answer}" = "y" ] || [ "${autoenv__answer}" = "Y" ]; then
      autoenv_authorize_env "${autoenv__envfile}"
      autoenv_source "${autoenv__envfile}"
    fi
  fi
}

autoenv_deauthorize_env() {
  autoenv__envfile="$1"
  \cp "${AUTOENV_AUTH_FILE}" "${AUTOENV_AUTH_FILE}.tmp"
  \grep -Gv "${autoenv__envfile}:" "${AUTOENV_AUTH_FILE}.tmp" \
    > "${AUTOENV_AUTH_FILE}"
}

autoenv_authorize_env() {
  autoenv__envfile=$1
  autoenv_deauthorize_env "${autoenv__envfile}"
  autoenv_hashline "${autoenv__envfile}" >> "${AUTOENV_AUTH_FILE}"
}

autoenv_source() {
  autoenv__allexport="$(set +o | grep allexport)"
  set -a
  . "$1"
  eval "${autoenv__allexport}"
}

autoenv_cd() {
  if chdir "$@" ; then
    autoenv_init
    return 0
  else
    return $?
  fi
}

cd() {
  autoenv_cd "$@"
}

cd "${PWD}"
