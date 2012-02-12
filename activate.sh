#!/usr/bin/env bash

AUTOENV_DIR="$(dirname $0)"

autoenv-init()
{
  typeset IFS cmd
  typeset -a cmds
  IFS=$'\n'
  cmds=( $( "${AUTOENV_DIR}/detect_env.py" ) )

  for cmd in ${cmds}
  do
    eval $cmd
  done
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
