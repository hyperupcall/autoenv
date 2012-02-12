#!/usr/bin/env bash

DIR="$(dirname "$(readlink -f "$0")")"

function autoenv-init(){
    # Run detect script and split it up.
    saveIFS=$IFS; IFS=$'\n'; cmds=($($DIR/detect_env.py)); IFS=$saveIFS

    for cmd in "${cmds[@]}"
    do
       eval $cmd
    done
}

function cd(){
    builtin cd "$@"
    autoenv-init
}
