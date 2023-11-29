.PHONY: test

test:
	@if ./test.sh; then echo '[OK] All tests passed'; else echo '[ERR] Tests failed!'; fi
