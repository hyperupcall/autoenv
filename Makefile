.PHONY: test test-bats publish

test:
	sh tests/test.sh

test-bats:
	bats tests

test2:
	@echo "=== AUTOENV TESTING SH ==="
	sh ./shelltestrunner.sh
	@echo "=== AUTOENV TESTING BASH ==="
	bash ./shelltestrunner.sh
	@echo "=== AUTOENV TESTING ZSH ==="
	zsh ./shelltestrunner.sh

publish:
	npm publish
