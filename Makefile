.PHONY: test publish

test:
	sh tests/test.sh

test2:
	shelltest -s bash,zsh,dash ./tests2
	
publish:
	npm publish
