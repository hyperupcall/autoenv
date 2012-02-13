#!/usr/bin/env bash

autoenv-init()
{
  typeset target home _file
  target=$1
  home="$(dirname $HOME)"

  while read _file
  do
    source "${_file}"
  done < <(
    while [[ "$PWD" != "/" && "$PWD" != "$home" ]]
    do
      _file="$PWD/.env"
      if [[ -e "${_file}" ]]
      then echo "${_file}"
      fi
      builtin cd ..
    done | sort -r
  )
}

cd()
{
  if builtin cd "$@"
  then
    autoenv-init
    return 0
  else
    return $?
  fi
}
