#!/usr/bin/env bash
AUTOENV_AUTH_FILE=~/.autoenv_authorized
if [ -z "$AUTOENV_ENV_FILENAME" ]; then
    AUTOENV_ENV_FILENAME=.env
fi

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
      if [[ -e "${_file}" ]]
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
  sed 's/.*/autoenv:     &/' $@
}

autoenv_hashline()
{
  typeset envfile hash
  envfile=$1
  if which shasum &> /dev/null
  then hash=$(shasum "$envfile" | cut -d' ' -f 1)
  else hash=$(sha1sum "$envfile" | cut -d' ' -f 1)
  fi
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
    if [ "$answer" = "y" -o "$answer" = "Y" ]; then
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
  allexport=$(set +o | grep allexport)
  set -a
  source "$1"
  eval "$allexport"
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

cd() {
  autoenv_cd "$@"
}

cd .
