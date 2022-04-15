.DEFAULT_GOAL := init

develop:
	python setup.py develop

install:
	python setup.py install

publish:
	npm publish

test:
	sh tests/test.sh

uninstall:
	pip uninstall autoenv
