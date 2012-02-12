#!/usr/bin/env bash

DIR="$(dirname $0)"

function cd(){
    builtin cd "$@"

    # Run detect script and split it up.
    saveIFS=$IFS; IFS=$'\n'; cmds=($($DIR/detect_env.py)); IFS=$saveIFS

    for cmd in ${cmds}
    do
       eval $cmd
    done
}
