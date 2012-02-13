#!/usr/bin/env bash

autoenv_init()
{
  typeset target home _file
  target=$1
  home="$(dirname $HOME)"

  (
    while [[ "$PWD" != "/" && "$PWD" != "$home" ]]
    do
      _file="$PWD/.env"
      if [[ -e "${_file}" ]]
      then source "${_file}"
      fi
      builtin cd ..
    done
  )
}

cd()
{
  if builtin cd "$@"
  then
    autoenv_init
    return 0
  else
    return $?
  fi
}
