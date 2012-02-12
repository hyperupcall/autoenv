#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function autoenv-init(){
    # Run detect script and split it up.
    saveIFS=$IFS
    IFS=$'\n'

    for cmd in $($DIR/detect_env.py) 
    do
       eval $cmd
    done

    IFS=$saveIFS

}

function cd(){
    builtin cd "$@"
    autoenv-init
}
