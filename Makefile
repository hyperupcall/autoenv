.PHONY: test publish

test:
	sh tests/test.sh

test2:
	@echo "=== AUTOENV TESTING SH ==="
	sh ./shelltestrunner.sh
	@echo "=== AUTOENV TESTING BASH ==="
	bash ./shelltestrunner.sh
	@echo "=== AUTOENV TESTING ZSH ==="
	zsh ./shelltestrunner.sh
	
publish:
	npm publish
