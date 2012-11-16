.DEFAULT_GOAL := init

clean:
	rm -rf *.egg-info dist

develop:
	python setup.py develop

init:
	gem install dtf --version 0.1.2

install:
	python setup.py install

publish: clean
	python setup.py register sdist upload

test:
	dtf tests/*

uninstall:
	pip uninstall autoenv
