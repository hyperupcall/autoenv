#!/usr/bin/env bash
AUTOENV_AUTH_FILE=~/.autoenv_authorized

if [[ -n "${ZSH_VERSION}" ]]
then __array_offset=0
else __array_offset=1
fi

autoenv_init()
{
  typeset target home _file
  typeset -a _files
  target=$1
  home="$(dirname $HOME)"

  envfile="$PWD/.env"
  if [[ -e "$envfile" ]]; then
    source "$envfile"
  fi
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
