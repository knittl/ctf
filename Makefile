.PHONY: test build push secrets

build: build-users
push: push-users
secrets: secrets-users

test:
	@if ./test.sh; then echo '[OK] All tests passed'; else echo '[ERR] Tests failed!'; fi

secrets-%: config/%
	./gen-secrets.sh CTF "config/$*" | tee "config/$*.secrets"

build-%: config/%.secrets
	./build.sh build "$^"

push-%: config/%.secrets
	./build.sh push "$^"
