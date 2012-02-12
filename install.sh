#!/usr/bin/env bash

echo "Downloading autoenv..."
git clone git@github.com:kennethreitz/autoenv.git ~/.autoenv

# TODO: if bash, if zsh
echo "Done!"

echo "To use autoenv, you should add the following to your ~/.bashrc:"
echo "    source ~/.autoenv/activate.sh"
