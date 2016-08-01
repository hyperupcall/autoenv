.DEFAULT_GOAL := init

clean:
	rm -rf *.egg-info dist

develop:
	python setup.py develop

install:
	python setup.py install

publish: clean
	python setup.py register sdist upload

test:
	sh tests/test.sh

uninstall:
	pip uninstall autoenv
