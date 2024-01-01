.PHONY: build push secrets

build: build-users
push: push-users
secrets: secrets-users

secrets-%: config/%
	./gen-secrets.sh CTF "config/$*" | tee "config/$*.secrets"

build-%: config/%.secrets
	./build.sh build "$^"

push-%: config/%.secrets
	./build.sh push "$^"
