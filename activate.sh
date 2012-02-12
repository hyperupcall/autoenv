#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function cd(){
    builtin cd "$@"
    $($DIR/detect_env.py)
}
