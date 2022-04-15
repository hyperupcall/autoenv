.PHONY: test publish

test:
	sh tests/test.sh

SHELL := /bin/bash

test2:
# FIXME: add dash,yash,ksh,mksh
	shelltest -s sh,bash,zsh ./shelltest
	
publish:
	npm publish
