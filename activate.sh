#!/usr/bin/env bash
AUTOENV_AUTH_FILE="${AUTOENV_AUTH_FILE-$HOME/.autoenv_authorized}"
AUTOENV_ENV_FILENAME="${AUTOENV_ENV_FILENAME-.env}"

if [[ -n "${ZSH_VERSION}" ]]
then __array_offset=0
else __array_offset=1
fi

autoenv_init()
{
  defIFS=$IFS
  IFS=$(echo -en "\n\b")

  typeset target home _file
  typeset -a _files
  target=$1
  home="$(dirname $HOME)"

  _files=( $(
    while [[ "$PWD" != "/" && "$PWD" != "$home" ]]
    do
      _file="$PWD/$AUTOENV_ENV_FILENAME"
      if [[ -f "${_file}" ]]
      then echo "${_file}"
      fi
      builtin cd .. &>/dev/null
    done
  ) )

  _file=${#_files[@]}
  while (( _file > 0 ))
  do
    envfile=${_files[_file-__array_offset]}
    autoenv_check_authz_and_run "$envfile"
    : $(( _file -= 1 ))
  done

  IFS=$defIFS
}

autoenv_run() {
  typeset _file
  _file="$(realpath "$1")"
  autoenv_check_authz_and_run "${_file}"
}

autoenv_env() {
  builtin echo "autoenv:" "$@"
}

autoenv_printf() {
  builtin printf "autoenv: "
  builtin printf "$@"
}

autoenv_indent() {
 cat -e $@ | sed 's/.*/autoenv:     &/' 
}

autoenv_hashline()
{
  typeset envfile hash
  envfile=$1
  hash=$(autoenv_shasum "$envfile" | cut -d' ' -f 1)
  echo "$envfile:$hash"
}

autoenv_check_authz()
{
  typeset envfile hash
  envfile=$1
  hash=$(autoenv_hashline "$envfile")
  touch $AUTOENV_AUTH_FILE
  \grep -Gq "$hash" $AUTOENV_AUTH_FILE
}

autoenv_check_authz_and_run()
{
  typeset envfile
  envfile=$1
  if autoenv_check_authz "$envfile"; then
    autoenv_source "$envfile"
    return 0
  fi
  if [[ -z $MC_SID ]]; then #make sure mc is not running
    autoenv_env
    autoenv_env "WARNING:"
    autoenv_env "This is the first time you are about to source $envfile":
    autoenv_env
    autoenv_env "    --- (begin contents) ---------------------------------------"
    autoenv_indent "$envfile"
    autoenv_env
    autoenv_env "    --- (end contents) -----------------------------------------"
    autoenv_env
    autoenv_printf "Are you sure you want to allow this? (y/N) "
    read answer
    if [ "$answer" = "y" ] || [ "$answer" = "Y" ]; then
      autoenv_authorize_env "$envfile"
      autoenv_source "$envfile"
    fi
  fi
}

autoenv_deauthorize_env() {
  typeset envfile
  envfile=$1
  \cp "$AUTOENV_AUTH_FILE" "$AUTOENV_AUTH_FILE.tmp"
  \grep -Gv "$envfile:" "$AUTOENV_AUTH_FILE.tmp" > $AUTOENV_AUTH_FILE
}

autoenv_authorize_env() {
  typeset envfile
  envfile=$1
  autoenv_deauthorize_env "$envfile"
  autoenv_hashline "$envfile" >> $AUTOENV_AUTH_FILE
}

autoenv_source() {
  typeset allexport
  allexport=$(set +o | \grep allexport)
  set -a
  AUTOENV_CUR_FILE=$1
  AUTOENV_CUR_DIR=$(dirname $1)
  source "$1"
  eval "$allexport"
  unset AUTOENV_CUR_FILE AUTOENV_CUR_DIR
}

autoenv_cd()
{
  if builtin cd "$@"
  then
    autoenv_init
    return 0
  else
    return $?
  fi
}

enable_autoenv() {
    cd() {
        autoenv_cd "$@"
    }

    cd .
}

# probe to see if we have access to a shasum command, otherwise disable autoenv
if which gsha1sum 2>/dev/null >&2 ; then
    autoenv_shasum() {
        gsha1sum "$@"
    }
    enable_autoenv
elif which sha1sum 2>/dev/null >&2; then
    autoenv_shasum() {
        sha1sum "$@"
    }
    enable_autoenv
elif which shasum 2>/dev/null >&2; then
    autoenv_shasum() {
        shasum "$@"
    }
    enable_autoenv
else
    echo "Autoenv cannot locate a compatible shasum binary; not enabling"
fi
